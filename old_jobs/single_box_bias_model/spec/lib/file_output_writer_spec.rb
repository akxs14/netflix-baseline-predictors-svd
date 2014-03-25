# encoding: utf-8
require 'yaml'
require 'csv'
require_relative "../../lib/file_output_writer"

describe FileOutputWriter do

  let(:yaml_file)     { "spec/fixtures/matrix_header.yml" }
  let(:matrix_header) { {"account" => [1,2,3]} }
  let(:model_array)   { [0.001, 0.002] }
  let(:csv_file_name) { "spec/fixtures/bias_model.csv" }


  subject(:file_output_writer) { FileOutputWriter.new }

  # after(:each) { File.delete(yaml_file) }

  describe "#write_sparse_matrix_header" do
    it "should save sparse matrix's structure to the given YAML file" do
      subject.write_sparse_matrix_header(matrix_header, yaml_file)
      loaded_yaml = YAML::load_file(yaml_file)
      loaded_yaml.should == matrix_header
      File.delete(yaml_file)
    end
  end

  describe ".write_sparse_matrix_header" do
    it "should save sparse matrix's structure to the given YAML file" do
      FileOutputWriter.write_sparse_matrix_header(matrix_header, yaml_file)
      loaded_yaml = YAML::load_file(yaml_file)
      loaded_yaml.should == matrix_header
      File.delete(yaml_file)
    end
  end

  describe "#write_model" do
    it "should write the given model array to the CSV file with the give name" do
      file_contents = []
      subject.write_model model_array, csv_file_name
      CSV.open(csv_file_name, "r") do |csv|
        file_contents = csv.readline
      end
      file_contents.map(&:to_f).should == model_array
      File.delete(csv_file_name)
    end
  end

end
