#!/usr/bin/env ruby

require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/string/conversions'
require 'jrjackson'

input_files_str = `hadoop fs -cat /events/info.json | ruby logs_between.rb #{ARGV[0]} #{ARGV[1]}`
input_files     = input_files_str.split(',')

input_files.each do |input_file|
  input_file.gsub!("\n","")
  output_file = input_file.sub(%r{/events},'/clicks_impressions')

  puts "starting #{input_file} #{output_file}"
  `hadoop jar build/clicks_imps_filter.jar ci_filter #{input_file} #{output_file}`
  puts "finished #{input_file} #{output_file}"
end