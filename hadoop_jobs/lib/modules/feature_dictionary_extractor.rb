# encoding: utf-8
require_relative "input_features"

module FeatureDictionaryExtractor
  include InputFeatures

  def save_impression_attributes_inline json, redis
    json.each do |k,v|
      if @@features.include?(k)
        redis.incr("attributes:" + k + ":score")
        score = redis.get("attributes:" + k + ":score").to_i
        redis.zadd("attributes:" + k, score - 1, v)
      end
    end
  end

  def save_impression_attributes json, redis
    json.each do |k,v|
      save_attr_value(k,v,redis) if @@features.include?(k)
    end
  end

  def save_attr_value attribute, value, redis
    if attribute == "timestamp"
      redis.incr("attributes:timestamp:score")
      score = redis.get("attributes:timestamp:score").to_i
      redis.zadd("attributes:weekday", score - 1, timestamp_to_weekday(value))
    else
      redis.incr("attributes:" + attribute +":score")
      score = redis.get("attributes:" + attribute + ":score").to_i
      redis.zadd("attributes:" + attribute, score - 1, value)
    end
  end

  def get_attr_value attribute, redis
    redis.zmembers("attributes:" + attribute)
  end

  def get_attributes_hash redis
    attributes = {}
    @@features.each do |attribute|
      attributes[attribute] = get_attr_value(attribute, redis)
    end
    attributes
  end

  def timestamp_to_weekday value
    Time.at(value).strftime("%A")
  end

end
