Bundler.require
include Kabu

n = 21000
code = 'I202'
strategy = PatternStrategy.new

ex = Examination.new
ex.scramble(strategy, code, n)
