# encoding: utf-8

require_relative 'file_output_writer'

class DictVectorizer

  @@features = [
    "account",
    "ad",
    "advertiser_account",
    "age",
    "banner_type",
    "campaign",
    "carrier",
    "channel",
    "country",
    "date",
    "device",
    "earnings",
    "gender",
    "geo_target",
    "gps_is_precise",
    "ip",
    "location",
    "mraid",
    "plattform",
    "requester",
    "rtb",
    "site",
    "timestamp",
    "ua",
    "user_token",
  ]

  @@non_categorical_used = [
    "timestamp"
  ]

  def initialize feature_hash
    @feature_hash = feature_hash
    @attributes = []
    @dictionary = {}
  end

  def generate_sparse_matrix_header logging_enabled = true, file_name = "yaml_header.yml"
    @attributes = filter_variables @feature_hash
    @dictionary = create_dictionary @feature_hash, @attributes
    create_sparse_matrix_header @dictionary, logging_enabled, file_name
  end

  def generate_dictionary
    if @dictionary.empty?
      @attributes = filter_variables @feature_hash
      @dictionary = create_dictionary @feature_hash, @attributes
    else
      @dictionary
    end
  end

  private

  def filter_variables feature_hash = @feature_hash
    attributes, first_record = [], feature_hash.first

    first_record.each do |k,v|
      attributes << k if included?(k) && categorical?(k, v)
    end
    attributes
  end

  def included? var
    @@features.include?(var)
  end

  def categorical? key, var
    !var.is_a?(Float) ^ @@non_categorical_used.include?(key)
  end

  def create_dictionary feature_hash = @feature_hash, attributes = @attributes
    dictionary = {}

    feature_hash.each do |line|
      attributes.each do |v|
        v, line[v] = apply_attr_filters(v, line[v])
        dictionary[v] = [] if !dictionary[v]
        dictionary[v] << line[v] if !dictionary[v].include?(line[v]) and line[v] != nil
      end
    end
    dictionary
  end

  def apply_attr_filters key, value
    key, value = timestamp_to_weekday key, value
    return key, value
  end

  def timestamp_to_weekday key, value
    if key == "timestamp"
      weekday = Time.at(value).strftime("%A")
      key, value = "weekday", weekday
    end
    return key, value
  end

  def create_sparse_matrix_header dictionary = @dictionary, logging_enabled, file_name
    write_matrix_header(@dictionary, file_name) if logging_enabled
    sparse_matrix_header = []

    dictionary.each do |k,v|
      v.each {|val| sparse_matrix_header << val.to_s }
    end
    sparse_matrix_header
  end

  def write_matrix_header dictionary = @dictionary, file_name
    FileOutputWriter.write_sparse_matrix_header dictionary, file_name
  end

end
