Bundler.require
include Kabu

dir = File.expand_path '../data/screen', File.dirname(__FILE__)
FileUtils.mkdir_p dir if not File.exists? dir

path = dir + '/screen'
if not File.exists? path
  screen = Screen.new
  screen.trader = Trader.new
  screen.trader.capital = 10000000
  screen.trader.percent = false
  screen.strategies = []
  Sok.joins(:company).where('market=?','T').group(:code).select(:code).each do |com|
    screen.strategies << KamaEmbS.new
    screen.strategies.last.code = com.code
    screen.strategies.last.s_len = 4
    screen.strategies.last.l_len = 30
    screen.strategies.last.m = 10
  end
else
  screen = Screen.load path
end

screen.screen

STDOUT.puts 'save dump? y/n'
if STDIN.gets.chomp == 'y'
  Screen.save screen, path
end
