require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = TestStrategy.new
dir = File.expand_path '../../../data/strategy1-5/chart/I201'
exam.plot_summary(strategy,'I201',dir)
