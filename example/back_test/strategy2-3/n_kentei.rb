Bundler.require
include Kabu

exam = Examination.new
strategy = KamaEmbN.new
strategy.s_len = 4
strategy.l_len = 30
strategy.m = 10
exam.n(strategy) 
