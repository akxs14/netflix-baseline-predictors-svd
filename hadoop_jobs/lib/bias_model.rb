# encoding: utf-8
require 'rubydoop'
require 'redis'
require_relative 'job_1/register_clicks'
require_relative 'job_2/match_imps_clicks'
require_relative 'job_3/train_model'
require_relative 'job_4/create_output'

module Compress
  include_package 'org.apache.hadoop.io.compress'
end

Rubydoop.configure do |input_path, output_path|

   job 'Map click tokens to redis' do
     input_path = STDIN.gets if input_path == "-"
     input_path.chomp! # Get rid of new line

     input input_path
     output output_path + "_one"

     raw do |job|
       Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setCompressOutput(job, true)
       Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setOutputCompressorClass(job, Compress::GzipCodec)
     end

     mapper RegisterClicks::Mapper

     map_output_key Hadoop::Io::Text
     map_output_value Hadoop::Io::Text

     output_key Hadoop::Io::Text
     output_value Hadoop::Io::Text

     set 'mapred.reduce.tasks', '0'
   end

   job 'Match impression and click, filter data, create attribute dictionary' do
     input_path = STDIN.gets if input_path == "-"
     input_path.chomp! # Get rid of new line

     input input_path
     output output_path + "_two"

     raw do |job|
       Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setCompressOutput(job, true)
       Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setOutputCompressorClass(job, Compress::GzipCodec)
     end

     mapper MatchImpsClicks::Mapper

     map_output_key Hadoop::Io::Text
     map_output_value Hadoop::Io::Text

     output_key Hadoop::Io::Text
     output_value Hadoop::Io::Text

     set 'mapred.reduce.tasks', '0'
  end

  job 'Train model' do
    input output_path + "_two"
    output output_path + "_three"

    raw do |job|
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setCompressOutput(job, true)
      Hadoop::Mapreduce::Lib::Output::TextOutputFormat.setOutputCompressorClass(job, Compress::GzipCodec)
    end

    mapper TrainModel::Mapper

    map_output_key Hadoop::Io::Text
    map_output_value Hadoop::Io::Text

    output_key Hadoop::Io::Text
    output_value Hadoop::Io::Text

    set 'mapred.reduce.tasks', '0'
  end

end

