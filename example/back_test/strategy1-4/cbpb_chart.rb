class CbPb

  def plot(record, file_path)
    soks = Sok.joins(:company).where('companies.code = ? and date >= ? and date <= ?',
                                     record.code,
                                     record.from - 40,
                                     record.to + 20).order(:date)
    dates = Soks.parse(soks, :date)
    values =Soks.parse(soks, :open, :high, :low, :close)
    opens = values[0]
    high = Soks[*soks].high(20)
    low = Soks[*soks].low(5)

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

    dates, values, marks, high, low = Soks.cut_off_tail(dates, values,  marks, high, low)
    up_stick, down_stick = values.split_up_and_down_sticks

    Numo.gnuplot do
      reset
      set terminal: 'jpeg'
      set output:  file_path
      set yrange: values.yrange
      set xtics: dates.xtics
      set grid: true
      plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
        [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
        [dates.x, marks.y, with: :points, notitle: true, pt: mark_point, ps: 2, lc: "'dark-green'"],
        [dates.x, high.y, with: :lines, notitle: true, lc: "'salmon'"],
        [dates.x, low.y, with: :lines, notitle: true, lc: "'salmon'"]
    end
  end
end

