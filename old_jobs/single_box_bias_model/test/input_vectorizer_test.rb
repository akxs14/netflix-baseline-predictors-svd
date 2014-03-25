# encoding: utf-8
require 'json'
require 'redis'

features = [
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

redis = Redis.new(:host => "localhost", :port => 6379, :db => 6)

#################################################################################
### feature extractor code
#################################################################################
def save_impression_attributes json, redis, features
  json.each do |k,v|
    save_attr_value(k,v,redis) if features.include?(k)
  end
end

def save_attr_value attribute, value, redis
  redis.incr("attributes:" + attribute + ":count")
  score = redis.get("attributes:" + attribute + ":count")

  if attribute == "timestamp"
    redis.zadd("attributes:weekday", score, timestamp_to_weekday(value))
  else
    redis.zadd("attributes:" + attribute, score, value)
  end
end

def timestamp_to_weekday value
  Time.at(value).strftime("%A")
end
#################################################################################

#################################################################################
### input vectorizer
#################################################################################
def load_attribute_counts redis
  features.each do |feature|
    attr_counts[feature] = redis.zcard("attributes:" + feature)
  end
end

def calculate_dummy_var_offset feature, dummy_variable, redis, features, attr_counts
  attr_index, offset = features.index(feature), 0

  (0...attr_index).each {|i| offset += attr_counts[features[i]].to_i }
  rank = redis.zrank("attributes:" + feature, dummy_variable.to_s)
  offset += (rank.nil? ? 0 : rank)
end

def create_sparse_matrix_row json, redis, features, attr_counts
  redis.incr "sparse_matrix_row_index"
  index, values = redis.get("sparse_matrix_row_index"), []

  features.each do |feature|
    feature_value = (json[feature].nil? ? 0: json[feature])
    offset = calculate_dummy_var_offset(feature, feature_value, redis, features, attr_counts)
    values.push(offset)
  end
  redis.hset("sparse_matrix", index, values.to_s)
  values
end

def load_attribute_counts redis, features
  attr_counts = {}
  features.each do |feature|
    attr_counts[feature] = redis.zcard("attributes:" + feature)
  end
  attr_counts
end
#################################################################################


File.open("../test_input/test_events5.json").each do |line|
  json = JSON.parse(line)
  save_impression_attributes json, redis, features
end

attr_counts = load_attribute_counts redis, features
puts attr_counts

File.open("../test_input/test_events5.json").each do |line|
  json = JSON.parse(line)
  create_sparse_matrix_row json, redis, features, attr_counts
end

