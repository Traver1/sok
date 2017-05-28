require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = MoneyManage.new
exam.deviation(strategy)
