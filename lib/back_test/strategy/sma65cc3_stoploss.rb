class Sma65Cc3StopLoss

  attr_accessor :loss_line, :length

  def initialize()
    @length = 68
    @loss_cut = false
  end

  def set_env(soks, env)
    env[:closes] = Soks.parse(soks[0..-2],:close)
    env[:open] = soks[-1].open
  end

  def setup()
    @loss_cutted = false
    @last_position = nil
  end

  def reset
    @loss_cutted = false
    @last_position = nil
  end

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

    if position.nil? and not @loss_cutted
      if is_buy
        return Action::Buy.new(code,date,open,1)
      elsif is_sell
        return Action::Sell.new(code,date,open,1)
      else
        return Action::None.new(code,open)
      end
    end

    if position.nil? and @loss_cutted
      if  @last_position.buy? and is_sell
        reset
        return Action::Sell.new(code,date,open,1)
      elsif @last_position.sell? and is_buy
        reset
        return Action::Buy.new(code,date,open,1)
      else
        return Action::None.new(code,open)
      end
    end

    is_loss_cut = position.gain(closes[-1],1) < @loss_line

    if is_loss_cut
      @loss_cutted = true
      @last_position = position
      if position.buy?
        return Action::Sell.new(code,date,open,1)
      elsif position.sell?
        return Action::Buy.new(code,date,open,1)
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


