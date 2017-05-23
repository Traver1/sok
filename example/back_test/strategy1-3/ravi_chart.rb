Bundler.require

soks = Kabu::Company.find_by_code('I201').soks.where('date > ? and date < ?', 
                                                     Date.parse('20120901'),
                                                     Date.parse('20140101')
                                                    )
dates = Kabu::Soks.parse(soks,:date)
values = Kabu::Soks.parse(soks,:open,:high,:low,:close)
closes = values[3]
bols = closes.bol(65)
indices = closes.ravi(7,65)
dates, values, bols, indices = Kabu::Soks.cut_off_tail(dates, values, bols, indices)
up_stick, down_stick = values.split_up_and_down_sticks
line = 1

stick = Kabu::Soks[Kabu::Soks.new,
         Kabu::Soks.new,
         Kabu::Soks.new,
         Kabu::Soks.new]
up_stick.each do
  stick.length.times do |i|
    dates.length.times do 
      stick[i] << Float::NAN
    end
  end
end

indices.each_with_index do |v,i|
  if v < line
    stick.length.times do |j|
      stick[j][i] = up_stick[j][i].finite? ? up_stick[j][i] : down_stick[j][i]
      up_stick[j][i] = Float::NAN
      down_stick[j][i] = Float::NAN
    end
  end
end

dir = File.expand_path '../../../data/strategy1-3/', File.dirname(__FILE__)
FileUtils.mkdir_p dir
file_path = dir + '/I201_2013.jpeg'

Numo.gnuplot do
  set terminal: 'jpeg'
  set output: file_path
  set multiplot: true
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
  plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
    [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
    [dates.x, *stick.y, with: :candlesticks, lt: 3, notitle: true],
    [dates.x, bols[0].y, with: :lines, notitle: true, lc: "'salmon'"],
    [dates.x, bols[1].y, with: :lines, notitle: true, lc: "'salmon'", lt: 0],
    [dates.x, bols[2].y, with: :lines, notitle: true, lc: "'salmon'", lt: 0],
    [dates.x, bols[3].y, axes: :x1y2, with: :lines, notitle: true, lc: "'orange'"]

  unset label: 1
  unset label: 2
  set :bmargin
  set tmargin: 0
  set format: :x
  set xtics: dates.xtics
  set yrange: (0..3)
  set grid: true
  set origin: [0.0, 0.0]
  set size: [1.0, 0.3]
  plot [dates.x, indices.y, with: :lines, notitle: true, lt: 3],
    [dates.x, Array.new(dates.length,line), with: :lines, notitle: true, lt: 8]
  unset multiplot: true
end
