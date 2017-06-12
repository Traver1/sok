class SmaChart

  def initialize
  end

  def plot(record, file_path)
    soks = Sok.joins(:company).where('companies.code = ?  and date <= ?',
                                     record.code,
                                     record.to + 30).order(:date).last(record.term + 80)
    dates = Soks.parse(soks, :date)
    values =Soks.parse(soks, :open, :high, :low, :close)
    opens = values[0]

    s_ave, s_btm, s_top, s_dev = values[3].bol(25)
    l_ave, l_btm, l_top, l_dev = values[3].bol(50)

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

    dates, values, marks, s_ave, s_btm, s_top, s_dev, l_ave, l_btm, l_top, l_dev =
      Soks.cut_off_tail(dates, values, marks, s_ave, s_btm, s_top, s_dev, l_ave, l_btm, l_top, l_dev)
    up_stick, down_stick = values.split_up_and_down_sticks

    Numo.gnuplot do
      reset
      set terminal: 'jpeg'
      set output:  file_path
      set yrange: values.yrange
      set xtics: dates.xtics
      set ytics: :nomirror
      set y2tics: true
      set grid: true
      plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
        [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
        [dates.x, marks.y, with: :points, notitle: true, pt: mark_point, ps: 2, lc: "'dark-green'"],
        [dates.x, s_ave.y, with: :lines, notitle: true, lc: "'blue'"], 
        [dates.x, s_btm.y, with: :lines, notitle: true, lc: "'blue'"],
        [dates.x, s_top.y, with: :lines, notitle: true, lc: "'blue'"], 
        [dates.x, l_ave.y, with: :lines, notitle: true, lc: "'red'"],
        [dates.x, l_btm.y, with: :lines, notitle: true, lc: "'red'"], 
        [dates.x, l_top.y, with: :lines, notitle: true, lc: "'red'"]
    end
  end
end
