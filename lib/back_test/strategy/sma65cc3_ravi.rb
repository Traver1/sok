module Kabu
  class Sma65Cc3Ravi < Strategy

    attr_accessor :closes, :open

    def initialize(line = 1)
      @line = line
      @length = 69
    end

    def set_env
      @closes = Soks.parse(soks[0..-2],:close)
      @open = soks[-1].open
    end

    def decide(env)
      ravi = closes.ravi(7,65)
      return Action::None.new(code,open) if ravi[-1] < @line

      aves = closes[-68..-1].ave(65)
      is_buy = 3.times.inject(true) do |ret, i|
        ret = (ret and (closes[-1-i] > aves[-i-1]))
      end
      is_buy = (is_buy and (closes[-4] <= aves[-4]))

      is_sell = 3.times.inject(true) do |ret, i|
        ret = (ret and (closes[-1-i] < aves[-i-1]))
      end
      is_sell = (is_sell and (closes[-4] >= aves[-4]))

      if position.nil? 
        if is_buy
          return Action::Buy.new(code,date,open,1)
        elsif is_sell
          return Action::Sell.new(code,date,open,1)
        else
          return Action::None.new(code,open)
        end
      end

      if position.buy? and is_sell
        Action::Sell.new(code,date,open,2)
      elsif position.sell? and is_buy
        Action::Buy.new(code,date,open,2)
      else
        Action::None.new(code,open)
      end
    end
  end
end
