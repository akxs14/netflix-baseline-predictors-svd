# encoding: utf-8
require_relative '../predictor/roc'

test_data_file = "ci_1000.json"
ctr_cut_off    = 0.000031

roc = ROC.new(test_data_file, ctr_cut_off)
roc.test_predictor
roc.output_results