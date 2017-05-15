module Kabu
  class Chart

    class ProfitCurve < Chart

      def plot(records, file_path)
        cumus = Soks[*Record.cumu_profit(records)]
        dates = Soks[*records.map{|r| r.to}]
        Numo.gnuplot do
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

        count = 10
        step = x.length / count
        step = 1 if step == 0
        xlabels = []
        x.each_with_index do |label,i|
          xlabels << "\"#{label.round(0)}\" #{i}" if i % step == 0
        end
        xtics = "(#{xlabels.join(',')})"

        Numo.gnuplot do
          set terminal: 'jpeg'
          set output:  file_path
          set yrange: histgram.yrange
          set logscale: :y
          set lmargin: 8
          set rmargin: 2
          set bmargin: true
          set xtics: xtics
          set grid: true
          plot [grid_size.times.to_a, histgram.y, with: :impulse, lt: 8, notitle: true]
          unset logscale: :y
        end
      end
    end

    class MonthlyProfit < Chart

      def plot(records, file_path)
        months, sums = Record.monthly_profit(records)

        count = 5
        step = months.length / count
        step = 1 if step == 0
        xlabels = []
        months.each_with_index do |month,i|
          xlabels << "\"#{month}\" #{i}" if i % step == 0
        end
        xtics = "(#{xlabels.join(',')})"

        Numo.gnuplot do
          set terminal: 'jpeg'
          set output:  file_path
          set yrange: sums.yrange
          set lmargin: 8
          set rmargin: 2
          set bmargin: true
          set xtics: xtics
          set grid: true
          plot [months.length.times.to_a, sums.y, with: :impulse, lt: 8, notitle: true]
        end
      end
    end
  end
end
