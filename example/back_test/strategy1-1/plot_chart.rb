require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

companies = Company.where('code like ?', 'I2%').order(:code).select(:code)
FileUtils.mkdir_p File.expand_path "../../../data/strategy1-1/chart", File.dirname(__FILE__)

companies.each do |company|
  soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
  
  dates = Kabu::Soks.parse(soks,:date)
  values = Kabu::Soks.parse(soks,:open,:high,:low,:close)
  closes = values[3]
  bols = closes.bol(65)
  dates, values, bols = Kabu::Soks.adjust_length(dates, values, bols)
  up_stick, down_stick = values.split_up_and_down_sticks

  file = File.expand_path "../../../data/strategy1-1/chart/#{company.code}.jpeg", File.dirname(__FILE__)

  Numo.gnuplot do
    reset
    set terminal: 'jpeg'
    set output:  file
    set yrange: (values+bols[1..2]).yrange
    set lmargin: 8
    set rmargin: 2
    set bmargin: true
    set xtics: dates.xtics(visible: false)
    set grid: true
    set grid: true
    plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
      [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
      [dates.x, bols[0].y, with: :lines, notitle: true, lc: "'salmon'"],
      [dates.x, bols[1].y, with: :lines, notitle: true, lc: "'salmon'", lt: 0],
      [dates.x, bols[2].y, with: :lines, notitle: true, lc: "'salmon'", lt: 0],
      [dates.x, bols[3].y, axes: :x1y2, with: :lines, notitle: true, lc: "'orange'"]
  end
end


