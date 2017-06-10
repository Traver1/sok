Bundler.require
include Kabu

codes = (201..233).map {|i| "I#{i}"}
exam = Examination2.new
strategies = codes.map do |c|
  s = ExpMaStrategy.new
  s.code = c
  s
end
dir = File.expand_path "../../../data/strategy2-5/"
exam.trader = Trader.new
exam.trader.percent = false
exam.trader.capital = 1000000
exam.trader.cost = 0.2
exam.plot_summary(strategies,dir)
puts exam.trader.capital
