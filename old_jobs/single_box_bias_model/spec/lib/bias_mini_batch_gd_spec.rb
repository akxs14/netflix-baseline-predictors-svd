# encoding: utf-8
require_relative "../../lib/input_reader"
require_relative "../../lib/bias_mini_batch_gd"

describe BiasMiniBatchGradientDescent do

  let(:iterations) { 1 }
  let(:x) { [[1,0,0], [0,1,0], [0,1,0]] }
  let(:y) { [1,0,0] }
  let(:lambda) { 0.0001 }
  let(:alpha) { 0.01 }
  let(:theta) { [0.0001, 0.0002, 0.0003] }
  let(:mi) { y.select{|num| num == 1}.count / x.count.to_f }

  describe "#regularization" do
    # subject { BiasMiniBatchGradientDescent.new(theta, lambda, mi, alpha, iterations)  }
    # it { puts subject.send(:regularization, lambda, theta, x[0]) }
  end

end
