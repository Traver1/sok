module Kabu

  class Sma

    attr_accessor :length, :l_len, :s_len

    def initialize
      @length = 52
      @l_len = 51
      @s_len = 23
      @l_len_tmp = 51
      @s_len_tmp = 23
    end

    def l_len=(l_len)
      @l_len = l_len
      @l_len_tmp = l_len
    end

    def s_len=(s_len)
      @s_len = s_len
      @s_len_tmp = s_len
    end

    def set_env(soks, env)
      env[:closes] = Soks.parse(soks[0..-2],:close)
      env[:open] = soks[-1].open
    end

    def setup
      @l_len = @l_len_tmp
      @s_len = @s_len_tmp
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
