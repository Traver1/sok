module Kabu
  class Gap < Strategy

    attr_accessor :closes, :open, :volumes, :profit

    def initialize
      @length = 22
      @profit = 0
      @q = 1000000
    end

    def <=>(o)
      if soks and o.soks and soks.length > 21 and o.soks.length > 21
        if soks[-2].volume * soks[-2].close > @q and o.soks[-2].volume * o.soks[-2].close > @q
          o.profit <=> profit
        elsif soks[-2].volume * soks[-2].close > @q
          -1
        elsif o.soks[-2].volume * o.soks[-2].close > @q
          1
        else
          0
        end
      elsif soks and soks.length > 21
        -1
      elsif o.soks and o.soks.length > 21
        1
      else
        0
      end
    end

    def set_env
      if soks.length >= 22
        @closes = Soks.parse(soks[0..-1], :close)
        @open = soks[-1].open
        @volumes = Soks.parse(soks[-22..-2], :volume)
      end
    end

    def decide(env)
      return Action::None.new(code,open) if soks.length < 22
      if position.nil?
        return Action::None.new(code,open) if soks[-2] and soks[-2].close * soks[-1].volume < @q
        return Action::None.new(code,open) if soks[-2] and soks[-2].close < 200
      end

      if capital
        volume = capital / open / company.unit * 0.5
        volume = volume.to_i * company.unit
        return Action::None.new(code,open) if volume == 0 and position.nil?
      else
        volume = 1
      end


      if position
        ave = closes[-3..-1].ave(3)[-1]
        if ave < closes[-1]
          @profit += position.gain(closes[-1],1).to_f / position.price * 100
          return Action::Sell.new(code,date,closes[-1],position.volume)
        end
      else
        gap_down = soks[-2].low > soks[-1].open
        rsi = closes[-3..-2].rsi(2)[-1]
        vave = volumes.ave(21)[-1]
        if rsi < 5 and gap_down and (code[0] != 'I' and vave > 1000000)
          return Action::Buy.new(code,date,open,volume)
        end
      end
      return Action::None.new(code,open)
    end
  end
end
