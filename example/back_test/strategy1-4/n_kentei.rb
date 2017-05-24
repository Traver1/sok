require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

exam = Examination.new
exam.n(CbPbDays, 28) do |soks, env|
  env[:soks] = soks
end
