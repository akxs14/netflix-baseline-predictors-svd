# encoding: utf-8
require 'csv'
require 'rubygems'
require 'JrJackson'
require 'redis'

class BiasPredictor

  REDIS_URL  = "opt0.madvertise.net"
  REDIS_PORT = 6379
  REDIS_DB   = 8

  @@features = [
    "clicks",
    "ad",
    "site"
  ]

  def initialize
    @theta = []
    @mi = 0
    @attr_counts = {}
    @dictionary  = {}
    @dictionary_hashes = {}
  end

  def load_model
    @redis = Redis.new(:host => REDIS_URL, :port => REDIS_PORT, :db => REDIS_DB)
    calculate_mi(@redis)
    load_attribute_counts(@redis)
    load_dictionary(@redis)
    load_theta(@redis)
    load_dictionary_hashes
    save_model
  end

  def load_model_file
    load_theta_file("theta.csv")
    load_dictionary_file("dictionary.csv")
    load_dictionary_hashes
  end

  def save_model
    CSV.open("theta.csv", "wb") do |csv|
      csv << @theta
    end
    CSV.open("dictionary.csv", "wb") do |csv|
      @@features.each do |feat|
        csv << [feat, @dictionary[feat]]
      end
    end
  end

  def load_theta_file file_name
    CSV.foreach(file_name) do |row|
      @theta = row.map {|x| x.to_f }
    end
  end

  def load_dictionary_file file_name
    @@features.clear
    CSV.foreach(file_name) do |row|
      attribute = row[0]
      @@features << attribute
      @dictionary[attribute] = row[1].gsub(/[\[\]\" ]/,"").split(",")
      @attr_counts[attribute] = @dictionary[attribute].count
    end
  end

  def calculate_mi redis
    clicks_count = redis.scard("click_tokens").to_i
    impressions_count = redis.get("valid_impressions_count").to_i
    @mi = clicks_count / impressions_count.to_f
  end

  def load_attribute_counts redis
    @@features.each do |feature|
      @attr_counts[feature] = redis.zcard("attributes:" + feature).to_i
    end
  end

  def load_dictionary redis
    @@features.each do |feature|
      @dictionary[feature] = redis.zrange("attributes:" + feature, 0, -1)
    end
  end

  def load_dictionary_hashes
    @@features.each do |feat|
      @dictionary_hashes[feat] = Hash[@dictionary[feat].map.with_index.to_a]
    end
  end

  def load_theta redis
    theta_keys = redis.keys("theta:*")
    theta = Array.new(redis.get(theta_keys.first).gsub(/[\[\]\" ]/,"").split(",").count, 0.0)

    theta_keys.each do |k|
      puts "key: #{k}"
      temp_theta = redis.get(k).gsub(/[\[\]]/,"").split(",")
      temp_theta = temp_theta.map{ |x| x.to_f }
      theta = theta.zip(temp_theta).map{ |pair| pair.reduce(&:+) }
    end
    vectors_count = theta_keys.count
    @theta = theta.map {|x| x / vectors_count }
  end

  def calculate_probability json
    propability = 0
    features_array = @@features.to_a

    @@features.each do |feat|
      dummy_var   = json[feat]

      if @dictionary_hashes[feat].include?(dummy_var)
        dummy_index = 0
        feat_index  = features_array.index(feat)
        (0..feat_index-1).each do |i|
          dummy_index += @attr_counts[features_array[i]]
        end
        dummy_index += @dictionary_hashes[feat][dummy_var]
      end
      propability += @theta[dummy_index] if dummy_index
    end
    propability
  end

end