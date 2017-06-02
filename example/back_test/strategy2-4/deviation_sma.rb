require './config.rb'
strategy = Sma.new
strategy.s_len = 1
strategy.l_len = 39
@exam.deviation(strategy)
