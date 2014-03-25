# encoding: utf-8
require_relative 'input_reader'
require_relative 'row_filter'

require 'rubygems'
require 'json'
require 'yaml'

class FileInputReader < InputReader
  include RowFilter

  def read_input file_name
    read_input_batch file_name, 20 do |array|
      @feature_matrix << array
    end
    @feature_matrix.flatten
  end

  def read_input_batch file_name, batch_size = 20, &emit
    read_input_file_batch file_name, batch_size, &emit
  end

  def row_count file_name
    rows = 0
    File.open(file_name).each_line do |line|
      rows += 1 if valid_line?(JSON.parse(line))
    end
    rows
  end

  private

  def read_input_file_batch file_name, batch_size, &emit
    counter, temp_array = 0, []

    File.open(file_name).each_line do |line|
      temp_array << JSON.parse(line)
      counter += 1

      if counter == batch_size
        emit.call(temp_array.clone)
        temp_array.clear
        counter = 0
      end
    end

    if !temp_array.empty?
      emit.call(temp_array.clone)
      temp_array.clear
    end
  end

  def read_input_file file_name
    read_input(file_name)
  end

end
