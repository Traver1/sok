require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

dir = File.expand_path '../../../data/strategy1-4/', File.dirname(__FILE__)
exam = Examination.new
exam.mfe(CbPbHigh.new, dir) 
