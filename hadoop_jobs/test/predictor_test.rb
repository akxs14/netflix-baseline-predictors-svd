# encoding: utf-8
require_relative "../predictor/bias_predictor"

predictor = BiasPredictor.new
# predictor.load_model
predictor.load_model_file

File.open("ci_1000.json").each do |line|
  predictor.calculate_probability(line)
end
