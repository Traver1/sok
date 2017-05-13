Bundler.require

soks = Kabu::Company.find_by_code(1305).soks
dates, closes = Kabu::Soks.parse(soks, :date, :close)

Numo.gnuplot do
  set terminal: 'jpeg'
  set output:  'sample1.jpeg'
  set title: "Demo of plotting financial data"
  set yrange: closes.yrange
  set xtics: dates.xtics
  set lmargin: 9
  set rmargin: 2
  set grid: true
  plot dates.x, closes.y, with: :lines, notitle: true
end
