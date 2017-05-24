require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

dir = File.expand_path '../../../data/strategy1-4/', File.dirname(__FILE__)
exam = Examination.new
exam.stoploss(CbPbHighStopLoss.new,CbPbHigh.new, -1.step(-10,-1),dir) 
