Bundler.require

soks = Kabu::Company.find_by_code(1305).soks
dates = Kabu::Soks.parse(soks,:date)
values = Kabu::Soks.parse(soks,:open,:high,:low,:close)
closes = values[3]
bols = closes.bol(25)
dates, values, bols = Kabu::Soks.adjust_length(dates, values, bols)

Numo.gnuplot do
  set terminal: 'jpeg'
  set output:  'sample3.jpeg'
  set title: "Demo of plotting financial data"
  set yrange: bols[1..2].yrange
  set xtics: dates.xtics
  set lmargin: 9
  set rmargin: 2
  set grid: true
  plot [dates.x, *values.y, with: :financebars, lt: 8, notitle: true],
    [dates.x, bols[0].y, with: :lines, notitle: true, lc: "'blue'"],
    [dates.x, bols[1].y, with: :lines, notitle: true, lc: "'blue'", lt: 0],
    [dates.x, bols[2].y, with: :lines, notitle: true, lc: "'blue'", lt: 0],
    [dates.x, bols[3].y, axes: :x1y2, with: :lines, notitle: true, lc: "'orange'"]
end

