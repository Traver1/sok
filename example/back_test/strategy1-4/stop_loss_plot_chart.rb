require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

object = nil
dir = File.expand_path '../../../data/strategy1-4', File.dirname(__FILE__)
File.open(dir + '/stop_loss_analysis_dump_data', 'rb') do |file|
  object = Marshal.load(file)
end

net_incomes = object[0]
drow_downs = object[1]
wins = object[2]
averages = object[3]

y1 = net_incomes.map {|array| Soks[*array].ave(array.length)}.flatten
y2 = drow_downs.map {|array| Soks[*array].ave(array.length)}.flatten

x = -1.step(-11,-1).to_a

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set ytics: :nomirror
  set :y2tics
  set output:  dir + '/net_income_and_drow_doon.jpeg'
  set title: "net income, drow down"
  set ylabel: "average net income(%)"
  set y2label: "average max drow down(%)"
  set xrange: (-12..0)
  set xlabel: "stop loss line(%)"
  set grid: true
  plot [x, y1, with: :lines, title: "'net income'"],
    [x, y2, axes: :x1y2, with: :lines, title: "'drow down'", lc: "'blue'"]
end

y2 = net_incomes.map {|array| Soks[*array].dev(array.length)}.flatten

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set output:  dir + '/net_income_and_deviation.jpeg'
  set title: "deviation"
  set ylabel: "deviation(%)"
  set xlabel: "stop loss line(%)"
  set grid: true
  plot [x, y2, with: :lines, title: "'deviation'", lc: "'blue'"]
end

y2 = wins.map {|array| Soks[*array].ave(array.length)}.flatten

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set output:  dir + '/net_income_and_wins.jpeg'
  set title: "wins"
  set ylabel: "wins"
  set xlabel: "stop loss line(%)"
  set grid: true
  plot [x, y2, with: :lines, title: "'wins'", lc: "'blue'"]
end

y2 = averages.map {|array| Soks[*array].ave(array.length)}.flatten

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set output:  dir + '/net_income_and_averages.jpeg'
  set title: "averages"
  set ylabel: "average"
  set xlabel: "stop loss line(%)"
  set grid: true
  plot [x, y2, with: :lines, title: "'wins'", lc: "'blue'"]
end
