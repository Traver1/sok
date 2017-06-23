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

puts 'screening'
codes.each do |com|
  strategy = KnifeS.new
  strategy.code = com.code
  from = dates[-strategy.length*2]
  screen.screen from, to, strategy
end

puts 'save screen'
screen.trader.increese_term
path = dir + '/screen'
Screen.save screen, path
