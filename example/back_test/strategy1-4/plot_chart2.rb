require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './cbpb_chart', File.dirname(__FILE__)
include Kabu

chart = CbPb.new
strategy = CbPbHigh.new
dir = File.expand_path '../../../data/strategy1-4/chart/I201'
exam = Examination.new
exam.plot_recorded_chart(strategy,'I201',chart,dir) 
