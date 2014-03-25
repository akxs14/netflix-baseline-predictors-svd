# encoding: utf-8
require 'rubydoop'
require_relative 'job_1/ci_filter_mapper'

module Compress
  include_package 'org.apache.hadoop.io.compress'
end

Rubydoop.configure do |input_path, output_path|

  job 'Filter Clicks and Impressions from raw stream' do
    input_path = STDIN.gets if input_path == "-"
    input_path.chomp! # Get rid of new line

    input input_path
    output output_path + "_one"

    raw do |job|
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setCompressOutput(job, true)
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setOutputCompressorClass(job, Compress::GzipCodec)
    end

    mapper ClicksImpressionsFilter::Mapper

    map_output_key Hadoop::Io::Text
    map_output_value Hadoop::Io::Text

    output_key Hadoop::Io::Text
    output_value Hadoop::Io::Text

    set 'mapred.reduce.tasks', '0'
  end

end

