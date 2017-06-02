require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = KamaEmb.new

strategy.s_len = 4
strategy.l_len = 30
strategy.m = 10
exam.deviation(strategy)
