module Kabu

  class SmaDbs

    attr_accessor :length

    def initialize
      @length = 51
      @l_len = 41
      @s_len = 12
    end

    def set_env(soks, env)
      env[:closes] = Soks.parse(soks[0..-2],:close)
      env[:open] = soks[-1].open
    end

    def setup
      @l_len = 41
      @s_len = 12
    end

    def decide(env)
      code = env[:code]
      open = env[:open]
      date = env[:date]
      position = env[:position]
      closes = env[:closes]

      s_ave, l_ave = calc_ave(closes)

      if position
        if (s_ave[-1] > l_ave[-1]) and position.sell?
          return Action::Buy.new(code, date, open, 1)
        elsif (s_ave[-1] < l_ave[-1]) and position.buy?
          return Action::Sell.new(code, date, open, 1)
        else
          return Action::None.new(code,open)
        end
      end

      if s_ave[-1] > l_ave[-1]
        return Action::Buy.new(code, date, open, 1)
      elsif s_ave[-1] < l_ave[-1]
        return Action::Sell.new(code, date, open, 1)
      else
        return Action::None.new(code,open)
      end
    end

    def calc_ave(closes)
      l_dev = closes[-31..-1].dev(30)
      s_dev = closes[-21..-1].dev(20)

      l_delta = (l_dev[-1] - l_dev[-2]) / l_dev[-1]
      s_delta = (s_dev[-1] - s_dev[-2]) / s_dev[-1]

      @l_len *= (1 + l_delta)
      @l_len = [@l_len, 41].max
      @l_len = [@l_len, 50].min

      @s_len *= (1 + s_delta)
      @s_len = [@s_len, 12].max
      @s_len = [@s_len, 23].min

      l_ave = closes[-@l_len.to_i..-1].ave(@l_len.to_i)
      s_ave = closes[-@s_len.to_i..-1].ave(@s_len.to_i)
      [s_ave, l_ave]
    end
  end

  class SmaDbsN < SmaDbs

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

      if s_ave[-1] > l_ave[-1]
        return Action::Buy.new(code, date, open, 1)
      elsif s_ave[-1] < l_ave[-1]
        return Action::Sell.new(code, date, open, 1)
      else
        return Action::None.new(code,open)
      end
    end
  end

end
