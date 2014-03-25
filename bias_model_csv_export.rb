# encoding: utf-8

require 'redis'
require 'json'
require 'csv'

features = [
  "clicks",
  "age",
  "country",
  "gps_is_precise",
  "gender",
  "rtb",
  "mraid",
  "banner_type",
  "hour",
  "weekday",
  "platform",
  "device",
  "earnings",
  "campaign",
  "carrier",
  "account",
  "advertiser_account",
  "channel",
  "requester",
  "ad",
  "date",
  "geo_target",
  "location",
  "site",
  "timestamp",
  "ua",
  "user_token",
  "ip",
]

redis = Redis.new(:host => "opt0.madvertise.net", :port => 6379, :db => 8)

dictionary = {}

features.each do |feature|
  dictionary[feature] = redis.zrange("attributes:" + feature, 0, -1)
end

CSV.open('bias_model_features.csv', 'wb') do |csv|
    csv << features
end

CSV.open('bias_model_dictionary.csv', 'wb') do |csv|
  features.each do |feat|
    csv << dictionary[feat]
  end
end

CSV.open('bias_model.csv','wb') do |csv|
  csv << redis.get('theta')
end