# encoding: utf-8
require 'java'

require_relative '../jars/concurrent.jar'
require_relative '../jars/colt.jar'

java_import "cern.colt.matrix.DoubleFactory1D"
java_import "cern.colt.matrix.DoubleMatrix1D"
java_import "cern.colt.matrix.linalg.Algebra"
java_import "cern.colt.matrix.impl.DenseDoubleMatrix1D"
java_import "cern.colt.matrix.impl.SparseDoubleMatrix2D"
java_import "cern.jet.math.Functions"

require_relative 'mini_batch_gd'

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
class BiasMiniBatchGradientDescent < MiniBatchGradientDescent

  def initialize theta, lambda, mi, alpha, iterations = 10, b = 10
    @iterations = iterations
    @lambda = lambda
    @theta = theta
    @alpha = alpha
    @b = b
    @mi = mi
  end

  def train feature_matrix, y
    theta_count, iterations = @theta.size, @iterations
    lambda, b, mi, alpha    = @lambda, @b, @mi, @alpha
    theta, m = @theta.copy, feature_matrix.count_valid_rows
    m_upper_limit  = m - b + 1
    batch_fraction = alpha * (1 / b.to_f)

    start_time = Time.now
    for n in 0...iterations
      puts "iterations: #{n} #{Time.now}"
      (0..m_upper_limit).step(b) do |i|
        for j in 0...theta_count
          new_theta =  y.get(i) - mi - h(theta, feature_matrix.row(i))
          new_theta =  (new_theta * new_theta) + regularization(lambda, theta, feature_matrix.row(i))
          new_theta =  theta.getQuick(j) - (batch_fraction * new_theta)
          theta.setQuick(j, new_theta)
        end
        puts "#{theta}"
        puts "#{(i / m.to_f * 100).round(2)}% complete"
      end
    end
    puts "Run time: #{Time.now - start_time}"
    @theta = theta.copy
  end

  private

  def regularization lambda, theta, x
    theta_e2 = theta.copy.assign(Functions.pow(2))
    sum = lambda * theta_e2.zDotProduct(x,0,x.size)
    sum
  end

end
