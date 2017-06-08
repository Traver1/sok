Bundler.require
include Numo
include Kabu

sa = 1
sz = 50
alpha = 0.1
count = 200

dir = File.expand_path '../../data/kalman/', File.dirname(__FILE__)
FileUtils.mkdir_p dir
file = dir + '/sample2.jpeg'

f = DFloat.new(1,1).fill 0
f[0,0] = 1

g = DFloat.new(1,1).fill 0
g[0,0] = 1

q = DFloat.new(1,1).fill 0
q[0,0] = sa

h = DFloat.new(1,1).fill 0
h[0,0] = 1

r = DFloat.new(1,1).fill 0
r[0,0] = sz


com = Company.find_by_code 'I201'
closes = Soks.parse(com.soks.order(:date).limit(count+10), :close)

kalman = Kalman.new 
kalman.ft0 = f
kalman.gt0 = g
kalman.qt0 = q
kalman.ht0 = h
kalman.rt0 = r

kalman.pt1 = DFloat.new(1,1).fill closes[0..10].dev(11)[-1]
kalman.xht1 = DFloat.new(1,1).fill closes[10]

obs = []
trs = []
inp = DFloat.new(1,1).fill 0
ut = DFloat.new(1,1).fill 0
x = []
closes[11..-1].each_with_index do |c,i|
  inp[0,0] = c
  ut[0,0] = alpha * (c - closes[i-1])
  out, p = kalman.observe inp, ut
  obs << inp[0,0]
  trs << out[0,0]
  x << i
  puts "#{i}\t#{inp[0,0].round(2)}\t#{out[0,0].round(2)}"
end

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set output:  file
  set grid: true
  plot [x, obs, with: :lines, title: 'observe', lc: "'salmon'"],
    [x, trs, with: :lines, title: 'true', lc: "'blue'", lt: 0]
end

