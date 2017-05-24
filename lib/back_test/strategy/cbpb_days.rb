module Kabu
  class CbPbDays

    attr_accessor :n, :length

    def initialize
      @length = 27
    end

    def set_env(soks, env)
      env[:soks] = soks
    end

    def decide(env)
      code = env[:code]
      date = env[:date]
      soks = env[:soks]
      position = env[:position]

      highs = soks[-27..-2].high(20)
      is_high = false
      highs.zip(soks[-8..-2]).each do |high,sok|
        next if high != sok.high
        is_high = true
        break
      end

      lows = soks[-6..-2].low(5)
      is_low = lows[-1] == soks[-2].low

      if not position.nil?
        if position.term >= @n
          return Action::Sell.new(code, date, soks[-1].open,1)
        else
          return Action::None.new(code, soks[-1].open)
        end
      end

      if is_high and is_low
        Action::Buy.new(code, date, soks[-1].open,1)
      else
        Action::None.new(code, soks[-1].open)
      end
    end
  end
end
