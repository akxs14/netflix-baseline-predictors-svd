# encoding: utf-8

require_relative "../lib/logistic_regression"
require_relative "../lib/sparse_matrix"

puts "creating sparse matrix"
sm = SparseMatrix.new("../test_input/test_events2000.json")
sm.populate_sparse_matrix

puts "rows: #{sm.count_valid_rows}"
puts "columns: #{sm.columns}"

puts "enriching sample y vector"
y_column = sm.y_column
for i in 0..y_column.size
  y_column.setQuick(i, 1) if i % 1100 == 0
end

puts "create log.reg. object, train thetas"
lr = LogisticRegression.new sm.columns
lr.train sm, y_column

# puts "estimate row 5:  #{lr.estimate(sm.row(5))}"
# puts "estimate row 10: #{lr.estimate(sm.row(10))}"
# puts "estimate row 15: #{lr.estimate(sm.row(15))}"
# puts "estimate row 20: #{lr.estimate(sm.row(20))}"

