Bundler.require
include Kabu

#codes = (201..233).map {|i| "I#{i}"}
companies = Company.where("not code like 'I%'")
codes = 1.step(companies.length-1, 10).map {|i|companies[i].code}
exam = Examination2.new
strategies = codes.map do |c|
  s = KamaEmb.new
  s.s_len = 4
  s.l_len = 30
  s.m = 10
  s.code = c
  s
end
dir = File.expand_path "../../../data/strategy2-3/"
exam.trader = Trader.new
exam.trader.percent = false
exam.trader.capital = 1000000
exam.trader.cost = 0.2
exam.plot_summary(strategies,dir)
puts exam.trader.capital
