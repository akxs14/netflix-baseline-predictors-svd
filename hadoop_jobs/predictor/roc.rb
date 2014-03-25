# encoding: utf-8
require 'jrjackson'

require_relative 'bias_predictor'

class ROC

  attr_accessor :cutoff_propability
  attr_accessor :true_positives, :false_positives
  attr_accessor :true_negatives, :false_negatives

  def initialize test_data_file, cutoff_propability
    @predictor = BiasPredictor.new
    @predictor.load_model_file

    @test_data_file = test_data_file

    @cutoff_propability = cutoff_propability

    @true_positives   = 0
    @false_positives  = 0
    @true_negatives   = 0
    @false_negatives  = 0
  end

  def test_predictor
    File.open(@test_data_file).each do |line|
      json = JrJackson::Json.parse(line)
      type = json["type"]

      if type == 0 || type == 1
        ctr_probability = @predictor.calculate_probability(json).to_f
        classify_propability(ctr_probability, json["clicks"].to_i)
      end
    end
  end

  def output_results
    puts "-------------------------------------------------"
    puts "cut off propability: #{@cutoff_propability}"
    puts "-------------------------------------------------"
    puts "true positives: #{@true_positives}"
    puts "false positives: #{@false_positives}"
    puts "true negatives: #{@true_negatives}"
    puts "false negatives: #{@false_negatives}"
    puts "-------------------------------------------------"
    puts "tp_rate: #{tp_rate}"
    puts "fp_rate: #{fp_rate}"
    puts "-------------------------------------------------"
  end

  private

    def classify_propability propability, y
      case( propability > @cutoff_propability )
      when true
        y == 1 ? @true_positives += 1 : @false_positives += 1
      when false
        y == 0 ? @true_negatives += 1 : @false_negatives += 1
      end
    end

    def tp_rate
      (@true_positives + @false_positives) != 0 ?
        @true_positives / (@true_positives + @false_positives) : 0
    end

    def fp_rate
      (@false_negatives + @true_positives) != 0 ?
        @false_negatives / (@true_negatives + @false_negatives) : 0
    end

    def sensitivity
      tp_rate
    end

    def recall
      tp_rate
    end

    def specificity
      (@false_positives + @true_negatives) != 0 ?
        @true_negatives / (@false_positives + true_negatives) : 0
    end

    def precision
      tp_rate
    end

    def f_measure
      2 / ( (1 / precision) + (1 / recall) )
    end

end