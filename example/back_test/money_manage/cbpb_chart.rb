class CbPbBiDirectionChart

  def plot(record, file_path)
    soks = Sok.joins(:company).where('companies.code = ? and date >= ? and date <= ?',
                                     record.code,
                                     record.from - 50,
                                     record.to + 20).order(:date)
    dates = Soks.parse(soks, :date)
    values =Soks.parse(soks, :open, :high, :low, :close)
    opens = values[0]
    high = Soks[*soks].high(25)
    low = Soks[*soks].low(25)
    ave, btm, upr, dev = values[3].bol(25)
    bol = Soks[*bol]

    marks = Soks.new
    dates.zip(opens).each do |date, open|
      marks << case date
      when record.from, record.to
        open
      else
        Float::NAN
      end
    end

    case record.position
    when :buy
      mark_point = '9'
    when :sell
      mark_point = '11'
    end

    dates, values, marks, ave, btm, upr, dev = Soks.cut_off_tail(dates, values,  marks, ave, btm, upr, dev)
    up_stick, down_stick = values.split_up_and_down_sticks

    Numo.gnuplot do
      reset
      set terminal: 'jpeg'
      set output:  file_path
      set yrange: values.yrange
      set y2tics: true
      set ytics: :nomirror
      set xtics: dates.xtics
      set grid: true
      plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
        [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
        [dates.x, marks.y, with: :points, notitle: true, pt: mark_point, ps: 2, lc: "'dark-green'"],
        [dates.x, ave.y, with: :lines, notitle: true, lc: "'salmon'"],
        [dates.x, btm.y, with: :lines, notitle: true, lc: "'salmon'"],
        [dates.x, upr.y, with: :lines, notitle: true, lc: "'salmon'"],
        [dates.x, dev.y, with: :lines, axes: :x1y2, notitle: true, lc: "'orange'"]
    end
  end
end
