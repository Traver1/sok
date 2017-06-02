
require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './sma_chart', File.dirname(__FILE__)
include Kabu

code = ARGV[0]
code ||= 'I230'
strategy = KamaEmb.new
strategy.s_len = 4
strategy.l_len = 30
strategy.m = 10
dir = File.expand_path "../../../data/strategy2-3/"
exam = Examination.new
exam.plot_summary(strategy,code,dir) 
