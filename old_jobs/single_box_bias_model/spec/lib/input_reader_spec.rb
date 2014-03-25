# encoding: utf-8
require_relative "../../lib/input_reader"

describe InputReader do

  let(:dummy_json) { "spec/fixtures/dummy_input.json" }

  subject(:input_reader) { InputReader.new }

  it "should respond to :feature_matrix" do
    subject.respond_to?(:feature_matrix).should be_true
  end

  it "should respond to read_input" do
    subject.respond_to?(:read_input).should be_true
  end

  it "should respond to read_dummy_variable_hash" do
    subject.respond_to?(:read_dummy_variable_hash).should be_true
  end

  it "should respond to statis read_input" do
    subject.class.respond_to?(:read_input).should be_true
  end

  its(:feature_matrix) { should == [] }

  it "should read and return the hash from the given file" do
    subject.read_dummy_variable_hash(dummy_json).should == [{1=>true, 2=>true, 3=>true}]
  end

  it "should call .read_input and get nil as response" do
    subject.class.read_input(dummy_json).should be_nil
  end

end
