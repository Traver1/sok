
require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './sma_chart', File.dirname(__FILE__)
include Kabu

code = ARGV[0]
code ||= 'I222'
strategy = KamaLama.new
dir = File.expand_path "../../../data/strategy2-2/"
exam = Examination.new
exam.plot_summary(strategy,code,dir) 
