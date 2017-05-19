module Kabu
  class Position
    attr_accessor :code, :date, :price, :volume, :term, :max, :min

    def initialize(code, date, price, volume)
      @code = code
      @date = date
      @volume = volume
      @price = price
      @term = 1
      @max = 0
      @min = 0
    end

    def stay_hold
      @term += 1
    end

    def buy?
      self.is_a? Buy
    end

    def sell?
      self.is_a? Sell
    end

    def self.total_gain(positions, price, percent=false)
      positions.inject(0) do |sum,position|
        sum += position.gain(price, position.volume, percent)
      end
    end

    def update_mfe(price, percent)
      g = gain(price,@volume,percent)
      @max = [g, @max].max
      @min = [g, @min].min
    end

    class Buy < Position
      def gain(price, volume, percent)
        raise 'over position volume' if volume > @volume
        if not percent
          (price - @price) * volume
        else
          (price - @price).to_f / @price * 100
        end
      end
    end

    class Sell < Position

      def gain(price, volume, percent)
        raise 'over position volume' if volume > @volume
        if not percent
          (@price - price) * volume
        else
          (@price - price).to_f / @price * 100
        end
      end
    end
  end
end
