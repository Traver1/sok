Bundler.require
include Numo
include Kabu

sz = 0.01
sa = 1
p_ = 1
count = 200

dir = File.expand_path '../../data/kalman/', File.dirname(__FILE__)
FileUtils.mkdir_p dir
file = dir + '/sample3.jpeg'

f = DFloat.new(p_+1,p_+1).eye

g = DFloat.new(1,1).fill 0

q = DFloat.new(1,1).fill 0

h = DFloat.new(1,p_+1).fill 0

p = DFloat.new(p_+1,p_+1).eye

r = DFloat.new(1,1).fill 0
r[0,0] = sz

x = DFloat.new(p_+1,1).fill(0)

com = Company.find_by_code 'I201'
closes = Soks.parse(com.soks.order(:date).limit(count+10), :close)
logs = closes.log

kalman = Kalman.new 
kalman.ft0 = f
kalman.gt0 = g
kalman.ht0 = h
kalman.qt0 = q
kalman.rt0 = r
kalman.pt1 = p
kalman.xht1 = x

obs = Soks.new
trs = Soks.new
inp = DFloat.new(1,1).fill 0
ut = DFloat.new(1,1).fill 0
x = []
logs.each_cons(p_+1).to_a.each_with_index do |c,i|

  kalman.ht0[0,true] = [1] + c[0..-2]
  inp[0,0] = c[-1]

  out, pt = kalman.observe inp
  obs << inp[0,0]
  trs << out[0]
  x << i
  puts "#{i}\t#{inp[0,0].round(2)}\t#{out[true,0].to_a.join("\t")}"
end

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set output:  file
  set grid: true
  set y2tics: true
  set ytics: :nomirror
  plot [x, obs[40..-1].cumu, with: :lines, title: 'observe', lc: "'salmon'"],
    [x, trs[40..-1], with: :lines, axes: :x1y2, title: 'true', lc: "'blue'", lt: 0]
end

