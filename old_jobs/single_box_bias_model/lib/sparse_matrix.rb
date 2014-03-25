# encoding: utf-8
require 'java'

require_relative '../jars/concurrent.jar'
require_relative '../jars/colt.jar'

java_import "cern.colt.matrix.DoubleFactory2D"
java_import "cern.colt.matrix.DoubleMatrix2D"
java_import "cern.colt.matrix.impl.DenseDoubleMatrix2D"
java_import "cern.colt.matrix.linalg.Algebra"
java_import "cern.colt.matrix.impl.SparseDoubleMatrix2D"

require_relative 'hadoop_input_reader'
require_relative 'dict_vectorizer'
require_relative 'row_filter'

class SparseMatrix
  include RowFilter

  attr_accessor :input_file
  attr_accessor :dict_vectorizer
  attr_accessor :matrix
  attr_accessor :file_read_batch_size
  attr_accessor :count_valid_rows

  def initialize input_file
    @matrix_header, @input_file = [], input_file
    @feature_matrix, @matrix_dictionary = [], {}
    @file_read_batch_size, @count_valid_rows = 1000, 0
  end

  def create_matrix_dictionary
    dict_vectorizer    = get_vectorizer
    @matrix_dictionary = dict_vectorizer.generate_dictionary
    @matrix_dictionary
  end

  def create_matrix_header_file save_in_file = false, file_name = 'sparse_matrix_columns.yml'
    dict_vectorizer = get_vectorizer
    @matrix_header  = dict_vectorizer.generate_sparse_matrix_header save_in_file, file_name
  end

  def populate_sparse_matrix
    create_matrix_dictionary
    @matrix = initialize_matrix
    file_input_reader = HadoopInputReader.new
    row_index = 0

    file_input_reader.read_input_batch @input_file, @file_read_batch_size do |array|
      segment, @count_valid_rows = self.copy_input_segment(array, @count_valid_rows)
      segment.each {|row| row_index = insert_row(row, row_index) }
    end
    @matrix
  end

  def copy_input_segment segment, count_valid_rows
    mapped_segment = []

    segment.each do |line|
      next if !valid_line?(line)
      count_valid_rows += 1
      mapped_segment << map_dummy_variables(line)
    end

    return mapped_segment, count_valid_rows
  end

  def cardinality
    @matrix.cardinality
  end

  def columns
    @matrix.columns
  end

  def rows
    self.count_valid_rows
  end

  def row index
    @matrix.viewRow index
  end

  def column index
    @matrix.viewColumn index
  end

  def y_column
    @matrix.viewColumn (@matrix.columns - 1)
  end

  def value x,y
    @matrix.getQuick(x,y)
  end

  private

  def insert_row row, row_index
    for column in 0..row.count
      @matrix.setQuick row_index, column, row[column]
    end
    row_index += 1
  end

  def map_dummy_variables line
    sparse_matrix_row = []

    line.each do |attr|
      if @matrix_dictionary[attr[0]]
        sparse_matrix_row.concat(create_attr_dummy_variables(attr))
      end
    end
    sparse_matrix_row
  end

  def create_attr_dummy_variables attr
    dummy_var_array = []
    var_cardinality = @matrix_dictionary[attr[0]].count
    var_cardinality.times { dummy_var_array << 0 }

    if !attr[1].nil?
      index = find_attr_column_index(attr)
      dummy_var_array[index] = 1
    end
    dummy_var_array
  end

  def find_attr_column_index attr
    @matrix_dictionary[attr[0]].index(attr[1])
  end

  def initialize_matrix
    create_matrix_header_file
    rows = get_row_number
    cols = get_column_number
    SparseDoubleMatrix2D.new(rows, cols)
  end

  def get_row_number
    file_input_reader = HadoopInputReader.new
    file_input_reader.row_count @input_file
  end

  def get_column_number
    @matrix_header.count
  end

  def get_vectorizer
    file_reader = HadoopInputReader.new
    @feature_matrix = file_reader.read_input @input_file
    dict_vectorizer = DictVectorizer.new @feature_matrix
  end

end
