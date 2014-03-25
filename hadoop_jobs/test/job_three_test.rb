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
    $redis_local.flushdb

    calculate_mi($redis_central)
    theta_arity = calculate_theta_arity($redis_central, @@features)
    @theta   = (0..theta_arity).to_a
    @theta   = initialize_theta_vector(@theta)
    @lambda  = 0.0001
    @alpha   = 0.0001
    @b       = 10
    @mi      = $redis_central.get("mi").to_f
  end

  def map filename
    row = 0

    File.open(filename).each do |line|
      start_time = Time.now
      json = JrJackson::Json.parse(line)

      x = create_sparse_matrix_row(json, $redis_local)
      @theta = cost(x, @theta, @mi, @lambda, @alpha)

      puts "iteration duration: #{Time.now - start_time}"
    end

    # cleanup
  end

  def cleanup
    central_theta = JrJackson::Json.parse($redis_local.get("theta"))
    aggregate_theta = [central_theta, @local_theta].transpose.map {|x| x.reduce(:+)}
    $redis_central.incr("distributed_theta_vectors_count")
    $redis_central.set("theta", JrJackson::Json.generate(aggregate_theta))
  end

end

test = ModelTest.new
test.map "bias_two_1.json"
