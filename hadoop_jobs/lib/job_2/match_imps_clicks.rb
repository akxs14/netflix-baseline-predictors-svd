# encoding: utf-8
require 'java'
require 'jrjackson'
require 'redis'

# require_relative '../../build/jedis-2.1.0.jar'
require_relative "../modules/row_filter"
require_relative "../modules/attribute_time_filter"
require_relative "../modules/feature_dictionary_extractor"

# java_import "redis.clients.jedis.Jedis"

module MatchImpsClicks

  class Mapper
    include RowFilter
    include AttributeTimeFilter
    include FeatureDictionaryExtractor

    def setup context
      # @redis_local = Redis.new(:host => "localhost", :port => 6379, :db => 8)
      # @redis_local.flushdb
      @redis_central = Redis.new(:host => "opt0.madvertise.net", :port => 6379, :db => 8)

      # @click_tokens = get_click_tokens
      # copy_click_tokens_local

      # @click_tokens.clear
      # @redis_central.quit

      @valid_impressions_count = 0
      @feature_counter = {}

      @@features.each do |attr|
        @feature_counter[attr] = 0
      end
    end

    def map key, value, context
      json = JrJackson::Json.parse(value.to_s)

      tx = json['tx'] || nil
      state = json['state'] || 0
      type = json["type"] || -1
      spotbuy = json["spotbuy"]
      ad = json["ad"] || nil

      return unless ((tx != nil) &&
          ((200..226).include?(state)) &&
          ((0..2).include?(type)) &&
          !spotbuy &&
          (ad.class != Fixnum))

      filtered_json = {}
      INCLUDED_ATTRIBUTES.each do |k|
        filtered_json[k] = json[k] if json.include?(k)
      end

      # impression_timestamp = json['timestamp']
      # if impression_timestamp
      #   ts = Time.at(impression_timestamp)
      #   filtered_json['hour'] = ts.hour
      #   filtered_json['weekday'] = ts.wday
      # end

      filtered_json['clicks'] = @redis_central.sismember("click_tokens", filtered_json['tx']) == true ? 1 : 0

      filtered_json.each do |attribute,value|
        if @@features.include?(attribute)
          rank = @redis_central.zrank("attributes:" + attribute, value)

          if rank == nil
            @redis_central.zadd("attributes:" + attribute, @feature_counter[attribute], value)
            @feature_counter[attribute] += 1
          end
        end
      end

      @valid_impressions_count += 1

      htx = Hadoop::Io::Text.new('')
      context.write(htx, Hadoop::Io::Text.new(JrJackson::Json.dump(filtered_json)))
    end

    def cleanup context
      # @redis_central = Redis.new(:host => "opt0.madvertise.net", :port => 6379, :db => 8)
      aggregate_impression_count
      # merge_dictionaries

      # @redis_local.flushdb
      # @redis_local.quit
      @redis_central.quit
    end

    private

    def get_click_tokens
      @redis_central.smembers("click_tokens")
    end

    def copy_click_tokens_local
      @click_tokens.each do |token|
        @redis_local.sadd("click_tokens", token)
      end
    end

    def aggregate_impression_count
      central_impr_count = @redis_central.get("valid_impressions_count").to_i
      central_impr_count = 0 if central_impr_count == nil
      central_impr_count += @valid_impressions_count
      @redis_central.set("valid_impressions_count", central_impr_count)
    end

    def merge_dictionaries
      @@features.each do |attribute|
        central_dict = @redis_central.zrange("attributes:" + attribute, 0, -1)

        if central_dict.empty? == true
          populate_empty_dict(attribute)
        else
          insert_new_dummy_vars(central_dict, attribute)
        end
      end
    end

    def insert_new_dummy_vars central_dict, attribute
      existing_vars_count = central_dict.count
      local_dictionary = @redis_local.zrange("attributes:" + attribute, 0, -1)

      local_dictionary.each do |dummy_var|
        if central_dict.index(dummy_var) == nil
          @redis_central.zadd("attributes:" + attribute, existing_vars_count, dummy_var)
          existing_vars_count += 1
        end
      end
    end

    def populate_empty_dict attribute
      @redis_central.pipelined do
        local_dictionary = @redis_local.zrange("attributes:" + attribute, 0, -1)
        local_dictionary.each do |dummy_var|
          rank = $redis_local.zrank("attributes:" + attribute, dummy_var)
          @redis_local.zadd("attributes:" + attribute, local_dictionary.index(dummy_var), dummy_var)
        end
      end
    end

  end

end
