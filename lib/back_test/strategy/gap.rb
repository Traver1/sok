module Kabu
  class Gap < Strategy

    attr_accessor :closes, :open

    def initialize
      super
      @length = 22
    end

    def set_env
      if soks.length >= 22
        @closes = Soks.parse(soks[0..-1], :close)
        @open = soks[-1].open
      end
    end

    def pass?
      return true if position
      return false if not prenty?
      @volume = calc_volume(open, 0.3)
      return false if @volume == 0 and position.nil?
      true
    end

    def decide(env)
      @volume = calc_volume(open, 0.3)
      if position
        ave = closes[-3..-1].ave(3)[-1]
        if ave < closes[-1]
          @profit += gain_p(closes[-1])
          return Action::Sell.new(code,date,closes[-1],position.volume)
        end
      else
        gap_down = soks[-2].low > soks[-1].open
        rsi = closes[-3..-2].rsi(2)[-1]
        if rsi < 5 and gap_down
          return Action::Buy.new(code,date,open,@volume)
        end
      end
      return Action::None.new(code,open)
    end
  end
end
