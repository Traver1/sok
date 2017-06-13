Bundler.require
include Kabu

n = 12000
code = 'I201'
com = Company.find_by_code code
strategy = KamaEmb.new
strategy.m = 10
strategy.s_len = 4
strategy.l_len = 30

ex = Examination.new
ex.scramble(strategy, code, n)
