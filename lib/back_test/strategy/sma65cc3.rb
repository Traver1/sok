module Kabu

  class Sma65Cc3 < Strategy

    attr_accessor :closes, :open

    def initialize
      @length = 68
    end

    def set_env
      @closes = Soks.parse(@soks[0..-2],:close)
      @open = @soks[-1].open
    end

    def decide(env)
      aves = @closes[-67..-1].ave(65)
      is_buy = 3.times.inject(true) do |ret, i|
        ret = (ret and (closes[-1-i] > aves[-i-1]))
      end

      is_sell = 3.times.inject(true) do |ret, i|
        ret = (ret and (closes[-1-i] < aves[-i-1]))
      end

      if not position.nil? and position.buy?
        if is_sell
          Action::Sell.new(code,date,open,2)
        else
          Action::None.new(code,open)
        end
      elsif not position.nil? and position.sell?
        if is_buy
          Action::Buy.new(code,date,open,2)
        else
          Action::None.new(code,open)
        end
      else
        if is_buy
          Action::Buy.new(code,date,open,1)
        elsif is_sell
          Action::Sell.new(code,date,open,1)
        else
          Action::None.new(code,open)
        end
      end
    end
  end

  class Sma65Cc3N < Sma65Cc3

    attr_accessor :closes, :open

    def initialize
      @length = 68
    end

    def set_env
      @closes = Soks.parse(@soks[0..-2],:close)
      @open = @soks[-1].open
    end

    def decide(env)
      aves = @closes[-67..-1].ave(65)
      is_buy = 3.times.inject(true) do |ret, i|
        ret = (ret and (closes[-1-i] > aves[-i-1]))
      end

      is_sell = 3.times.inject(true) do |ret, i|
        ret = (ret and (closes[-1-i] < aves[-i-1]))
      end

      if not position.nil? and position.buy? and position.term >= @n
        Action::Sell.new(code,date,open,1)
      elsif not position.nil? and position.sell?  and position.term >= @n
        Action::Buy.new(code,date,open,2)
      elsif not position
        if is_buy
          Action::Buy.new(code,date,open,1)
        elsif is_sell
          Action::Sell.new(code,date,open,1)
        else
          Action::None.new(code,open)
        end
      else
        Action::None.new(code,open)
      end
    end
  end
end
