require_relative '../lib/sparse_matrix'

sm = SparseMatrix.new("../test_input/test_events10k.json")
sm.populate_sparse_matrix

# for i in 0...sm.count_valid_rows
#   puts "#{sm.matrix.viewRow(i)}"
# end

puts "number of rows: #{sm.count_valid_rows}"
