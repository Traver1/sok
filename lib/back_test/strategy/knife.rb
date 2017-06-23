module Kabu

  class Knife < Strategy

    attr_accessor :closes, :z, :y, :x

    def initialize
      super
      @length = 22
      @t_price = nil
      @z = 0.04
      @y = 4
      @x = 0.04
    end

    def set_up
      super
    end

    def pass?
      super
    end

    def set_env
      super
      @t_price = nil
      if soks[-@y-1..-1]
        @closes = Soks.parse(soks[-@y-1..-2],:close)
        @open = soks[-1].open
        if soks[-1].low < soks[-2].close * (1-@z) and soks[-1].volume > @q / 3
          @t_price = [(soks[-2].close * (1-@z)).to_i, soks[-1].high].min
        end
      end
    end

    def decide(env)
      if position.nil?
        return none if @t_price.nil?
      end
      if position
        ave = Soks.parse(soks[-3..-1], :close).ave(3)[-1]
        return none if ave > soks[-1].close
        return sell(soks[-1].close,@position.volume)
      else
        diffs = closes[-3..-1].diff
        return none if not (diffs[-1] < 0 and diffs[-2] < 0)

        uave = closes[-@y..-1].ave(@y)[-1] * (1-@x)
        return none if closes[-1] > uave

        volume = calc_volume(@t_price,0.3)
        return buy(@t_price,volume)
      end
    end
  end

  class KnifeS < Knife
    def set_env
      super
      @t_price = nil
      if soks[-@y-1..-1]
        @closes = Soks.parse(soks[-@y-1..-1],:close)
        @open = soks[-1].open
        @t_price = [(soks[-1].close * (1-@z)).to_i, soks[-1].high].min
      end
    end
  end
end
