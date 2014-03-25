# encoding: utf-8

require_relative "../lib/sparse_matrix"
require_relative "../lib/stochastic_regression"
require_relative "../lib/mini_batch_gd"

sm = SparseMatrix.new("../test_input/test_events2000.json")
sm.populate_sparse_matrix

row = sm.row 0
y_column = sm.y_column

for i in 0..y_column.size
  y_column.setQuick(i, 1) if i % 4 == 0
end

sr = StochasticRegression.new 0.0001, sm.columns
theta = sr.create_theta_vector sm.columns

mbgd = MiniBatchGradientDecent.new theta, 0.0001

puts "#{mbgd.train(sm, y_column)}"

