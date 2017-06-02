require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './sma_chart', File.dirname(__FILE__)
include Kabu

code = ARGV[0]
code ||= 'I201'
chart = SmaChart.new
strategy = KamaEmb.new
strategy.m = 10
strategy.s_len = 4
strategy.l_len = 30
dir = File.expand_path "../../../data/strategy2-3/chart/#{code}"
exam = Examination.new
exam.plot_recorded_chart(strategy,code,chart,dir) 
