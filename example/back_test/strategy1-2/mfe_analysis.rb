require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = Sma65Cc3.new
dir = File.expand_path '../../../data/strategy1-2', File.dirname(__FILE__)
exam.mfe(strategy, 68, dir) do |soks, env|
  env[:closes] = Soks.parse(soks[0..-2],:close)
  env[:open] = soks[-1].open
end 
