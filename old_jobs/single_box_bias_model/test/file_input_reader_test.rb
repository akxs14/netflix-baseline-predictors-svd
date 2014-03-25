require_relative '../lib/sparse_matrix'

file_input_reader = HadoopInputReader.new
feature_hash = file_input_reader.read_input "../test_input/test_events3k.json"

def valid_json? json
 (json.include?('tx') &&
 !json['spotbuy']    &&
  json["ad"].is_a?(Integer) &&
  json["type"]
 )
end

valid_rows = 0
feature_hash.each{|row| valid_rows += 1 if valid_json?(row) == true }
puts "valid rows: #{valid_rows}"

# dict_vectorizer = DictVectorizer.new feature_hash
# dictionary = dict_vectorizer.generate_dictionary
# puts dictionary

