# encoding: utf-8
require 'csv'

require_relative 'output_writer'

class FileOutputWriter < OutputWriter

  def write_model model_array, output
    CSV.open(output, "w") do |csv|
      csv << model_array
    end
  end

  def write_sparse_matrix_header sparse_matrix_columns, output
    f = File.open(output, 'w')
    YAML.dump(sparse_matrix_columns, f)
    f.close
  end

  class << self
    def write_sparse_matrix_header sparse_matrix_columns, output
      self.new.write_sparse_matrix_header(sparse_matrix_columns, output)
    end
  end

end
