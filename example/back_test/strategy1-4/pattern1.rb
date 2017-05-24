require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = CbPbDays.new(50)
exam.deviation(strategy)
