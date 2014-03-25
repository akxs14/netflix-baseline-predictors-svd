# encoding: utf-8
require 'jrjackson'

module ClicksImpressionsFilter

  IMPRESSION = 0
  CLICK      = 1

  class Mapper
    def map(key, value, context)
      json = JrJackson::Json.parse(value.to_s)
      type = json['type']

      return if !(type == CLICK or type == IMPRESSION)
      context.write(Hadoop::Io::Text.new(''), Hadoop::Io::Text.new(value))
    end
  end

end
