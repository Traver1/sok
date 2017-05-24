module Kabu
  class Chart

    class RecordedChart < Chart

      def plot(record, file_path)
        soks = Sok.joins(:company).where('companies.code = ? and date >= ? and date <= ?',
                                         record.code,
                                         record.from - 50,
                                         record.to + 20).order(:date)
        dates = Soks.parse(soks, :date)
        values =Soks.parse(soks, :open, :high, :low, :close)
        volumes = Soks.parse(soks, :volume)
        closes = values[3]
        bols = closes.bol(12)
        v_aves = volumes.ave(12)

        marks = Soks.new
        dates.zip(closes).each do |date, close|
          marks << case date
          when record.from, record.to
            close
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

        dates, values, volumes, bols, marks, v_aves = Soks.cut_off_tail(
          dates, values, volumes, bols, marks, v_aves)
        up_stick, down_stick = values.split_up_and_down_sticks

        Numo.gnuplot do
          reset
          set terminal: 'jpeg'
          set output:  file_path
          set multiplot: true
          set yrange: (values+bols[1..2]).yrange
          set lmargin: 8
          set rmargin: 2
          set bmargin: 0
          set xtics: dates.xtics(visible: false)
          set format_x: ""
          set grid: true
          set origin: [0.0, 0.3]
          set size: [1.0, 0.7]
          plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
            [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
            [dates.x, marks.y, with: :points, notitle: true, pt: mark_point, ps: 2, lc: "'dark-green'"],
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
          set ytics: volumes.ytics(count: 2)
          set grid: true
          set origin: [0.0, 0.0]
          set size: [1.0, 0.3]
          set yrange: volumes.yrange
          plot [dates.x, volumes.y, with: :impulses, notitle: true, lt: 3, lc: "'green'"], 
            [dates.x, v_aves.y, with: :lines, notitle: true, lt: 3 ]
          unset multiplot: true
        end
      end
    end

    class ProfitCurve < Chart

      def plot(records, file_path)
        cumus = Soks[*Record.cumu_profit(records)]
        dates = Soks[*records.map{|r| r.to}]
        Numo.gnuplot do
          reset
          set terminal: 'jpeg'
          set output:  file_path
          set yrange: cumus.yrange
          set lmargin: 8
          set rmargin: 2
          set bmargin: true
          set xtics: dates.xtics
          set grid: true
          plot [dates.x, cumus.y, with: :lines, lt: 8, notitle: true]
        end
      end
    end

    class ProfitHistgram < Chart
      
      def plot(records, file_path)
        grid_size = 20
        x,histgram = Record.profit_histgram(records, grid_size)

        count = [10, records.length].min
        step = x.length / count
        step = 1 if step == 0
        xlabels = []
        x.each_with_index do |label,i|
          xlabels << "\"#{label.round(0)}\" #{i}" if i % step == 0
        end
        xtics = "(#{xlabels.join(',')})"

        Numo.gnuplot do
          reset
          set style: :fill, solid: :border, lc: "'black'"
          set terminal: 'jpeg'
          set output:  file_path
          set yrange: histgram.yrange
          set logscale: :y
          set lmargin: 8
          set rmargin: 2
          set bmargin: true
          set xtics: xtics
          set grid: true
          plot [grid_size.times.to_a, histgram.y, with: :boxes, lw: 2, lc: "'light-cyan'", notitle: true]
          unset logscale: :y
        end
      end
    end

    class MonthlyProfit < Chart

      def plot(records, file_path)
        months, sums = Record.monthly_profit(records)

        count = [5, records.length].min
        step = months.length / count
        step = 1 if step == 0
        xlabels = []
        months.each_with_index do |month,i|
          xlabels << "\"#{month}\" #{i}" if i % step == 0
        end
        xtics = "(#{xlabels.join(',')})"

        Numo.gnuplot do
          reset
          set style: :fill, solid: :border, lc: "'black'"
          set boxwidth: 0.7, relative: true
          set terminal: 'jpeg'
          set output:  file_path
          set yrange: sums.yrange
          set lmargin: 8
          set rmargin: 2
          set bmargin: true
          set xtics: xtics
          set grid: true
          plot [months.length.times.to_a, sums.y, with: :boxes, lw: 2, lc: "'light-cyan'", notitle: true]
        end
      end
    end

    class Histgram < Chart

      def plot(x, histgram, file_path)
        count = [10, histgram.length].min
        step = x.length / count
        step = 1 if step == 0
        xlabels = []
        x.each_with_index do |label,i|
          xlabels << "\"#{label.round(0)}\" #{i}" if i % step == 0
        end
        xtics = "(#{xlabels.join(',')})"

        Numo.gnuplot do
          reset
          set style: :fill, solid: :border, lc: "'black'"
          set terminal: 'jpeg'
          set output:  file_path
          set yrange: histgram.yrange
          set logscale: :y
          set lmargin: 8
          set rmargin: 2
          set bmargin: true
          set xtics: xtics
          set grid: true
          plot [x.length.times.to_a, histgram.y, with: :boxes, lw: 2, lc: "'light-cyan'", notitle: true]
          unset logscale: :y
        end
      end
    end

    class Cumu < Chart
      def plot(x, y, file_path)
        count = [10, x.length].min
        step = x.length / count
        step = 1 if step == 0
        xlabels = []
        x.each_with_index do |label,i|
          xlabels << "\"#{label.round(1)}\" #{i}" if i % step == 0
        end
        xtics = "(#{xlabels.join(',')})"

        Numo.gnuplot do
          reset
          set terminal: 'jpeg'
          set output:  file_path
          set yrange: (0..100)
          set ytics: '(0,10,20, 50, 80, 90, 100)'
          set lmargin: 8
          set rmargin: 2
          set bmargin: true
          set xtics: xtics
          set grid: true
          plot [x.length.times.to_a, y.y, with: :lines, lt: 1, lc: "'black'", notitle: true]
          unset logscale: :y
        end
      end
    end
  end
end
