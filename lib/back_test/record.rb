module Kabu
  class Record
    attr_accessor :code, :profit, :term, :volume, :from, :to, :position, :max, :min

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
      los = Record.loss(records).abs
      los > 0 ? Record.profit(records) / los : 0
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

    def self.average(records)
      if records.length > 0 
        self.net_income(records) / records.length
      else
        0
      end
    end

    def self.average_profit(records)
      w = self.wins(records)
      w > 0 ?
        self.profit(records) / w :
        0
    end

    def self.average_loss(records)
      l = self.looses(records)
      l > 0 ?
      self.loss(records) / l :
      0
    end

    def self.average_posess_term_of_win(records)
      s = records.inject(0) do |sum,record|
        sum += record.profit > 0 ? record.term : 0
      end
      w = self.wins(records)
      w > 0 ?  s / w : 0
    end

    def self.average_posess_term_of_loose(records)
      s = records.inject(0) do |sum,record|
        sum += record.profit <= 0 ? record.term : 0
      end 
      l = self.looses(records)
      l > 0 ? s / l : 0
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
      Record.histgram profits, grid_size
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

    def self.best_latent_gain_in_loose(records, grid_size=10)
      latent_gain = records.select{|r| r.profit <= 0}.map{|r|r.max}
      Record.histgram(latent_gain, grid_size)
    end

    def self.worst_latent_gain_in_win(records, grid_size=10)
      latent_gain = records.select{|r| r.profit > 0}.map{|r|r.min}
      Record.histgram(latent_gain, grid_size)
    end

    def self.histgram(array,grid_size)
      max = array.max
      min = array.min
      step = (max-min)/grid_size
      histgram = Soks.new
      grid_size.times { |i| histgram[i] = Float::NAN}
      array.each do |p|
        grid = ((p - min)/step).to_i
        grid -= 1 if p == max
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
  end
end
