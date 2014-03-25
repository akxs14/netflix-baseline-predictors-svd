# encoding: utf-8
require 'redis'
require 'jrjackson'
require_relative "../lib/modules/row_filter"
require_relative "../lib/modules/attribute_time_filter"
require_relative "../lib/modules/feature_dictionary_extractor"

$redis_local = Redis.new(:host => "localhost", :port => 6379, :db => 4)

class ModelTest
  include RowFilter
  include AttributeTimeFilter
  include FeatureDictionaryExtractor

  def initialize
    $redis_local.flushdb
  end

  def map filename
    row = 0

    File.open(filename).each do |line|
      json = JrJackson::Json.parse(line)

      time_start = Time.now

      unless valid_line?(json)
        puts "invalid line"
      else
        incr_valid_impression_count

        filtered_json = filter_impression_attributes(json)
        filtered_json = add_time_fields(filtered_json)
        filtered_json['clicks'] = resulted_to_click?(filtered_json['tx']) == true ? 1 : 0
        save_impression_attributes(filtered_json, $redis_local)

        puts "valid line"

        puts "#{Time.now - time_start}"
      end
    end

  end

end

test = ModelTest.new
test.map "bias_two_1.json"
