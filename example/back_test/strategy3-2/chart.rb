class SmaChart

  def initialize
  end

  def plot(record, file_path)
    soks = Sok.joins(:company).where('companies.code = ?  and date <= ?',
                                     record.code,
                                     record.to + 20).order(:date).last(record.term + 40)
    dates = Soks.parse(soks, :date)
    values =Soks.parse(soks, :open, :high, :low, :close)
    opens = values[0]
    aves = values[3].ave(3)
    rsis = values[3].rsi(2)

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

    dates, values, marks, aves, rsis = Soks.cut_off_tail(dates, values, marks, aves, rsis)
    up_stick, down_stick = values.split_up_and_down_sticks

    Numo.gnuplot do
      reset
      set terminal: 'jpeg'
      set output:  file_path
      set yrange: values.yrange
      set xtics: dates.xtics
      set y2tics: true
      set ytics: :nomirror
      set y2range: (0..200)
      set grid: true
      plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
        [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
        [dates.x, marks.y, with: :points, notitle: true, pt: mark_point, ps: 2, lc: "'dark-green'"],
        [dates.x, aves.y, with: :lines, notitle: true, lc: "'salmon'"],
        [dates.x, rsis.y, with: :lines, axes: :x1y2, notitle: true, lc: "'orange'"]
    end
  end
end
