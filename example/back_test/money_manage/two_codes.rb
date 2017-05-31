Bundler.require
include Kabu

codes = ["I201", "I202"]
exam = Examination2.new
strategy = MoneyManageTwoCodes.new
dir = File.expand_path "../../../data/money-manage/"
exam.trader = Trader.new
exam.trader.percent = false
exam.trader.capital = 1000000
exam.trader.cost = 0.2
exam.plot_summary(strategy,codes,dir)
puts exam.trader.capital
