Bundler.require
include Kabu

code = "I201"
com = Company.find_by_code code
exam = Examination.new
strategy = MoneyManageHukusu.new
dir = File.expand_path "../../../data/strategy1-5/chart/#{code}"
exam.trader = Trader.new
exam.trader.percent = false
exam.trader.capital = 1000000
exam.trader.cost = 0.2
exam.plot_summary(strategy,code,dir)
puts exam.trader.capital
