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

    if @all_vidyas.nil?
      tmp_value = Sok.joins(:company).where('companies.code = ?', record.code)
      tmp_date, tmp_value, tmp_high, tmp_low = Soks.parse(tmp_value,:date, :close, :high, :low)
      @s_ave = tmp_value.exp_ave(0.5)
      @l_ave = tmp_value.exp_ave(0.05)
      @all_dates = tmp_date[-@l_ave.length..-1]
    end

    index = @all_dates.index(dates.last)
    s_ave = @s_ave[0..index]
    l_ave = @l_ave[0..index]

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

    dates, values, marks, s_ave, l_ave= Soks.cut_off_tail(dates, values, marks, s_ave, l_ave)
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
        [dates.x, l_ave.y, with: :lines, notitle: true, lc: "'red'"]
    end
  end
end
