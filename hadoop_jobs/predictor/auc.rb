# encoding: utf-8
require 'jrjackson'

require_relative 'roc'

class AUC

  def initialize cutoff_vector, input_file
    @prop_vector = propability_vector
    @roc_results = {}
    @input_file  = input_file
    @roc = ROC.new(input_file,0)
  end

  def run_benchmark
    cutoff_vector.each do |cutoff_prop|
      @roc.cutoff_propability = cutoff_prop
      @roc.test_predictor
      @roc_results[cutoff_prop] = {
        :true_positives  => @roc.true_positives,
        :false_positives => @roc.false_positives,
        :true_negatives  => @roc.true_negatives,
        :false_negatives => @roc.false_negatives
      }
    end
  end

end