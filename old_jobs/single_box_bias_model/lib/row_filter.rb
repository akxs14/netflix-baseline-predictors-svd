# encoding: utf-8

module RowFilter

  def valid_line_inline json
    tx = json['tx'] || nil
    state = json['state'] || 0
    type = json["type"] || -1
    spotbuy = json["spotbuy"]
    ad = json["ad"] || nil
    (
      (tx != nil) &&
      ((200..226).include?(state)) &&
      ((0..2).include?(type)) &&
      spotbuy &&
      (ad.class != Fixnum)
    )
  end

  def valid_line? json
    (
      transaction_id_valid?(json) &&
      state_valid?(json) &&
      type_valid?(json) &&
      !spotbuy?(json) &&
      !external_ad?(json)
    )
  end

  def transaction_id_valid? json
    tx = json['tx'] || nil
    tx != nil
  end

  def state_valid? json
    state = json['state'] || 0
    (200..226).include?(state)
  end

  def type_valid? json
    type = json["type"] || -1
    (0..2).include?(type)
  end

  def spotbuy? json
    spotbuy = json["spotbuy"]
    spotbuy
  end

  def external_ad? json
    ad = json["ad"] || nil
    ad.class != Fixnum
  end

end
