# encoding: utf-8
require_relative "../../lib/sparse_matrix"

describe SparseMatrix do

  let(:dataset_file)  { 'spec/fixtures/sample_input.json' }

  let(:yaml_file)     { "spec/fixtures/blablabla.yml" }

  let(:dictionary)    { {"account"=>[1, 3677], "ad"=>[1, 10], "advertiser_account"=>[1, 0],
    "age"=>[0], "banner_type"=>[1], "campaign"=>[], "carrier"=>[481], "channel"=>[1],
    "country"=>[227], "date"=>[1294], "device"=>[1798, 2557], "earnings"=>[0], "gender"=>[0],
    "geo_target"=>[735], "gps_is_precise"=>[false], "ip"=>["174.019.137.001", "107.201.120.001"],
    "location"=>[0], "mraid"=>[false], "plattform"=>[32], "requester"=>["API (html,v1)"], "rtb"=>[true],
    "site"=>[34698, 35044], "weekday"=>["Thursday"], "ua"=>[247006920922414803, 979421220479502540],
    "user_token"=>[]} }

  let(:matrix_header) { ["1", "3677", "1", "10", "1", "0", "0", "1", "481", "1", "227", "1294", "1798",
    "2557", "0", "0", "735", "false", "174.019.137.001", "107.201.120.001", "0", "false", "32",
    "API (html,v1)", "true", "34698", "35044", "Thursday", "247006920922414803", "979421220479502540"] }

  let(:dataset_file_single_line)  { 'spec/fixtures/dummy_features_single_line.json' }

  let(:feature_array) { [ {"account" => 1, "ad" => 10}, {"account" => 2, "ad" => 11} ] }

  let(:feats) { [
      {"account"=>1,            "ad"=>1,                 "advertiser_account"=>1, "ad_provider"=>nil,
       "ad_provider_conf"=>nil, "age"=>0,                "banner_type"=>1,        "bidder"=>26956,
       "campaign"=>nil,         "carrier"=>nil,          "channel"=>1,            "country"=>nil,
       "date"=>1294,            "device"=>1798,          "earnings"=>0,           "gender"=>0,
       "geo_target"=>nil,       "gps_is_precise"=>false, "imp_token"=>1234,       "income"=>0.0,
       "ip"=>"174.019.137.001", "lat"=>nil, "lng"=>nil,  "local_ad_provider"=>nil,"location"=>0,
       "mraid"=>false,          "plattform"=>32,         "remote"=>false,         "requester"=>"API (html,v1)",
       "rtb"=>true,             "site"=>34698,           "spendings"=>0,          "spotbuy"=>false,
       "timestamp"=>1374123928.549855, "token"=>nil,     "tx"=>nil,               "ua"=>247006920922414803,
       "user_token"=>nil,       "ais"=>0,                "bid_requests"=>1,       "bids"=>0,
       "cis"=>0,                "clicks"=>0,             "invalid_clicks"=>0,     "downloads"=>0,
       "ipb"=>0,                "pis"=>0,                "requests"=>0,           "type"=>1,
       "state"=>204
      },
      {
       "account"=>1,            "ad"=>10,               "advertiser_account"=>1,  "ad_provider"=>nil,
       "ad_provider_conf"=>nil, "age"=>0,               "banner_type"=>1,         "bidder"=>26956,
       "campaign"=>nil,         "carrier"=>nil,         "channel"=>1,             "country"=>nil,
       "date"=>1294,            "device"=>1798,         "earnings"=>0,            "gender"=>0,
       "geo_target"=>nil,       "gps_is_precise"=>false,"imp_token"=>nil,        "income"=>0.0,
       "ip"=>"174.019.137.001", "lat"=>nil, "lng"=>nil, "local_ad_provider"=>nil, "location"=>0,
       "mraid"=>false,          "plattform"=>32,        "remote"=>false,          "requester"=>"API (html,v1)",
       "rtb"=>true,             "site"=>34698,          "spendings"=>0,           "spotbuy"=>true,
       "timestamp"=>1374123928.549855, "token"=>nil,    "tx"=>nil,                "ua"=>247006920922414803,
       "user_token"=>nil,       "ais"=>0,               "bid_requests"=>1,        "bids"=>0,
       "cis"=>0,                "clicks"=>0,            "invalid_clicks"=>0,      "downloads"=>0,
       "ipb"=>0,                "pis"=>0,               "requests"=>0,            "type"=>111,
       "state"=>404
      }
  ] }

  subject(:sparse_matrix) { SparseMatrix.new dataset_file }

  describe "#initialize" do
    it { subject.instance_variable_get(:@matrix_header).should == [] }
    it { subject.instance_variable_get(:@input_file).should == dataset_file }
    it { subject.instance_variable_get(:@feature_matrix).should == [] }
    it { subject.instance_variable_get(:@matrix_dictionary).should == {} }
  end

  describe "#get_vectorizer" do
    it "should create an instance of DictVectorizer" do
      subject.send(:get_vectorizer).class.should == DictVectorizer
    end
  end

  describe "#create_matrix_dictionary" do
    it "sould create the dictionary that represents the given dataset" do
      subject.create_matrix_dictionary.should == dictionary
    end
  end

  describe "#create_matrix_header_file" do
    after(:all) { File.delete yaml_file }

    it "should create a matrix header corresponding to the given dictionary" do
      subject.create_matrix_header_file.should == matrix_header
    end

    it "should save the generated dictionary to the given file in YAML form" do
      subject.create_matrix_header_file true, yaml_file
      YAML::load_file(yaml_file).should == dictionary
    end
  end

  describe "#map_dummy_variables" do
    it "should map the variables from the given line to their dummy vars equivalent" do
      line_buf = ""
      File.open(dataset_file_single_line).each {|line| line_buf = line }
      subject.create_matrix_dictionary
      subject.send(:map_dummy_variables,JSON.parse(line_buf)).should == [1,0,0,1]
    end
  end

  describe "#find_attr_column_index" do
    it "return the index of the given attribute value in the dictionary" do
      subject.create_matrix_dictionary
      subject.send(:find_attr_column_index,['account',1]).should == 0
    end

    it "should return nil for a nil attribute value" do
      subject.create_matrix_dictionary
      subject.send(:find_attr_column_index,["account",nil]).should == nil
    end
  end

  describe "#create_attr_dummy_variables" do
    it "generates the dummy variables for row and attribute" do
      subject.create_matrix_dictionary
      subject.send(:create_attr_dummy_variables,["account", 1]).should == [1,0]
    end

    it "should set all variables to zero for a nil variable" do
      subject.create_matrix_dictionary
      subject.send(:create_attr_dummy_variables,["account", nil]).should == [0,0]
    end
  end

  describe "#initialize_matrix" do
    it "should create an instance of SparseDoubleMatrix2D" do
      subject.create_matrix_dictionary
      subject.send(:initialize_matrix).class.should == SparseDoubleMatrix2D
    end

    it "should create a matrix with the correct number of rows" do
      subject.create_matrix_dictionary
      subject.send(:initialize_matrix)
      file_rows = subject.send(:get_row_number)
      file_rows.should == 2
    end

    it "should create a matrix with the correct number of columns" do
      subject.create_matrix_dictionary
      subject.send(:initialize_matrix)
      file_columns = subject.send(:get_row_number)
      file_columns.should == 2
    end
  end

  describe "#insert_row" do
    it "should insert correctly the row in the sparse matrix" do
      subject.create_matrix_dictionary
      subject.matrix = subject.send(:initialize_matrix)
      subject.send(:insert_row, [0, 1, 1, 0], 0)

      first_row = []
      4.times {|i| first_row << subject.matrix.viewRow(0).getQuick(i) }
      first_row.should == [0.0, 1.0, 1.0, 0.0]
    end
  end

  describe "#cardinality" do
    it "should return the number of non-zero elements in the sparse matrix" do
      subject.create_matrix_dictionary
      subject.matrix = subject.send(:initialize_matrix)
      subject.send(:insert_row, [0, 1, 1, 0], 0)
      subject.send(:cardinality).should == 2
    end
  end

  describe "#copy_input_segment" do
    it "should map a variable to its dummy vars equivalent and add it in the current row" do
      subject.create_matrix_dictionary
      mapped_segment, valid_rows = subject.send(:copy_input_segment, feats, 0)
      mapped_segment == [0, 0, 0, 1]
    end
  end

  describe "#populate_sparse_matrix" do
    it "should populate the sparse matrix with the given data set" do
      subject.file_read_batch_size = 1
      subject.populate_sparse_matrix
      subject.matrix.rows.should == 2
    end
  end

  describe "#valid_line?" do
    it "should verify whether a line passes all criteria" do
      subject.send(:valid_line?, feats.first).should be_true
    end

    it "should verify whether a an invalid line is discarded" do
      subject.send(:valid_line?, feats.last).should be_false
    end
  end

  describe "#state_valid?" do
    it { subject.send(:state_valid?, feats.first).should be_true }
    it { subject.send(:state_valid?, feats.last).should be_false }
  end

  describe "#imp_token_valid?" do
    it { subject.send(:imp_token_valid?, feats.first).should be_true }
    it { subject.send(:imp_token_valid?, feats.last).should be_false }
  end

  describe "#spotbuy?" do
    it { subject.send(:spotbuy?, feats.first).should be_false }
    it { subject.send(:spotbuy?, feats.last).should be_true }
  end

  describe "#valid_type?" do
    it { subject.send(:valid_type?, feats.first).should be_true }
    it { subject.send(:valid_type?, feats.last).should be_false }
  end

  describe "#columns" do
    it "should return the number of columns in the sparse matrix" do
      subject.populate_sparse_matrix
      subject.columns.should == 30
    end
  end

  describe "#rows" do
    it "should return the number of rows in the sparse matrix" do
      subject.populate_sparse_matrix
      subject.rows.should == 2
    end
  end

  describe "#row" do
    it "should return the given row from the sparse matrix" do
      subject.populate_sparse_matrix
      row0 = subject.instance_variable_get(:@matrix).viewRow(0)
      subject.row(0).should == row0
    end
  end

  describe "#column" do
    it "should return the given column from the sparse matrix" do
      subject.populate_sparse_matrix
      column0 = subject.instance_variable_get(:@matrix).viewColumn(0)
      subject.column(0).should == column0
    end
  end

  describe "#y_column" do
    it "should return the given column from the sparse matrix" do
      subject.populate_sparse_matrix
      columns = subject.columns - 1
      column0 = subject.instance_variable_get(:@matrix).viewColumn(columns)
      subject.y_column.should == column0
    end
  end

  describe "#value" do
    it "should return the value from cell[i][j] of the sparse matrix" do
      subject.populate_sparse_matrix
      value = subject.instance_variable_get(:@matrix).getQuick(0, 10)
      subject.value(0,10).should == value
    end
  end

end
