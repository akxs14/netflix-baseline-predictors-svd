# encoding: utf-8
module BiasStochasticGradientDescent

  @@iterations = 5
  @@epsilon_lower_bound = 0.00001
  @@epsilon_upper_bound = 0.00005

###
#
# Initialization functions
#
###

  def calculate_mi redis
    clicks_count = redis.scard("click_tokens").to_i
    impressions_count = redis.get("valid_impressions_count").to_i
    mi = clicks_count / impressions_count.to_f
    redis.set("mi", mi)
  end

  def calculate_theta_arity redis, features
    arity = 0
    features.each do |feature|
      arity += redis.zcard("attributes:" + feature).to_i
    end
    arity
  end

  def initialize_theta_vector theta_vector
    arity = theta_vector.count
    (0...arity).each {|i| theta_vector[i] = random_theta }
    theta_vector
  end

  def random_theta
    rand(@@epsilon_lower_bound..@@epsilon_upper_bound)
  end

###
#
# Actual SGD functions
#
###

  def cost x, theta, mi, lambda, alpha
    x_without_y = x[1..x.count]
    x_without_y.each do |j|
      # theta[j] = (theta[j] + alpha * (x[0] - probability(mi, x, theta))) + regularization(lambda, theta, x)
      theta[j] = (theta[j] + alpha * \
        (x[0] - (mi + x_without_y.map{ |j| theta[j] }.reduce(:+)))) + \
        (lambda * x_without_y.map {|j| theta[j] ** 2 }.reduce(:+))
    end
    theta
  end

  def probability mi, x, theta
    x_without_y = x[1..x.count]
    mi + x_without_y.map{ |j| theta[j] }.reduce(:+)
  end

  def hypothesis x, theta
    x_without_y = x[1..x.count]
    x_without_y.map {|i| theta[i] }.reduce(:+)
  end

  def regularization lambda, x, theta
    x_without_y = x[1..x.count]
    lambda * x_without_y.map {|j| theta[j] ** 2 }.reduce(:+)
  end

###
#
# => inline SGD training
#
###
  def train_sgd json
    x = []
    @@features.each do |feature|
      attr_index, offset = @@features.index(feature), 0

      (0...attr_index).each {|i| offset += @@attr_counts[@@features[i]] - 1 }
      rank = $redis_local.zrank("attributes:" + feature, json[feature].to_s)
      offset += (rank.nil? ? 0 : rank)
      x.push(offset)
    end

    x_without_y = x[1..x.count]
    x_without_y.each do |j|
      @theta[j] = (@theta[j] + @alpha * \
        (x[0] - (@mi + x_without_y.map{ |j| @theta[j] }.reduce(:+)))) + \
        (@lambda * x_without_y.map {|j| @theta[j] ** 2 }.reduce(:+))
    end
  end

end
