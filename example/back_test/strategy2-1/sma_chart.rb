class SmaChart

  def plot(record, file_path)
    soks = Sok.joins(:company).where('companies.code = ? and date >= ? and date <= ?',
                                     record.code,
                                     record.from - 80,
                                     record.to + 20).order(:date)
    dates = Soks.parse(soks, :date)
    values =Soks.parse(soks, :open, :high, :low, :close)
    opens = values[0]

    l_ave = values[3].ave(51)
    s_ave = values[3].ave(23)

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

    dates, values, marks, l_ave, s_ave = Soks.cut_off_tail(dates, values,  marks, l_ave, s_ave)
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
        [dates.x, l_ave.y, with: :lines, notitle: true, lc: "'salmon'"],
        [dates.x, s_ave.y, with: :lines, notitle: true, lc: "'salmon'"]
    end
  end
end

