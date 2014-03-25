# encoding: utf-8
require_relative "input_features"

module InputVectorizer
  include InputFeatures

  @@attr_counts = {}

  def load_attribute_counts redis
    @@features.each do |feature|
      @@attr_counts[feature] = redis.zcard("attributes:" + feature).to_i
    end
  end

  def calculate_dummy_var_offset feature, dummy_variable, redis
  attr_index, offset = @@features.index(feature), 0

  (0...attr_index).each {|i| offset += @@attr_counts[@@features[i]] - 1 }
  rank = redis.zrank("attributes:" + feature, dummy_variable.to_s)
  offset += (rank.nil? ? 0 : rank)
  end

  def create_sparse_matrix_row json, redis
    values = []
    @@features.each do |feature|
      offset = calculate_dummy_var_offset(feature, json[feature], redis)
      values.push(offset)
    end
    values
  end

end
