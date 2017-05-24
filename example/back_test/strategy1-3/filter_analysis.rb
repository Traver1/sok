require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
strategy = Sma65Cc3Ravi.new(0.5)
exam.deviation(69, strategy) do |soks, env|
  env[:closes] = Soks.parse(soks[0..-2], :close)
  env[:open] = soks[-1].open
end
