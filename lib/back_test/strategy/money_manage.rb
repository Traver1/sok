module Kabu

  class MoneyManage < Strategy

    attr_accessor :open, :closes

    def initialize
      @length = 67
    end

    def set_env
      @open = soks[-1].open
      @closes = Soks.parse(soks[0..-2],:close)
    end

    def decide(env)
      log = closes[-66..-1].log
      ave,btm,top,dev = log.bol(65,1)

      if capital
        volume = capital /  company.unit / open
        volume = volume.to_i * company.unit
      else
        volume = 1
      end

      if not position.nil? 

        if capital
          gain = position.gain(closes[-1],1) / position.price * 100
        else
          gain = position.gain(closes[-1],1)
        end

        if gain > 20 or gain < -1
          if  position.sell? 
            return Action::Buy.new(code,date,open,position.volume)
          elsif position.buy? 
            return Action::Sell.new(code,date,open,position.volume)
          end
        end

        if gain > 10
          if log[-1] < btm[-1] and position.sell?
            return Action::Buy.new(code,date,open,position.volume + volume)
          elsif log[-1] > top[-1] and position.buy? 
            return Action::Sell.new(code,date,open,position.volume + volume)
          end
        end

        if gain > 2
          bol = closes[-25..-1].bol(25,2.0)

          if bol[1][-1] > closes[-1] and position.sell? 
            return Action::Buy.new(code,date,open,position.volume)
          elsif bol[2][-1] < closes[-1] and position.buy? 
            return Action::Sell.new(code,date,open,position.volume)
          end
        end

        return Action::None.new(code,open)
      end

      if log[-1] < btm[-1]
        return Action::Buy.new(code,date,open,volume)
      elsif log[-1] > top[-1]
        return Action::Sell.new(code,date,open,volume)
      else
        return Action::None.new(code,open)
      end
    end
  end

  class MoneyMonageN

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
        if position.sell? and position.term >= @n
          return Action::Buy.new(code,date,open,1)
        elsif  position.buy? and position.term >= @n
          return Action::Sell.new(code,date,open,1)
        else
          return Action::None.new(code,open)
        end
      end


      if log[-1] < btm[-1]
        return Action::Buy.new(code,date,open,1)
      elsif log[-1] > top[-1]
        return Action::Sell.new(code,date,open,1)
      else
        return Action::None.new(code,open)
      end
    end
  end

  class MoneyManageHukuri

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
      capital = env[:capital]

      volume = volume(capital, soks)
      action(env, volume)
    end

    def volume(capital, soks)
      unit = soks[-1].company.unit
      stocks = (capital.to_f / unit / open * 0.8).to_i
      stocks * unit
    end

    def action(env, volume)
      closes = Soks.parse(soks,:close)
      log = closes[-67..-2].log
      ave,btm,top,dev = log.bol(65,1)
      if not position.nil?

        gain = position.gain(soks[-2].close,1) / position.price * 100

        if gain > 20 or gain < -1
          if  position.sell?
            return Action::Buy.new(code,date,open,position.volume)
          elsif position.buy?
            return Action::Sell.new(code,date,open,position.volume)
          end
        end

        if gain > 10
          if log[-1] < btm[-1] and position.sell?
            return Action::Buy.new(code,date,open,position.volume + volume)
          elsif log[-1] > top[-1] and position.buy?
            return Action::Sell.new(code,date,open,position.volume + volume)
          end
        end

        if gain > 2
          bol = closes[-26..-2].bol(25,2.0)

          if bol[1][-1] > closes[-2] and position.sell?
            return Action::Buy.new(code,date,open,position.volume)
          elsif bol[2][-1] < closes[-2] and position.buy?
            return Action::Sell.new(code,date,open,position.volume)
          end
        end
        return Action::None.new(code,open)
      end

      if volume > 0
        if log[-1] < btm[-1]
          return Action::Buy.new(code,date,open,volume)
        elsif log[-1] > top[-1]
          return Action::Sell.new(code,date,open,volume)
        else
          return Action::None.new(code,open)
        end
      end
    end
  end
end
