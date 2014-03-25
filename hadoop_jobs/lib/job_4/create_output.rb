# encoding: utf-8
require 'csv'
require 'jrjackson'
require 'redis'
require_relative "../modules/input_features"

$redis_central = Redis.new(:host => "opt0.madvertise.net", :port => 6379, :db => 4)
$redis_de_prod = Redis.new(:host => "de2.madvertise.net", :port =>6379, :db => 2)

module CreateOutput

  class Mapper
    include InputFeatures

    def setup context
      central_theta = JrJackson::Json.parse($redis_local.get("theta").to_s)
      theta_constituents = $redis_central.get("distributed_theta_vectors_count").to_i
      @central_theta = central_theta.map {|theta| theta / theta_constituents.to_f }

      $redis_de_prod.set("theta", JrJackson::Json.generate(@central_theta))
      @@features.each do |attr|
        dummy_vars = $redis_central.get("attributes:" + attr)
        $redis_de_prod.set("attributes:" + attr, dummy_vars)
      end
    end

    def map key, value, context
      theta = JrJackson::Json.parse(value.to_s)

      htx = Hadoop::Io::Text.new('')
      context.write(htx, Hadoop::Io::Text.new(JrJackson::Json.dump(@central_theta)))
    end

  end

end
