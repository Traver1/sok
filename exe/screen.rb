Bundler.require
include Kabu

dir = File.expand_path '../data/screen/kama_emb', File.dirname(__FILE__)
FileUtils.mkdir_p dir if not File.exists? dir

path = dir + '/screen'
if  File.exists? path
  screen = Screen.load path
else
  screen = Screen.new
  screen.trader = Trader.new
  screen.trader.capital = 1000000
  screen.trader.percent = false
  screen.trader.off_increse_term = true 
end

puts 'get dates'
dates = Sok.all.group(:date).order(:date).select(:date).map {|s|s.date}
to = dates.last

puts 'get companies'
codes = Sok.joins(:company).where('market=?','T').group(:code).select(:code)

puts 'get previeous status'
profits = codes.map do |com|
  path = dir + '/' + com.code
  if File.exists? path
    kamas, profit = Screen.load path
  else
    kamas, profit = [], 0
  end
  [com.code,profit,kamas]
end
profits.sort!{|a,b|b[1] <=> a[1]}

puts 'screening'
profits.each do |code, profit,kamas|
  strategy = KamaEmbS.new
  strategy.s_len = 4
  strategy.l_len = 30
  strategy.m = 10
  strategy.code = code
  strategy.profit = profit
  strategy.kamas = kamas
  strategy.capital = screen.trader.capital(false)

  path = dir + '/' + code
  from = File.exists?(path) ? dates[-strategy.length*2] : dates.first

  screen.screen from, to, strategy
  Screen.save [strategy.kamas, strategy.profit], path
end

puts 'save screen'
screen.trader.increese_term
path = dir + '/screen'
Screen.save screen, path
