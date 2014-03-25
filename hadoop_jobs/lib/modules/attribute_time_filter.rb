# encoding: utf-8
module AttributeTimeFilter

  INCLUDED_ATTRIBUTES = %w(
    tx
    ad
    account
    advertiser_account
    age
    app_id
    audience
    banner_type
    campaign
    carrier
    channel
    country
    device
    gender
    geo_target
    gps_is_precise
    imp_token
    income
    ip
    location
    mraid
    plattform
    requester
    rtb
    site
    user_token)

  def filter_impression_attributes json
    filtered_json = {}

    INCLUDED_ATTRIBUTES.each do |k|
      filtered_json[k] = json[k] if json.include?(k)
    end
    filtered_json
  end

  def add_time_fields json
    impression_timestamp = json['timestamp']

    if impression_timestamp
      ts = Time.at(impression_timestamp)
      json['hour'] = ts.hour
      json['weekday'] = ts.wday
    end
    json
  end

end