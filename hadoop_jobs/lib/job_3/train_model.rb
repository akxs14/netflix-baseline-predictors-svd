# encoding: utf-8
require 'jrjackson'
require 'redis'
require_relative "../modules/input_features"
require_relative "../modules/input_vectorizer"
require_relative "../modules/bias_stochastic_gradient_descent"
require_relative "../modules/bias_mini_batch_gradient_descent"

# notation:
#   x = input feature, or simply input variable
#   X = input value space
#   y = target variable, output
#   Y = output value space
#   h = hypothesis function, the predictor function, maps x to expected y values
#   b      = mini-batch size, the number of examples used in each iteration
#   a_b    = partial differential equation, partial a over partial b
#   mi (μ) = the training set's average CTR
#   alpha (α)  = learning rate
#   lambda (λ) = the regularization factor, used to avoid overfitting
#   theta (θ)  = the parameters / weights that parameterize the mapping from X to Y
#
module TrainModel

  class Mapper
    include InputFeatures
    include InputVectorizer
    include BiasMiniBatchGradientDescent

    def setup context
      @redis_central = Redis.new(:host => "opt0.madvertise.net", :port => 6379, :db => 8)
      # @redis_local = Redis.new(:host => "localhost", :port => 6379, :db => 8)
      @redis_central.set("distributed_theta_vectors_count",0)
      load_attribute_counts(@redis_central)
      # copy_dictionary_locally

      calculate_mi(@redis_central)
      initialize_learning_parameters
    end

    def map key, value, context
      json = JrJackson::Json.parse(value.to_s)
      train_mbgd(json)
    end

    def cleanup context
      vector_index = @redis_central.incr("theta_vectors_index")
      @redis_central.set("theta:" + vector_index.to_s, JrJackson::Json.generate(@theta))
      # @redis_local.flushdb
    end

    private

    def train_mbgd json
      @batch_buffer.push(json)
      x_without_y = []

      if @batch_counter % @b == 0
        cost_sum, non_zero_indices = 0, {}

        @batch_buffer.each do |x_json|
          # calculate x vector for given observation
          x = []
          @@features.each do |feature|
            attr_index, offset = @@features.index(feature), 0

            (0...attr_index).each {|i| offset += @@attr_counts[@@features[i]] - 1 }
            rank = @redis_central.zrank("attributes:" + feature, x_json[feature].to_s)
            offset += (rank.nil? ? 0 : rank)
            non_zero_indices[offset] = 1
            x.push(offset)
          end

          #calculate the sum of cost functions for the batch
          x_without_y = x[1..x.count]
          cost_sum += x[0] - (@mi + x_without_y.map{|j| @theta[j] }.reduce(:+))
        end
        # update theta vector
        cost_avg = (@alpha * (1.to_f / @b) * cost_sum) + \
          # + regularization
          @lambda * x_without_y.map {|j| @theta[j] ** 2 }.reduce(:+)

        non_zero_indices.each {|j, v| @theta[j] -= cost_avg }

        @batch_buffer.clear
      end

      @batch_counter += 1
    end

    def initialize_learning_parameters
      @theta   = Array.new(calculate_theta_arity(@redis_central, @@features))
      @theta   = initialize_theta_vector(@theta)
      @lambda  = 0.0001
      @alpha   = 0.0001
      @b       = 1000
      @mi      = @redis_central.get("mi").to_f

      @batch_buffer  = []
      @batch_counter = 1
    end

    def copy_dictionary_locally
      # @redis_local.flushdb

      @@features.each do |attr|
        attr_dict = @redis_central.zrange("attributes:" + attr, 0, -1)
        attr_dict.each_with_index do |value, index|
          @redis_central.zadd("attributes:" + attr, index, value)
        end
      end
    end

  end

end
