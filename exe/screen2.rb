Bundler.require
include Kabu

dir = File.expand_path '../data/screen/hv_adx_pb', File.dirname(__FILE__)
FileUtils.mkdir_p dir if not File.exists? dir

screen = Screen.new
screen.trader = Trader.new
screen.trader.capital = 1000000
screen.trader.percent = false
screen.trader.off_increse_term = true 

puts 'get dates'
dates = Sok.all.group(:date).order(:date).select(:date).map {|s|s.date}
to = dates.last

puts 'get companies'
codes = Sok.joins(:company).where('market=?','T').group(:code).select(:code)

puts 'get previeous status'
profits = codes.map do |com|
  path = dir + '/' + com.code
  if File.exists? path
    profit = Screen.load path
  else
    profit =  0
  end
  [com.code,profit]
end
profits.sort!{|a,b|b[1] <=> a[1]}

puts 'screening'
profits.each do |code, profit|
  strategy = HvAdxPb.new
  strategy.code = code
  strategy.profit = profit

  from = dates[-strategy.length*2]

  screen.screen from, to, strategy
  path = dir + '/' + code
  Screen.save [strategy.profit], path
end

puts 'save screen'
screen.trader.increese_term
path = dir + '/screen'
Screen.save screen, path
