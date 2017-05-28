Bundler.require
include Kabu

n = 3000
com = Company.find_by_code 'I201'
file = File.expand_path "../../../data/strategy1-5/chart/#{com.code}.jpeg", File.dirname(__FILE__)

soks = com.soks
diffs = Soks.new
shuffled = Soks.new

soks.each_cons(2) do |prev,curnt|
  pc = prev.close
  diffs << [curnt.open/pc, curnt.high/pc, curnt.low/pc, curnt.close/pc]
end

shuffled << soks[-1]
(n-1).times do 
  i = Random.rand(soks.length-1)
  pc = shuffled[-1].close
  s = Sok.new
  s.open = diffs[i][0] * pc
  s.high = diffs[i][1] * pc
  s.low = diffs[i][2] * pc
  s.close = diffs[i][3] * pc
  shuffled << s
end

values = Kabu::Soks.parse(shuffled,:open,:high,:low,:close)
up_stick, down_stick = values.split_up_and_down_sticks

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set output:  file
  set grid: true
  plot [n.times.to_a, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
    [n.times.to_a, *down_stick.y, with: :candlesticks, lt: 7, notitle: true]
end
