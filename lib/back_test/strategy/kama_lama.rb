module Kabu

  class KamaLama < Strategy

    attr_accessor :s_len, :l_len, :closes, :open

    def initialize
      super
      @length = 37
      @l_len = 6
      @s_len = 3
      @kama = nil
      @lama = nil
      @m = 10
    end

    def set_env
      @closes = Soks.parse(soks[0..-2],:close)
      @open = soks[-1].open
    end

    def n=(m)
      @m = m
      @length = m + 2
    end

    def setup
      @kama = nil
      @lama = nil
      @pkama = nil
      @plama = nil
    end

    def decide(env)
      @kama, @lama = calc_ave(closes)

      if position
        if @kama > @lama and position.sell?
          return Action::Buy.new(code, date, open, 2)
        elsif @kama < @lama and position.buy?
          return Action::Sell.new(code, date, open, 2)
        else
          return Action::None.new(code,open)
        end
      end

      if @kama > @lama
        return Action::Buy.new(code, date, open, 1)
      elsif @kama < @lama
        return Action::Sell.new(code, date, open, 1)
      else
        return Action::None.new(code,open)
      end
    end

    def calc_ave(closes)
      @pkama, @plama = @kama, @lama
      sum = closes[-@m-1..-1].diff.abs.sum
      if sum > 0
        er = (closes[-1] - closes[-@m]).abs / sum
      else
        er = 0
      end
      alpha = (er*(2.0/(@s_len+1) - 2.0/(@l_len+1)) + 2.0/(@l_len+1)) ** 2
      if not @kama or not @lama
        @kama = closes[-1]
        @lama = closes[-1]
      else
        @kama = @kama + alpha * (closes[-1] - @kama)
        @lama = @lama + 0.5 * alpha * (@kama - @lama)
      end
      [@kama, @lama]
    end
  end

  class KamaLamaN < KamaLama

    attr_accessor :n

    def decide(env)
      s_ave, l_ave = calc_ave(closes)

      if position
        if position.buy? and @n <= position.term
          return Action::Sell.new(code, date, open, 1)
        elsif position.sell? and @n <= position.term
          return Action::Buy.new(code, date, open, 1)
        else
          return Action::None.new(code,open)
        end
      end

      if @pkama and @plama
        if @kama > @lama and @pkama <= @plama
          return Action::Buy.new(code, date, open, 1)
        elsif @kama < @lama and @pkama >= @plama
          return Action::Sell.new(code, date, open, 1)
        else
          return Action::None.new(code,open)
        end
      else
        return Action::None.new(code,open)
      end
    end
  end
end
