module Kabu
  class CbPbHighStopLoss < Strategy

    attr_accessor :loss_line, :length

    def initialize
      @loss_cutted = false
      @length = 27
      @loss_line = -10
    end

    def setup
      @last_position = nil
    end

    def decide(env)
      highs = soks[-27..-2].high(20)
      is_high = false
      highs.zip(soks[-8..-2]).each do |high,sok|
        next if high != sok.high
        is_high = true
        break
      end

      lows = soks[-6..-2].low(5)
      is_low = lows[-1] == soks[-2].low

      if position.nil? 
        if is_high and is_low
          return Action::Buy.new(code, date, soks[-1].open,1)
        else
          return Action::None.new(code, soks[-1].open)
        end
      end

      is_loss_cut = gain_p(soks[-2].close) < @loss_line

      if is_loss_cut
        @last_position = position
        return Action::Sell.new(code,date,soks[-1].open,1)
      end

      if highs[-1] <= soks[-1].high
        return Action::Sell.new(code, date, highs[-1],1)
      else
        return Action::None.new(code, soks[-1].open)
      end
    end
  end
end
