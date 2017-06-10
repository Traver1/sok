module Kabu
  include Numo

  class DevTAt
  end

  class ExpMaStrategy

    attr_accessor :length, :all_data, :code

    def initialize
      @length = 301
    end

    def set_env(soks,env)
      env[:closes] = Soks.parse(soks[0..-2], :close)
      env[:open] = soks[-1].open
      env[:soks] = soks[0..-2]
    end

    def setup
      @a = 1.0 / 2
      @b = 1.0 / 38
      @c = 0.001
      @d = []
      @t = []
      @k = []
      @is_buy = false
      @is_sell = false
      @w = Soks[0]
      @max = Soks[0]
      @min = Soks[0]
    end

    def decide(env)
      closes = env[:closes]
      open = env[:open]
      date = env[:date]
      code = env[:code]
      soks = env[:soks]
      position = env[:position]
      capital = env[:capital]
      com = env[:com]

      if @k.empty?
        @k << [closes[-1],closes[-1],closes[-1]]
      else
        @k << [@k.last[0] + @a * (-@k.last[0] + closes[-1]),
               @k.last[1] + @b * (-@k.last[1] + closes[-1]),
               @k.last[1] + @c * (-@k.last[1] + closes[-1])]
      end
      return Action::None.new(code,open) if @k.length < 100

      @d << (@k[-1][1] - @k[-1][2]) / @k[-1][2] * 100 
      @t << (@k[-1][0] - @k[-1][1]) / @k[-1][1] * 100

      if (@k[-1][0] - @k[-1][1]) * (@k[-2][0] - @k[-2][1]) < 0
        @max << 0
        @min << 0
        @w << 1
      else
        @max[-1] = [@max[-1],@t[-1]].max
        @min[-1] = [@min[-1],@t[-1]].min
        @w[-1] += 1
      end
      return Action::None.new(code,open) if @w.length < 4

      if capital
        volume = capital / open
        volume = (volume / com.unit).to_i * com.unit
      else
        volume = 1
      end

      cma = @max[-4..-2].max * 0.2
      cmi = @max[-4..-2].min * 0.2
      @is_sell = (@t[-1] < cma and @t[-2] > cma)
      @is_buy = (@t[-1] > cmi and @t[-2] < cmi)
      wm =  @w[-4..-2].ave(3)[-1]
      if position
        if wm / 4 < position.term 
          if position.sell? 
            return Action::Buy.new(code, date, open, position.volume)
          elsif position.buy? 
            return Action::Sell.new(code, date, open, position.volume)
          end
        else
          return Action::None.new(code,open)
        end
      elsif wm / @w[-4..-2].ave(3)[-1] > 0.01 and wm > 40
        if @is_buy 
          return Action::Buy.new(code, date, open, volume)
        elsif @is_sell 
          return Action::Sell.new(code, date, open, volume)
        else
          return Action::None.new(code,open)
        end
      else
        return Action::None.new(code,open)
      end
    end
  end

  class ExpMaStrategy2 < ExpMaStrategy
  end
end
