require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = Sma65Cc3Ravi.new(0.5)
exam.deviation(strategy) 
