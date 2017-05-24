require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

class Sma65Cc3

  def initialize(n)
    @n = n
  end

  def decide(env)
    code = env[:code]
    date = env[:date]
    closes = env[:closes]
    open = env[:open]
    position = env[:position]

    aves = closes[-67..-1].ave(65)
    is_buy = 3.times.inject(true) do |ret, i|
      ret = ret and (closes[-i-1] > aves[-i-1])
    end

    if not position.nil? and position.buy?
      if position.term >= @n
        Action::Sell.new(code,date,open,1)
      else
        Action::None.new(code,open)
      end
    else
      if is_buy
        Action::Buy.new(code,date,open,1)
      else
        Action::None.new(code,open)
      end
    end
  end
end

exam = Examination.new
exam.n(Sma65Cc3, 68) do |soks, env|
  env[:closes] = Soks.parse(soks[0..-2],:close)
  env[:open] = soks[-1].open
end
