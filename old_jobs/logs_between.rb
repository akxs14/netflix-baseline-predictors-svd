#!/usr/bin/env ruby

require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/string/conversions'
require 'jrjackson'


if ARGV.size != 2
  $stderr.puts <<-eos
Usage: hadoop fs -cat /events/info.json | ruby #{__FILE__} <start> <end>

  <start> examples:
      1/6/2013    1st of June 2013
      -2.weeks    two weeks ago (Time.now - 2.weeks)
      1370041200  1st of June 2013

  <end> examples:
      2/6/2013    2nd of June 2013
      +2.weeks    two weeks from <start>
      +1.hour     one hour from <start>
      1370041200  1st of June 2013

eos
  exit -1
end

class String
  def is_ts?
    !!(self =~ /^[0-9]+$/)
  end
end

def parse_arg(base, arg)
  return arg.to_i if arg.is_ts?
  return arg.to_time.to_i if arg.include? '/'
  if arg[0] == '+'
    (base + eval(arg[1..-1])).to_i
  else if arg[0] == '-'
         (base - eval(arg[1..-1])).to_i
       else
         eval(arg).to_i
       end
  end
end

qstart = parse_arg(Time.now, ARGV[0])
qend = parse_arg(Time.at(qstart), ARGV[1])

t = JrJackson::Json.parse($stdin).map do |file, info|
  file if (qstart <= info['end'] && qend >= info['start'])
end

puts t.select{|v| v}.join(',')
