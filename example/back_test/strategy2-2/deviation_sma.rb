require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = Sma.new
strategy.s_len = 6
strategy.l_len = 36
exam.deviation(strategy)
