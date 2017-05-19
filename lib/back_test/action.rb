module Kabu
  class Action
    attr_accessor :code, :date, :price, :volume 

    def initialize(code, date, price, volume)
      @code = code
      @date = date
      @price = price
      @volume = volume
    end

    def buy?
      self.is_a? Buy
    end

    def sell?
      self.is_a? Sell
    end
    
    def none?
      self.is_a? None
    end

    class Buy < Action

    end

    class Sell < Action

    end

    class None < Action
      def initialize(code, price)
        @code = code
        @price = price
      end
    end
  end
end
