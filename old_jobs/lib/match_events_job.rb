require 'rubydoop'
require 'match_events_one'
require 'match_events_two'

module Compress
  include_package 'org.apache.hadoop.io.compress'
end

Rubydoop.configure do |input_path, output_path|
  job 'Map click tokens to redis' do
    input input_path
    output output_path + "_one"

    raw do |job|
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setCompressOutput(job, true)
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setOutputCompressorClass(job, Compress::GzipCodec)
    end

    mapper MatchEventsOne::Mapper

    map_output_key Hadoop::Io::Text
    map_output_value Hadoop::Io::Text

    output_key Hadoop::Io::NullWritable
    output_value Hadoop::Io::Text

    set 'mapred.reduce.tasks', '0'
  end

  job 'Match impression and click data' do
    input input_path
    output output_path+"_two"

    raw do |job|
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setCompressOutput(job, true)
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setOutputCompressorClass(job, Compress::GzipCodec)
    end

    mapper MatchEventsTwo::Mapper
    reducer MatchEventsTwo::Reducer

    map_output_key Hadoop::Io::Text 
    map_output_value Hadoop::Io::Text

    output_key Hadoop::Io::NullWritable
    output_value Hadoop::Io::Text

    set 'mapred.reduce.tasks', '3'
  end
end

