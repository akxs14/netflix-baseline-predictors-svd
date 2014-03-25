# encoding: utf-8
require_relative "../../lib/output_writer"

describe OutputWriter do

  subject(:output_writer) { OutputWriter.new }

  it "should respond to :sparse_matrix_columns" do
    subject.respond_to?(:sparse_matrix_columns).should be_true
  end

  it "should respond to :sparse_matrix_cols_to_yaml" do
    subject.respond_to?(:write_sparse_matrix_header).should be_true
  end

  it "should respond to :write_model" do
    subject.respond_to?(:write_model).should be_true
  end

  it "class should respond to :sparse_matrix_columns" do
    subject.class.respond_to?(:write_sparse_matrix_header).should be_true
  end

  it "#write_sparse_matrix_header should not have any specific behaviour and return nil" do
    subject.write_sparse_matrix_header({}, "output_file.yml").should be_nil
  end

  it "#write_model should not have any specific behaviour and return nil" do
    subject.write_model({}, "output_file.yml").should be_nil
  end

  it ".write_sparse_matrix_header should not have any specific behaviour and return nil" do
    OutputWriter.write_sparse_matrix_header({}, "output_file.yml").should be_nil
  end

end