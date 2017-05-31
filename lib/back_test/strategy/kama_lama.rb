module Kabu

  class KamaLama

    attr_accessor :length, :s_len, :l_len, :n

    def initialize
      @length = 37
      @l_len = 6
      @s_len = 3
      @kama = nil
      @lama = nil
      @m = 10
    end

    def set_env(soks, env)
      env[:closes] = Soks.parse(soks[0..-2],:close)
      env[:open] = soks[-1].open
    end

    def setup
      @kama = nil
      @lama = nil
      @pkama = nil
      @plama = nil
    end

    def decide(env)
      code = env[:code]
      open = env[:open]
      date = env[:date]
      position = env[:position]
      closes = env[:closes]

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
      er = (closes[-1] - closes[-@m]).abs / closes[-@m-1..-1].diff.abs.sum
      alpha = (er*(2.0/(@s_len+1) - 2.0/(@l_len+1)) + 2.0/(@l_len+1)) ** 2
      if not @kama or not @lama
        @kama = closes[-@l_len**2..-1].ave(@l_len**2)[-1]
        @lama = @kama
      else
        @kama = @kama + alpha * (closes[-1] - @kama)
        @lama = @lama + 0.5 * alpha * (closes[-1] - @lama)
      end
      [@kama, @lama]
    end
  end

  class KamaLamaN < KamaLama

    attr_accessor :length, :n

    def decide(env)
      code = env[:code]
      open = env[:open]
      date = env[:date]
      position = env[:position]
      closes = env[:closes]

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

      binding.pry
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
