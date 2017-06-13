Bundler.require
include Kabu

n = 12000
code = 'I201'
strategy = MoneyManage.new

exam = Examination.new
exam.scramble(strategy, code, n)
