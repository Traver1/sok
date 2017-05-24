require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
stop_strategy = Sma65Cc3StopLoss.new
base_strategy = Sma65Cc3.new
dir = File.expand_path '../../../data/strategy1-2', File.dirname(__FILE__)
exam.stoploss(stop_strategy, base_strategy, 68, -1.step(-10,-1), dir) do |soks, env|
  env[:closes] = Soks.parse(soks[0..-2], :close)
  env[:open] = soks[-1].open
end
