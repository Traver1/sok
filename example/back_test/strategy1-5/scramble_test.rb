Bundler.require
include Kabu

n = 12000
code = 'I201'
com = Company.find_by_code code
file = File.expand_path "../../../data/strategy1-5/chart/#{com.code}.jpeg", File.dirname(__FILE__)
strategy = MoneyManage.new

net_incomes = []
dds = []
wins = []
averages = []
pfs = []
codes = []
trades = []

soks = com.soks

10.times do 

  diffs = Soks.new
  shuffled = Soks.new

  soks.each_cons(2) do |prev,curnt|
    pc = prev.close
    diffs << [curnt.open/pc, curnt.high/pc, curnt.low/pc, curnt.close/pc]
  end

  shuffled << soks[-1]
  (n-1).times do 
    i = Random.rand(soks.length-1)
    pc = shuffled[-1].close
    s = Sok.new
    s.open = diffs[i][0] * pc
    s.high = diffs[i][1] * pc
    s.low = diffs[i][2] * pc
    s.close = diffs[i][3] * pc
    shuffled << s
  end

  trader = Trader.new
  trader.percent = true
  strategy.setup if strategy.respond_to? :setup
  position =nil
  shuffled.each_cons(strategy.length) do |sok|
    env = {}
    env[:code] = code
    env[:date] = sok[-1].date
    env[:position] = position
    strategy.set_env(Soks[*sok.to_a],env)
    action = strategy.decide(env)
    trader.receive [action]
    position = trader.positions.any? ? trader.positions[0] : nil
  end
  r = trader.records
  net_incomes << Record.net_income(r)
  dds << Record.max_drow_down(r)
  wins << Record.win_rate(r) * 100
  averages << Record.average(r)
  pfs << Record.profit_factor(r)
  trades << Record.trades(r)
  trader.summary
end

10.times.to_a.zip(net_incomes,trades,wins,pfs,averages,dds).each do |array|
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
