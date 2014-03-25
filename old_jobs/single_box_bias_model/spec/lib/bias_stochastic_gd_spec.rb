# encoding: utf-8
require_relative '../jars/concurrent.jar'
require_relative '../jars/colt.jar'

java_import "cern.colt.matrix.DoubleFactory1D"
java_import "cern.colt.matrix.DoubleMatrix1D"
java_import "cern.colt.matrix.linalg.Algebra"
java_import "cern.colt.matrix.impl.DenseDoubleMatrix1D"
java_import "cern.colt.matrix.impl.SparseDoubleMatrix2D"
java_import "cern.jet.math.Functions"

require_relative "../../lib/bias_stochastic_gd"

describe BiasStochasticGradientDescent do

  let(:iterations) { 1 }
  let(:x) { [[1,0,0], [0,1,0], [0,1,0]] }
  let(:y) { DenseDoubleMatrix1D.new([1,0,0]) }
  let(:lambda) { 0.0001 }
  let(:alpha) { 0.01 }
  let(:theta) { [0.0001, 0.0002, 0.0003] }
  let(:mi) { y.select{|num| num == 1}.count / x.count.to_f }

  describe "#regularization" do
    subject { BiasStochasticGradientDescent.new(theta, lambda, mi, alpha, iterations) }
    it { puts subject.send(:regularization,lambda, theta, x[0]) }
  end
end
