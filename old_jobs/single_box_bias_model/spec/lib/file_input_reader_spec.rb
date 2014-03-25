# encoding=> utf-8
require_relative "../../lib/file_input_reader"

describe FileInputReader do

  let(:sample_input) { "spec/fixtures/sample_input.json" }

  let(:feats) {
    [
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
       "geo_target"=>nil,       "gps_is_precise"=>false,"imp_token"=>1234,        "income"=>0.0,
       "ip"=>"174.019.137.001", "lat"=>nil, "lng"=>nil, "local_ad_provider"=>nil, "location"=>0,
       "mraid"=>false,          "plattform"=>32,        "remote"=>false,          "requester"=>"API (html,v1)",
       "rtb"=>true,             "site"=>34698,          "spendings"=>0,           "spotbuy"=>false,
       "timestamp"=>1374123928.549855, "token"=>nil,    "tx"=>nil,                "ua"=>247006920922414803,
       "user_token"=>nil,       "ais"=>0,               "bid_requests"=>1,        "bids"=>0,
       "cis"=>0,                "clicks"=>0,            "invalid_clicks"=>0,      "downloads"=>0,
       "ipb"=>0,                "pis"=>0,               "requests"=>0,            "type"=>1,
       "state"=>204
      },
      {
       "account"=>3677,         "ad"=>nil,              "advertiser_account"=>0,  "ad_provider"=>nil,
       "ad_provider_conf"=>nil, "age"=>0,               "banner_type"=>1,         "bidder"=>26956,
       "campaign"=>nil,         "carrier"=>481,         "channel"=>1,             "country"=>227,
       "date"=>1294,            "device"=>2557,         "earnings"=>0,            "gender"=>0,
       "geo_target"=>735,       "gps_is_precise"=>false,"imp_token"=>nil,         "income"=>0.0,
       "ip"=>"107.201.120.001", "lat"=>nil, "lng"=>nil, "local_ad_provider"=>nil, "location"=>0,
       "mraid"=>false,          "plattform"=>32,        "remote"=>false,          "requester"=>"API (html,v1)",
       "rtb"=>true,             "site"=>35044,          "spendings"=>0,           "spotbuy"=>false,
       "timestamp"=>1374123928.490232,"token"=>nil,     "tx"=>nil,                "ua"=>979421220479502540,
       "user_token"=>nil,       "ais"=>0,               "bid_requests"=>1,        "bids"=>0,
       "cis"=>0,                "clicks"=>0,            "invalid_clicks"=>0,      "downloads"=>0,
       "ipb"=>0,                "pis"=>0,               "requests"=>0,            "type"=>21
       }
       ]
     }

  subject(:input_file_reader) { FileInputReader.new }

  it "should read the input file and return the feature matrix via #read_input" do
    subject.read_input(sample_input).should == feats
  end

  it "should read the input file and return the part of feature matrix via #read_input_file_batch" do
    input = []
    subject.send(:read_input_file_batch,sample_input, 3) do |array|
      input = array.clone
    end
    input.should == feats
  end

  it "should read the input file and return the part of feature matrix via #read_input_batch" do
    input = []
    subject.read_input_batch(sample_input, 3) do |array|
      input = array.clone
    end
    input.should == feats
  end

  it "should read the input file via #read_input_file" do
    subject.send(:read_input_file,sample_input).should == feats
    end

  it "should call .read_input and get nil as response" do
    subject.class.read_input(sample_input).should == feats
  end

  it "should return the correct number of lines in the given file" do
    subject.row_count(sample_input).should == 2
  end

end
