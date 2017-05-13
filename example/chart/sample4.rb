Bundler.require

soks = Kabu::Company.find_by_code(1305).soks
dates = Kabu::Soks.parse(soks,:date)
values = Kabu::Soks.parse(soks,:open,:high,:low,:close)
volumes = Kabu::Soks.parse(soks,:volume)
v_aves = volumes.ave(25)
closes = values[3]
bols = closes.bol(25)
dates, values, bols, v_aves = Kabu::Soks.adjust_length(dates, values, bols, v_aves)

Numo.gnuplot do
  set terminal: 'jpeg'
  set output:  'sample4.jpeg'
  set multiplot: true
  set label: "Bolinger Band", at: [0.01, 0.03]
  set label: "http://gnuplot.sourceforge.net/demo/finance.html", at: [0.01, 0.07]
  set yrange: (values+bols[1..2]).yrange
  set lmargin: 8
  set rmargin: 2
  set bmargin: 0
  set xtics: dates.xtics(visible: false)
  set format_x: ""
  set grid: true
  set grid: true
  set origin: [0.0, 0.3]
  set size: [1.0, 0.7]
  plot [dates.x, *values.y, with: :financebars, lt: 8, notitle: true],
    [dates.x, bols[0].y, with: :lines, notitle: true, lc: "'blue'"],
    [dates.x, bols[1].y, with: :lines, notitle: true, lc: "'blue'", lt: 0],
    [dates.x, bols[2].y, with: :lines, notitle: true, lc: "'blue'", lt: 0],
    [dates.x, bols[3].y, axes: :x1y2, with: :lines, notitle: true, lc: "'orange'"]

  unset label: 1
  unset label: 2
  set :bmargin
  set tmargin: 0
  set format: :x
  set xtics: dates.xtics
  set ytics: volumes.ytics(count: 2)
  set grid: true
  set origin: [0.0, 0.0]
  set size: [1.0, 0.3]
  set yrange: volumes.yrange
  plot [dates.x, volumes.y, with: :impulses, notitle: true, lt: 3, lc: "'green'"],
    [dates.x, v_aves.y, with: :lines, notitle: true, lt: 3 ]
  unset multiplot: true
end


