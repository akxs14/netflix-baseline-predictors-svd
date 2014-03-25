require 'jrjackson'
require 'redis'

$redis = Redis.new(:host => "de2.madvertise.net", :port => 6379, :db => 3)

module MatchEventsTwo
  class Mapper

    def valid_json? json
      tx      = json['tx'] || "0"
      state   = json['state'] || 0
      spotbuy = json["spotbuy"] || true
      ad      = json["ad"]
      type    = json["type"]

      ((tx != nil || tx != "0") && (200..226).include?(state) && spotbuy == false && ad.is_a?(Integer) && (0..2).include?(type))
     # (json['tx'] &&
     #  (200..226).include?(json['state']) &&
     #  !json['spotbuy'] &&
     #  json['ad'].is_a?(Integer) &&
     #  (0..2).include?(json['type'])
     # )
    end

    def map(key, value, context)
      json = JrJackson::Json.parse(value.to_s)

      tx = json['tx']
      return unless valid_json?(json)

      htx = Hadoop::Io::Text.new(tx)
      context.write(htx, value)
    end
  end

  class Reducer
    def reduce(key, values, context)
      json = JrJackson::Json.parse(values.first.to_s)

      out = {}

      %w(tx ad account advertiser_account age app_id audience banner_type campaign carrier channel country device gender geo_target gps_is_precise imp_token income ip location mraid plattform requester rtb site user_token).each do |k|
        out[k] = json[k]
      end

      impression_timestamp = out['timestamp']

      if impression_timestamp
        ts = Time.at(impression_timestamp)
        out['hour'] = ts.hour
        out['weekday'] = ts.wday
      end

      out['clicks'] = click?(out['tx']) ? 1 : 0

      context.write(nil, Hadoop::Io::Text.new(JrJackson::Json.dump(out)))
    end

    private
    
    def click? token
      $redis.sismember("click_tokens", token)
    end
  end
end
