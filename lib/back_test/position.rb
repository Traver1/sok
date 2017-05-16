module Kabu
  class Position
    attr_accessor :code, :date, :price, :volume, :term

    def initialize(code, date, price, volume)
      @code = code
      @date = date
      @volume = volume
      @price = price
      @term = 1
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

    def self.total_gain(positions, price)
      positions.inject(0) do |sum,position|
        sum += position.gain(price, position.volume)
      end
    end

    class Buy < Position
      def gain(price, volume)
        raise 'over position volume' if volume > @volume
        (price - @price) * volume
      end
    end

    class Sell < Position

      def gain(price, volume)
        raise 'over position volume' if volume > @volume
        (@price - price) * volume
      end
    end
  end
end
