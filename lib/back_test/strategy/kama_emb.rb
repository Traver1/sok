module Kabu

  class KamaEmb < KamaLama

    attr_accessor :kmasa_l, :t_stop_l, :profit

    def initialize
      super
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

    def setup
      super
      @kamas = []
      @is_buy = nil
      @is_sell = nil
    end

    def pass?
      return true if position
      return false if not prenty?
      @volume = calc_volume(open, 0.3)
      return false if @volume == 0 and position.nil?
      true
    end

    def set_env
      super
      @kama, @lama = calc_ave(closes)
      @kamas << @kama
    end

    def decide(env)
      return none if @kamas.length < @kamas_l
      dev = closes[-@kamas_l..-1].vol(@kamas_l,@kamas)[-1]
      stc = (@kamas.last - @kamas.min ) / (@kamas.max - @kamas.min)  * 100
      is_buy_p = @is_buy
      is_sell_p = @is_sell
      @is_buy = (stc == 100 and closes[-1] < @kama+dev*@dev_r)
      @is_sell = (stc == 0 and closes[-1] > @kama-dev*@dev_r)
      @volume = calc_volume(open, 0.3)

      @kamas.shift

      if position
        gain = gain_p(closes[-1])
        if gain > @m_stop
          high = soks[-@t_stop_l..-1].high(@t_stop_l)[-1]
          low = soks[-@t_stop_l..-1].low(@t_stop_l)[-1]
          if position.sell? and high == soks[-1].high
            @profit += gain / position.term
            return buy(open, position.volume)
          elsif  position.buy? and low == soks[-1].low
            @profit += gain/ position.term
            return sell(open, position.volume)
          else
            return none 
          end
        elsif gain < -20 or position.term > 40
          if position.sell?
            @profit += gain/ position.term
            return buy(open, position.volume)
          elsif position.buy?
            @profit += gain/ position.term
            return sell(open, position.volume)
          end
        else
          if @is_buy and not is_buy_p and position.sell?
            @profit += gain/ position.term
            return buy(open, position.volume + @volume)
          elsif @is_sell and not is_sell_p and position.buy?
            @profit += gain/ position.term
            return sell(open, position.volume + @volume)
          else
            return none
          end
        end
      end

      if @is_buy and not is_buy_p
        return buy(open, @volume)
      elsif @is_sell and not is_sell_p
        return sell(open, @volume)
      else
        return none
      end
    end
  end

  class KamaEmbS < KamaEmb
    
    def set_env
      super
      closes = Soks.parse(soks, :close)
      open = soks[-1].open
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
