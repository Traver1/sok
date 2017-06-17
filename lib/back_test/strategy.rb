module Kabu
  class Strategy
    attr_accessor :company, :code, :soks, :date, :position, :capital, :length, :n, :q, :profit, :volumes

    def initialize
      @q = 1000000
      @profit = 0
    end

    def set_env
    end

    def <=>(o)
      if @soks and o.soks and @soks.length >= @length and o.soks.length >= @length
        o.profit <=> @profit
      elsif @soks and @soks.length >= @length
        -1
      elsif o.soks and o.soks.length >= @length
        1
      else
        0
      end
    end

    def pass?
      true
    end

    def calc_volume(price, mult)
      if @capital
        volume = @capital / price / @company.unit * mult
        volume = volume.to_i * @company.unit
      else
        volume = 1
      end
    end

    def prenty?
      if @position.nil? and @capital
        return false if @soks.length < [22, @length].max
        return false if @soks[-2] and @soks[-2].close < 200
        if not @code[0] == 'I'
          @volumes = Soks.parse(soks[-22..-2], :volume)
          return false if @volumes.ave(21)[-1] < @q
        end
      end
      true
    end

    def gain_p(price)
      if @capital
        @position.gain(price,1).to_f / @position.price * 100
      else
        @position.gain(price,1)
      end
    end

    def none
      Action::None.new(@code,@soks[-1].close)
    end

    def sell(price,volume)
      Action::Sell.new(@code,@date,price,volume)
    end

    def buy(price,volume)
      Action::Buy.new(@code,@date,price,volume)
    end

    def date
      @date
    end

    def position
      @position
    end

    def length
      @length
    end

    def soks
      @soks
    end

    def code
      @code
    end

    def company
      @company
    end
  end
end
