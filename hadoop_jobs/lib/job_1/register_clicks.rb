# encoding: utf-8
require 'jrjackson'
require 'redis'

module RegisterClicks

  CLICK = 1

  class Mapper

    def setup context
      @click_tokens = []
    end

    def map(key, value, context)
      json = JrJackson::Json.parse(value.to_s)
      type = json['type']
      tx   = json['tx']

      if (type == CLICK) and tx != 'TX_MISSING'
        if(@click_tokens.count < 2000)
          @click_tokens.push(tx)
        else
          @click_tokens.push(tx)
          save_tokens
        end
      end
    end

    def cleanup context
      save_tokens
    end

    private

    def save_tokens
      local_tokens = @click_tokens.clone
      redis_central = Redis.new(:host => "opt0.madvertise.net", :port => 6379, :db => 8)
      local_tokens.each {|tx| redis_central.sadd("click_tokens", tx) }
      @click_tokens.clear
    end

  end

end
