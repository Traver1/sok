class SmaChart

  def initialize
    @all_vidyas = {}
    @all_dates = {}
  end

  def plot(record, file_path)
    soks = Sok.joins(:company).where('companies.code = ? and date >= ? and date <= ?',
                                     record.code,
                                     record.from - 72,
                                     record.to + 20).order(:date)
    dates = Soks.parse(soks, :date)
    values =Soks.parse(soks, :open, :high, :low, :close)
    opens = values[0]

    if @all_vidyas[record.code].nil?
      tmp_value = Sok.joins(:company).where('companies.code = ?', record.code)
      tmp_date, tmp_value = Soks.parse(tmp_value,:date, :close)
      @all_vidyas[record.code] = tmp_value.vidya(39,7,39)
      @all_dates[record.code] = tmp_date[-@all_vidyas[record.code].length..-1]
    end

    index = @all_dates[record.code].index(dates.last)
    vidyas = @all_vidyas[record.code][0..index]

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

    dates, values, marks, vidyas = Soks.cut_off_tail(dates, values, marks, vidyas)
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
        [dates.x, vidyas.y, with: :lines, notitle: true, lc: "'salmon'"]
    end
  end
end
