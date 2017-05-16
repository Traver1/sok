module Kabu
  class Record
    attr_accessor :code, :profit, :term, :volume, :from, :to, :position

    def initialize(code, profit, term, volume, from, to, position)
      @code = code
      @profit = profit
      @term = term
      @volume = volume
      @from = from
      @to = to
      @position = position
    end

    def self.net_income(records)
      records.inject(0) do |sum,record|
        sum += record.profit
      end
    end

    def self.profit(records)
      records.inject(0) do |sum,record|
        sum += record.profit >  0 ? record.profit : 0
      end
    end

    def self.loss(records)
      records.inject(0) do |sum,record|
        sum += record.profit <= 0 ? record.profit : 0
      end
    end

    def self.profit_factor(records)
      Record.profit(records) / Record.loss(records).abs
    end

    def self.max_profit(records)
      records.inject(0) do |max,record|
        [max, record.profit].max
      end
    end

    def self.max_loss(records)
      records.inject(0) do |min,record|
        [min, record.profit].min
      end
    end

    def self.trades(records)
      records.length
    end

    def self.wins(records)
      records.inject(0) do |sum,record|
        sum += record.profit > 0 ? 1 : 0
      end
    end

    def self.looses(records)
      records.inject(0) do |sum,record|
        sum += record.profit <= 0 ? 1 : 0
      end
    end

    def self.win_rate(records)
      Record.wins(records).to_f / Record.trades(records)
    end

    def self.max_series_of_wins(records)
      prev = records[0].profit
      max, count = 0,1
      records[1..-1].each do |record|
        if prev > 0 and record.profit > 0
          count += 1
        else
          count = 1
        end
        max = [count, max].max
        prev = record.profit
      end
      max
    end

    def self.max_series_of_looses(records)
      prev = records[0].profit
      max, count = 0,1
      records[1..-1].each do |record|
        if prev <= 0 and record.profit <= 0
          count += 1
        else
          count = 1
        end
        max = [count, max].max
        prev = record.profit
      end
      max
    end

    def self.average_posess_term_of_win(records)
      records.inject(0) do |sum,record|
        sum += record.profit > 0 ? record.term : 0
      end / self.wins(records)
    end

    def self.average_posess_term_of_loose(records)
      records.inject(0) do |sum,record|
        sum += record.profit <= 0 ? record.term : 0
      end / self.looses(records)
    end

    def self.max_drow_down(records)
      min, sum = 0,0
      records.each do |record|
        if record.profit > 0
          sum = 0
        else
          sum += record.profit
        end
        min = [sum, min].min
      end
      min
    end

    def self.cumu_profit(records)
      sum = 0
      Soks[*records].map do |record|
        sum += record.profit
      end
    end


    def self.profit_histgram(records, grid_size=20)
      profits = records.map{|r| r.profit}
      max = profits.max
      min = profits.min
      step = (max-min)/grid_size
      histgram = Soks.new
      grid_size.times { |i| histgram[i] = Float::NAN}
      profits.each do |p|
        if p.positive?
          grid = ((p - min -  step * 0.1)/step).to_i
        else
          grid = ((p - min +  step * 0.1)/step).to_i
        end
        if histgram[grid].is_a?(Float) and histgram[grid].nan?
          histgram[grid] = 0 
        end
        histgram[grid] += 1
      end
      x = Soks.new
      grid_size.times do |i|
        x << i*step + min
      end
      [x,histgram]
    end

    def self.monthly_profit(records)
      sums = Soks.new
      months = []
      records.group_by do |r| 
        r.to.strftime('%Y-%m')
      end.each do |month, recs|
        months << month
        sums << recs.inject(0) {|sum, r| sum += r.profit}
      end
      [months, sums]
    end
  end
end
