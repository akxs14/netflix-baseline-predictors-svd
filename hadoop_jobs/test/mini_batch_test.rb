# encoding: utf-8
require 'redis'
require 'jrjackson'
require_relative "../lib/modules/input_features"
require_relative "../lib/modules/input_vectorizer"
require_relative "../lib/modules/bias_mini_batch_gradient_descent"

$redis_central = Redis.new(:host => "opt0.madvertise.net", :port => 6379, :db => 4)
$redis_local = Redis.new(:host => "localhost", :port => 6379, :db => 4)

class ModelTest
  include InputFeatures
  include InputVectorizer
  include BiasMiniBatchGradientDescent

  def initialize
    load_attribute_counts($redis_central)

    calculate_mi($redis_central)
    @theta   = Array.new(calculate_theta_arity($redis_central, @@features))
    @theta   = initialize_theta_vector(@theta)
    @lambda  = 0.0001
    @alpha   = 0.0001
    @b       = 10
    @mi      = $redis_central.get("mi").to_f

    @batch_buffer  = []
    @batch_counter = 1
  end

  def map filename
    row = 0

    copy_dictionary_locally

    File.open(filename).each do |line|
      start_time = Time.now
      json = JrJackson::Json.parse(line)

      @batch_buffer.push(json)

      if @batch_counter % @b == 0
        cost_sum, non_zero_indices = 0, {}

        @batch_buffer.each do |x_json|
          # calculate x vector for given observation
          x = []
          @@features.each do |feature|
            attr_index, offset = @@features.index(feature), 0

            (0...attr_index).each {|i| offset += @@attr_counts[@@features[i]] - 1 }
            rank = $redis_local.zrank("attributes:" + feature, x_json[feature].to_s)
            offset += (rank.nil? ? 0 : rank)
            x.push(offset)
          end

          #calculate the sum of cost functions for the batch
          x_without_y = x[1..x.count]
          x_without_y.each_with_index do |value, index|
            cost_sum += (x[0] - (@mi + x_without_y.map{|j| @theta[j] }.reduce(:+)))
            non_zero_indices[value] = 1
          end
        end
        cost_avg = @alpha * (1.to_f / @b) * cost_sum
        non_zero_indices.each {|j, v| @theta[j] -= cost_avg }
        @batch_buffer.clear
      end

      @batch_counter += 1

      puts "iteration duration: #{Time.now - start_time}"
    end

  end

  def cleanup
    central_theta = JrJackson::Json.parse($redis_local.get("theta"))
    aggregate_theta = [central_theta, @local_theta].transpose.map {|x| x.reduce(:+)}
    $redis_central.incr("distributed_theta_vectors_count")
    $redis_central.set("theta", JrJackson::Json.generate(aggregate_theta))
  end

  def copy_dictionary_locally
    @@features.each do |attr|
      attr_dict = $redis_central.zrange("attributes:" + attr, 0, -1)
      attr_dict.each_with_index do |value, index|
        $redis_local.zadd("attributes:" + attr, index, value)
      end
    end
  end

end

test = ModelTest.new
test.map "bias_two_1.json"
