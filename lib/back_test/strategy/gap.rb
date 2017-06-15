module Kabu
  class Gap < Strategy

    attr_accessor :closes, :open, :volumes

    def initialize
      @length = 22
    end

    def set_env
      @closes = Soks.parse(soks[0..-1], :close)
      @open = soks[-1].open
      @volumes = Soks.parse(soks[-22..-2], :volume)
    end

    def decide(env)
      if position
        ave = closes[-3..-1].ave(3)[-1]
        if ave < closes[-1]
          return Action::Sell.new(code,date,closes[-1],1)
        end
      else
        gap_down = soks[-2].low > soks[-1].open
        rsi = closes[-3..-2].rsi(2)[-1]
        vave = volumes.ave(21)[-1]
        if rsi < 5 and gap_down and (code[0] != 'I' and vave > 1000000)
          return Action::Buy.new(code,date,open,1)
        end
      end
      return Action::None.new(code,open)
    end
  end
end
