# encoding: utf-8

require 'rubygems'
require 'yaml'

class InputReader

  attr_accessor :feature_matrix

  def initialize
    @feature_matrix = []
  end

  def read_input source
    nil
  end

  def read_dummy_variable_hash file_name
    YAML.load_file(file_name)
  end

  class << self
    def read_input source
      self.new.read_input source
    end
  end

end
