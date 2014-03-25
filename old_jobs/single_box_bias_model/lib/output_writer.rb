# encoding: utf-8

require 'rubygems'
require 'json'
require 'yaml'

class OutputWriter

  attr_accessor :sparse_matrix_columns

  def write_model model_array, output
    nil
  end

  def write_sparse_matrix_header sparse_matrix_columns, output
    nil
  end

  class << self
    def write_sparse_matrix_header sparse_matrix_columns, output
      nil
    end
  end

end
