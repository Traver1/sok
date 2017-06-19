Bundler.require
include Kabu

#codes = (201..233).map {|i| "I#{i}"}
companies = Company.where("market = 'T'")
codes = 0.step(companies.length-1, 10).map {|i|companies[i].code}
exam = Examination2.new
exam.from = Date.parse '20000101'
exam.to = Date.parse '20170501'
strategies = codes.map do |c|
  s = HvAdxAPb.new
  s.code = c
  s
end
dir = File.expand_path "../../../data/strategy3-1/"
exam.trader = Trader.new
exam.trader.percent = false
exam.trader.capital = 1000000
exam.trader.cost = 0.2
exam.plot_summary(strategies,dir)
puts exam.trader.capital
