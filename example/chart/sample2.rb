Bundler.require


soks = Kabu::Company.find_by_code(1305).soks
dates = Kabu::Soks.parse(soks,:date)
values = Kabu::Soks.parse(soks,:open,:high,:low,:close)

Numo.gnuplot do
  set terminal: 'jpeg'
  set output:  'sample2.jpeg'
  set title: "Demo of plotting financial data"
  set yrange: values.yrange
  set xtics: dates.xtics
  set lmargin: 9
  set rmargin: 2
  plot dates.x, *values.y, with: :financebars, lt: 8, notitle: true
end



