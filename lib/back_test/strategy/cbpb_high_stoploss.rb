module Kabu
  class CbPbHighStopLoss

    attr_accessor :loss_line, :length

    def initialize
      @loss_cutted = false
      @length = 27
    end

    def setup
      @last_position = nil
    end

    def set_env(soks, env)
      env[:soks] = soks
    end

    def decide(env)
      code = env[:code]
      date = env[:date]
      soks = env[:soks]
      position = env[:position]

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

      is_loss_cut = position.gain(soks[-2].close,1) < @loss_line

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
