Bundler.require
include Numo

sa = 0.1
sz = 0.1
dt = 0.01

dir = File.expand_path '../../data/kalman/', File.dirname(__FILE__)
FileUtils.mkdir_p dir
file = dir + '/sample1.jpeg'

f = DFloat.new(2,2).fill 0
f[0,true] = [1, dt]
f[1,true] = [0, 1]

g = DFloat.new(2,1).fill 0
g[0,0] = dt**2 / 2
g[1,0] = dt

q = DFloat.new(2,1).fill 0
q[0,0] = sa
q[1,0] = sa

h = DFloat.new(1,2).fill 0
h[0,true] = [1,0]

r = DFloat.new(1,1).fill 0
r[0,0] = sz


kalman = Kalman.new 
kalman.ft0 = f
kalman.gt0 = g
kalman.qt0 = q
kalman.ht0 = h
kalman.rt0 = r

kalman.pt1 = DFloat.new(2,2).fill 0
kalman.xht1 = DFloat.new(2,1).fill 0

obs = []
trs = []
inp = DFloat.new(1,1).fill 0
x = []
1000.times do |i|
  inp[0,0] = Random.rand
  out, p = kalman.observe inp
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

