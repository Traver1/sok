module Kabu

  class Vidya < Strategy

    attr_accessor :l_len, :s_len, :closes, :open

    def initialize
      @length = 40
      @l_len = 39
      @s_len = 7
      @alpha = 2.0 / (1 + 39)
      @vidya = nil
    end

    def set_env
      @closes = Soks.parse(soks[0..-2],:close)
      @open = soks[-1].open
    end

    def setup
      @vidya = nil
    end

    def decide(env)
      @vidya = calc_ave(closes)
      is_buy = closes[-1] > @vidya
      is_sell = closes[-1] < @vidya

      if position
        if is_buy and position.sell?
          return Action::Buy.new(code, date, open, 2)
        elsif is_sell and position.buy?
          return Action::Sell.new(code, date, open, 2)
        else
          return Action::None.new(code,open)
        end
      end

      if is_buy
        return Action::Buy.new(code, date, open, 1)
      elsif is_sell
        return Action::Sell.new(code, date, open, 1)
      else
        return Action::None.new(code,open)
      end
    end

    def calc_ave(closes)
      @pvidya = @vidya
      if @vidya.nil?
        @vidya = closes[-1]
      else
        sdev = closes[-@s_len..-1].dev(@s_len)[-1]
        ldev = closes[-@l_len..-1].dev(@l_len)[-1]
        vi = sdev / ldev
        vi = 1 if vi > 1
        @vidya = @vidya + @alpha * vi * (closes[-1] - @vidya)
      end
      @vidya
    end
  end

  class VidyaN < Vidya

    attr_accessor :l_len, :s_len

    def decide(env)
      @vidya = calc_ave(closes)
      is_buy = closes[-1] > @vidya
      is_sell = closes[-1] < @vidya

      if position
        if position.sell? and position.term >= @n
          return Action::Buy.new(code, date, open, 1)
        elsif position.buy? and position.term >= @n
          return Action::Sell.new(code, date, open, 1)
        else
          return Action::None.new(code,open)
        end
      end

      return Action::None.new(code,open) if not @pvidya 
      is_buy_p = closes[-2] > @pvidya
      is_sell_p = closes[-2] < @pvidya

      if is_buy and not is_buy_p
        return Action::Buy.new(code, date, open, 1)
      elsif is_sell and not is_sell_p
        return Action::Sell.new(code, date, open, 1)
      else
        return Action::None.new(code,open)
      end
    end
  end
end
