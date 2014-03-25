require 'jrjackson'
require 'redis'

$redis = Redis.new(:host => "de2.madvertise.net", :port => 6379, :db => 3)

module MatchEventsOne

  CLICK = 1

  class Mapper
    def map(key, value, context)
      json = JrJackson::Json.parse(value.to_s)
      type = json['type']
      tx   = json['tx']

      if (type == CLICK) and tx != 'TX_MISSING'
        $redis.pipelined do
          $redis.sadd "click_tokens", tx
        end
      end
    end
  end
end

