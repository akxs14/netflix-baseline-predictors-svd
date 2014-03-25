# encoding: utf-8
require 'java'

require_relative '../jars/concurrent.jar'
require_relative '../jars/colt.jar'

java_import "java.math.BigDecimal"

java_import "cern.colt.matrix.DoubleFactory1D"
java_import "cern.colt.matrix.DoubleMatrix1D"
java_import "cern.colt.matrix.linalg.Algebra"
java_import "cern.colt.matrix.impl.DenseDoubleMatrix1D"
java_import "cern.colt.matrix.impl.DenseObjectMatrix1D"

require_relative "file_output_writer"
require_relative "mini_batch_gd"
require_relative "stochastic_gd"
require_relative "bias_mini_batch_gd"
require_relative "bias_stochastic_gd"

# notation:
#   x = input feature, or simply input variable
#   X = input value space
#   y = target variable, output
#   Y = output value space
#   h = hypothesis function, the predictor function, maps x to expected y values
#   b = mini-batch size, the number of examples used in each iteration
#   theta   = the parameters / weights that parameterize the mapping from X to Y
#   a_b     = partial differential equation, partial a over partial b
#   alpha   = learning rate
#   mi (μ)  = the training set's average CTR
#   epsilon (ε) = the step of the difference per iteration step
#   lambda (λ)  = the regularization factor, used to avoid overfitting
#
class LogisticRegression

  @@iterations = 5
  @@epsilon_lower_bound = 0.00001
  @@epsilon_upper_bound = 0.00005
  @@scale_factor = 10 ** 5

  def initialize row_arity
    @default_theta  = 0.0001
    @default_lambda = 0.0001
    @alpha  = 0.0001
    @lambda = 0.0001 #create_lambda_vector row_arity
    @theta  = create_theta_vector row_arity
    @mi = 0
  end

  def train feature_matrix, y, model_file_name = "bias_model.csv"
    calculate_mi feature_matrix, y
    @theta = up_scale_vector @theta
    bgd = BiasStochasticGradientDescent.new @theta, @lambda, @mi, @alpha, @@iterations
    @theta = bgd.train feature_matrix, y
    @theta = down_scale_vector @theta
    write_model @theta, model_file_name
    @theta
  end

  def estimate x
    @mi + biases_sum(x)
  end

  private

  def create_lambda_vector arity
    DenseDoubleMatrix1D.new( Array.new(arity) { @default_lambda }.to_java(:double) )
  end

  def create_theta_vector arity
    vector = DenseDoubleMatrix1D.new(arity)
    (0...arity).each {|i| vector.set(i, random_theta) }
    vector
  end

  def up_scale_vector vector
    vector_size = vector.size
    for i in 0...vector_size
      vector.setQuick(i, vector.getQuick(i) * @@scale_factor.to_f)
    end
    vector
  end

  def down_scale_vector vector
    vector_size  = vector.size
    scale_factor = 1 / @@scale_factor.to_f
    for i in 0...vector_size
      vector.setQuick(i, vector.getQuick(i) * scale_factor)
    end
    vector
  end


  def write_model model, model_file_name
    fow = FileOutputWriter.new
    fow.write_model model.toArray, model_file_name
  end

  def  biases_sum x
    attributes_count, sum = x.size - 2, 0 #last column is y so it is excluded
    for i in 0..attributes_count
      sum += x.getQuick(i) * @theta.getQuick(i)
    end
    sum
  end

  def calculate_mi feature_matrix, y
    @mi = y.cardinality / feature_matrix.count_valid_rows.to_f
  end

  def random_theta
    rand(@@epsilon_lower_bound..@@epsilon_upper_bound)
  end

end
