module Kabu

  class KamaEmb < KamaLama

    attr_accessor :kmasa_l, :t_stop_l

    def initialize
      @kamas = Soks.new
      @t_stop_l = 5
      @m_stop = 0
      @kamas_l = 10
      @dev_r = 0.3
      @length = [@kamas_l,@t_stop_l].max + 2
    end

    def m=(m)
      @m = m
      @length = [@m,@length].max
    end

    def decide(env)
      @kama, @lama = calc_ave(closes)
      @kamas << @kama
      return Action::None.new(code,open) if @kamas.length < @kamas_l
      dev = closes[-@kamas_l..-1].vol(@kamas_l,@kamas)[-1]
      stc = (@kamas.last - @kamas.min ) / (@kamas.max - @kamas.min)  * 100
      is_buy_p = @is_buy
      is_sell_p = @is_sell
      @is_buy = (stc == 100 and closes[-1] < @kama+dev*@dev_r)
      @is_sell = (stc == 0 and closes[-1] > @kama-dev*@dev_r)

      @kamas.shift

      if position
        gain = position.gain(closes[-1], position.volume)

        if gain > @m_stop
          high = soks[-@t_stop_l..-1].high(@t_stop_l)[-1]
          low = soks[-@t_stop_l..-1].low(@t_stop_l)[-1]
          if position.sell? and high == soks[-1].high
            return Action::Buy.new(code, date, open, 1)
          elsif  position.buy? and low == soks[-1].low
            return Action::Sell.new(code, date, open, 1)
          else
            return Action::None.new(code,open)
          end
        else
          if @is_buy and not is_buy_p and position.sell?
            return Action::Buy.new(code, date, open, 2)
          elsif @is_sell and not is_sell_p and position.buy?
            return Action::Sell.new(code, date, open, 2)
          else
            return Action::None.new(code,open)
          end
        end
      end

      if @is_buy and not is_buy_p
        return Action::Buy.new(code, date, open, 1)
      elsif @is_sell and not is_sell_p
        return Action::Sell.new(code, date, open, 1)
      else
        return Action::None.new(code,open)
      end
    end
  end

  class KamaEmbN < KamaEmb

    attr_accessor :n

    def initialize
      super
      @kamas = Soks.new
      @length = 22
    end

    def m=(m)
      @m = m
      @length = [@m,20].max + 2
    end

    def decide(env)
      @kama, @lama = calc_ave(closes)
      @kamas << @kama
      return Action::None.new(code,open) if @kamas.length < @kamas_l
      dev = closes[-@kamas_l..-1].vol(@kamas_l,@kamas)[-1]
      stc = (@kamas.last - @kamas.min ) / (@kamas.max - @kamas.min)  * 100
      is_buy_p = @is_buy
      is_sell_p = @is_sell
      @is_buy = (stc == 100 and closes[-1] < @kama+dev*0.3)
      @is_sell = (stc == 0 and closes[-1] > @kama-dev*0.3)

      @kamas.shift

      if position
        if position.sell? and @n <= position.term
          return Action::Buy.new(code, date, open, 1)
        elsif  position.buy? and @n <= position.term
          return Action::Sell.new(code, date, open, 1)
        else
          return Action::None.new(code,open)
        end
      end

      if @is_buy and not is_buy_p
        return Action::Buy.new(code, date, open, 1)
      elsif @is_sell and not is_sell_p
        return Action::Sell.new(code, date, open, 1)
      else
        return Action::None.new(code,open)
      end
    end
  end
end
