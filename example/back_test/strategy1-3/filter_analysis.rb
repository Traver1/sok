require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

net_incomes = []
dds = []
wins = []
averages = []
pfs = []
codes = []
trades = []

companies = Company.where('code like ?', 'I2%').order(:code).select(:code)

companies.each do |company|
  codes << company.code
  trader = Trader.new
  trader.percent = true
  #strategy = Sma65Cc3Ravi.new(0.5)
  strategy = Sma65Cc3.new
  position =nil
  soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
  soks.each_cons(69) do |sok|
    closes = Soks.parse(sok[0..-2],:close)
    action = strategy.decide(code: company.code, date: sok[-1].date, 
                      closes: closes, open: sok[-1].open, position: position)
    trader.receive [action]
    position = trader.positions.any? ? trader.positions[0] : nil
  end

  trader.summary
  r = trader.records
  net_incomes << Record.net_income(r)
  dds << Record.max_drow_down(r)
  wins << Record.win_rate(r) * 100
  averages << Record.average(r)
  pfs << Record.profit_factor(r)
  trades << Record.trades(r)
end

codes.zip(net_incomes,trades,wins,pfs,averages,dds).each do |array|
  puts "|#{array.map{|v| (v.is_a? Float) ? v.round(2) : v}.join("|")}|"
end

indecis = [net_incomes, trades, wins, pfs,averages, dds].map do |vs|
  (vs.inject(0){|r,v| r+= v}/vs.length).round(1)
end 
puts "|#{["    ", indecis].flatten.join("|")}|"

indecis = [net_incomes, trades, wins, pfs,averages, dds].map do |vs|
  ave = vs.inject(0){|r,v| r+= v}/vs.length
  (Math.sqrt(vs.inject(0){|r,v|r+=(v-ave)**2}/vs.length)).round(2)
end 
puts "|#{["    ", indecis].flatten.join("|")}|"
