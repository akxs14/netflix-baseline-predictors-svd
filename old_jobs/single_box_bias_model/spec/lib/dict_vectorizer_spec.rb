# encoding: utf-8
require_relative "../../lib/dict_vectorizer"

describe DictVectorizer do

  let(:feats) { [
    {"account"=>3677, "ad"=>nil, "advertiser_account"=>1, "ad_provider"=>nil, "ad_provider_conf"=>nil,
     "age"=>0, "banner_type"=>1, "bidder"=>26956, "campaign"=>nil, "carrier"=>nil, "channel"=>1,
     "country"=>nil, "date"=>1294, "device"=>1798, "earnings"=>0, "gender"=>0, "geo_target"=>nil,
     "gps_is_precise"=>false, "imp_token"=>nil, "income"=>0.0, "ip"=>"174.019.137.001", "lat"=>nil,
     "lng"=>nil, "local_ad_provider"=>nil, "location"=>0, "mraid"=>false, "plattform"=>32, "remote"=>false,
     "requester"=>"API (html,v1)", "rtb"=>true, "site"=>34698, "spendings"=>0, "spotbuy"=>false,
     "timestamp"=>1374123928.549855, "token"=>nil, "tx"=>nil, "ua"=>247006920922414803, "user_token"=>nil,
     "ais"=>0, "bid_requests"=>1, "bids"=>0, "cis"=>0, "clicks"=>0, "invalid_clicks"=>0, "downloads"=>0,
     "ipb"=>0, "pis"=>0, "requests"=>0, "type"=>1
    },
    {"account"=>4102, "ad"=>nil, "advertiser_account"=>1, "ad_provider"=>nil, "ad_provider_conf"=>nil,
      "age"=>0, "banner_type"=>1, "bidder"=>26956, "campaign"=>nil, "carrier"=>145, "channel"=>1,
      "country"=>64, "date"=>1294, "device"=>4003, "earnings"=>0, "gender"=>0, "geo_target"=>399,
      "gps_is_precise"=>false, "imp_token"=>nil, "income"=>0.0, "ip"=>"181.112.236.001", "lat"=>nil,
      "lng"=>nil, "local_ad_provider"=>nil, "location"=>0, "mraid"=>false, "plattform"=>32, "remote"=>false,
      "requester"=>"API (html,v1)", "rtb"=>true, "site"=>75122, "spendings"=>0, "spotbuy"=>false,
      "timestamp"=>1374123928.499789, "token"=>nil, "tx"=>nil, "ua"=>1002539825826374964, "user_token"=>nil,
      "ais"=>0, "bid_requests"=>1, "bids"=>0, "cis"=>0, "clicks"=>0, "invalid_clicks"=>0, "downloads"=>0,
      "ipb"=>0, "pis"=>0, "requests"=>0, "type"=>2
    }
  ] }

  let(:simple_feats) {
    [
     {"account" => 1},
     {"account" => 2}
   ]
  }

  let (:matrix_header) {
    ["3677", "4102", "1", "0", "1", "145", "1", "64", "1294", "1798", "4003", "0", "0", "399", "false",
      "174.019.137.001", "181.112.236.001", "0", "false", "32", "API (html,v1)", "true", "34698", "75122",
      "Thursday", "247006920922414803", "1002539825826374964"]
  }

  let(:simple_matrix_header) {
    ["1", "2"]
  }

  let(:attribute_dictionary) {
    {"account"=>[3677, 4102], "ad"=>[], "advertiser_account"=>[1], "age"=>[0], "banner_type"=>[1], "campaign"=>[],
     "carrier"=>[145], "channel"=>[1], "country"=>[64], "date"=>[1294], "device"=>[1798, 4003], "earnings"=>[0],
     "gender"=>[0], "geo_target"=>[399], "gps_is_precise"=>[false], "ip"=>["174.019.137.001", "181.112.236.001"],
     "location"=>[0], "mraid"=>[false], "plattform"=>[32], "requester"=>["API (html,v1)"], "rtb"=>[true],
     "site"=>[34698, 75122], "weekday"=>["Thursday"], "ua"=>[247006920922414803, 1002539825826374964], "user_token"=>[]}
  }

  let(:simple_attr_dictionary) {
    {
      "account" => [1,2]
    }
  }

  let(:yaml_file) { 'sparse_matrix_columns.yml' }

  subject(:dict_vectorizer) { DictVectorizer.new(feats) }

  describe "#initialize" do
    it { subject.instance_variable_get(:@feature_hash).should == feats }
    it { subject.instance_variable_get(:@attributes).should == [] }
    it { subject.instance_variable_get(:@dictionary).should == {} }
  end

  describe "#categorical?" do
    it { subject.send(:categorical?, "timestamp", feats.first["timestamp"]).should be_true }
    it { subject.send(:categorical?, "account", feats.first["account"]).should be_true }
  end

  describe "#write_matrix_header" do
    it "should write sparse matrix's header" do
      subject.send(:write_matrix_header, attribute_dictionary, yaml_file )
      YAML::load_file(yaml_file).should == attribute_dictionary
    end
  end

  describe "#filter_variables" do
    it "should filter out the attributes that don't pass all criteria" do
      subject.send(:filter_variables,feats).should == DictVectorizer.class_variable_get(:@@features)
    end
  end

  describe "#create_dictionary" do
    it "should create a hash with the feature as a key and an array with the range of attribute's values as values" do
      attributes = subject.send(:filter_variables, simple_feats)
      subject.send(:create_dictionary, simple_feats, attributes).should == simple_attr_dictionary
    end
  end

  describe "#create_sparse_matrix_header" do
    it "should generate an array with the values of every accepted attribute" do
      attributes = subject.send(:filter_variables, feats)
      dictionary = subject.send(:create_dictionary, feats, attributes)
      subject.send(:create_sparse_matrix_header, simple_attr_dictionary, false, "").should == simple_matrix_header
    end
  end

  describe "#generate_sparse_matrix_header" do
    it "should create the sparse matrix's header in an array form" do
      subject.generate_sparse_matrix_header(false).should == matrix_header
    end
  end

  describe "#generate_dictionary" do
    it "should generate the dictionary from scratch" do
      subject.generate_dictionary.should == attribute_dictionary
    end

    it "shoud return an already generated dictionary" do
      subject.generate_dictionary if subject.instance_variable_get(:@dictionary).send(:empty?)
      subject.generate_dictionary.should == attribute_dictionary
    end
  end

  describe "#timestamp_to_weekday" do
    it "should extract the weekday of an event from its timestamp" do
      subject.send(:timestamp_to_weekday, "timestamp", feats.first["timestamp"]).should == ["weekday","Thursday"]
    end
  end

  describe "#apply_attr_filters" do
    it "should filter timestamps and extract the weekday" do
      subject.send(:apply_attr_filters, "timestamp", feats.first["timestamp"]).should == ["weekday","Thursday"]
    end
  end

end
