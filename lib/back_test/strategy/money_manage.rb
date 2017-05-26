module Kabu
  class TestStrategy

    attr_accessor :length, :n

    def initialize
      @length = 67
    end

    def set_env(soks, env)
      env[:soks] = soks
    end

    def setup
    end

    def decide(env)
      soks = env[:soks]
      code = env[:code]
      date = env[:date]
      position = env[:position]
      closes = Soks.parse(soks,:close)

      log = closes[-67..-2].log
      ave,btm,top,dev = log.bol(65,1)
      if not position.nil? 

        gain = position.gain(soks[-1].close,1)

        if gain > 20 or gain < -1
          if  position.sell? 
            return Action::Buy.new(code,date,soks[-1].open,1)
          elsif position.buy? 
            return Action::Sell.new(code,date,soks[-1].open,1)
          end
        end

        if gain > 10
          if log[-1] < btm[-1] and position.sell?
            return Action::Buy.new(code,date,soks[-1].open,2)
          elsif log[-1] > top[-1] and position.buy? 
            return Action::Sell.new(code,date,soks[-1].open,2)
          end
        end

        if gain > 2
          bol = closes[-26..-2].bol(25,2.0)

          if bol[1][-1] > closes[-2] and position.sell?
            return Action::Buy.new(code,date,soks[-1].open,1)
          elsif bol[2][-1] < closes[-2] and position.buy?
            return Action::Sell.new(code,date,soks[-1].open,1)
          end
        end

        return Action::None.new(code,soks[-1].open)
      end

      if log[-1] < btm[-1]
        return Action::Buy.new(code,date,soks[-1].open,1)
      elsif log[-1] > top[-1]
        return Action::Sell.new(code,date,soks[-1].open,1)
      else
        return Action::None.new(code,soks[-1].open)
      end
    end
  end
end
