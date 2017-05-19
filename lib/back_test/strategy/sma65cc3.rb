class Sma65Cc3

  def decide(env)
    code = env[:code]
    date = env[:date]
    closes = env[:closes]
    open = env[:open]
    position = env[:position]

    aves = closes[-67..-1].ave(65)
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


