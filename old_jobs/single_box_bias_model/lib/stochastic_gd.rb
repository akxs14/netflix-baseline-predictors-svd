# encoding: utf-8
require 'java'

require_relative '../jars/concurrent.jar'
require_relative '../jars/colt.jar'

java_import "cern.colt.matrix.DoubleFactory1D"
java_import "cern.colt.matrix.DoubleMatrix1D"
java_import "cern.colt.matrix.linalg.Algebra"
java_import "cern.colt.matrix.impl.DenseDoubleMatrix1D"

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
class StochasticGradientDescent

  def initialize theta, alpha, iterations
    @alpha = alpha
    @theta = theta
    @iterations = iterations
  end

  def train feature_matrix, y
    iterations = @iterations
    theta_count = @theta.size
    alpha = @alpha
    m = feature_matrix.count_valid_rows

    for n in 0...iterations
      for i in 0...m
        for j in 0...theta_count
          new_theta = @theta.get(j) - alpha * j_theta(@theta, feature_matrix, y,  i, j)
          @theta.setQuick(j, new_theta)
        end
      end
    end
    @theta
  end

  private

  private

  def j_theta theta, x, y, b, i, j
    sum = 0
    for k in 0...(i + b)
      sum += (h(theta, x.row(k)) - y.get(k)) * x.value(k,j).to_f
    end
    sum
  end

  def h theta, x
    size = theta.size
    theta.zDotProduct(x,0,size)
  end

end
