module Kabu
  class MoneyManage

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

        gain = position.gain(soks[-2].close,1)

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
          return Action::Buy.new(code,date,soks[-1].open,1)
        elsif  position.buy? and position.term >= @n
          return Action::Sell.new(code,date,soks[-1].open,1)
        else
          return Action::None.new(code,soks[-1].open)
        end
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
      stocks = (capital.to_f / unit / soks[-1].open * 0.8).to_i
      stocks * unit
    end

    def action(env, volume)
      soks = env[:soks]
      capital = env[:capital]
      code = env[:code]
      date = env[:date]
      position = env[:position]
      closes = Soks.parse(soks,:close)
      log = closes[-67..-2].log
      ave,btm,top,dev = log.bol(65,1)
      if not position.nil?

        gain = position.gain(soks[-2].close,1) / position.price * 100

        if gain > 20 or gain < -1
          if  position.sell?
            return Action::Buy.new(code,date,soks[-1].open,position.volume)
          elsif position.buy?
            return Action::Sell.new(code,date,soks[-1].open,position.volume)
          end
        end

        if gain > 10
          if log[-1] < btm[-1] and position.sell?
            return Action::Buy.new(code,date,soks[-1].open,position.volume + volume)
          elsif log[-1] > top[-1] and position.buy?
            return Action::Sell.new(code,date,soks[-1].open,position.volume + volume)
          end
        end

        if gain > 2
          bol = closes[-26..-2].bol(25,2.0)

          if bol[1][-1] > closes[-2] and position.sell?
            return Action::Buy.new(code,date,soks[-1].open,position.volume)
          elsif bol[2][-1] < closes[-2] and position.buy?
            return Action::Sell.new(code,date,soks[-1].open,position.volume)
          end
        end
        return Action::None.new(code,soks[-1].open)
      end

      if volume > 0
        if log[-1] < btm[-1]
          return Action::Buy.new(code,date,soks[-1].open,volume)
        elsif log[-1] > top[-1]
          return Action::Sell.new(code,date,soks[-1].open,volume)
        else
          return Action::None.new(code,soks[-1].open)
        end
      end
    end
  end

  class MoneyManageHukusu

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
      stocks = (capital.to_f / unit / soks[-1].open ).to_i
      stocks * unit
    end

    def action(env, volume)
      soks = env[:soks]
      capital = env[:capital]
      code = env[:code]
      date = env[:date]
      positions = env[:positions]
      closes = Soks.parse(soks,:close)
      log = closes[-67..-2].log
      ave,btm,top,dev = log.bol(65,1)

      actions = []
      if positions.any?
        positions.each do |position|
          gain = position.gain(soks[-2].close,1) / position.price * 100
          if gain > 20 or gain < -1
            if  position.sell?
              actions << Action::Buy.new(code,date,soks[-1].open,position.volume)
            elsif position.buy?
              actions << Action::Sell.new(code,date,soks[-1].open,position.volume)
            end
          elsif gain > 10
            if log[-1] < btm[-1] and position.sell?
              actions << Action::Buy.new(code,date,soks[-1].open,position.volume + volume)
            elsif log[-1] > top[-1] and position.buy?
              actions << Action::Sell.new(code,date,soks[-1].open,position.volume + volume)
            end
          elsif gain > 2
            bol = closes[-26..-2].bol(25,2.0)
            if bol[1][-1] > closes[-2] and position.sell?
              actions << Action::Buy.new(code,date,soks[-1].open,position.volume)
            elsif bol[2][-1] < closes[-2] and position.buy?
              actions << Action::Sell.new(code,date,soks[-1].open,position.volume)
            end
          end
        end
      end

      is_hold_buy = positions.select {|action| action.buy?}.any?
      is_hold_sell = positions.select {|action| action.sell?}.any?

      if actions.empty? and (is_hold_buy or is_hold_sell)
        actions << Action::None.new(code,soks[-1].open)
      end

      is_buy = actions.select {|action| action.buy?}.any?
      is_sell = actions.select {|action| action.sell?}.any?
      if volume > 0
        if log[-1] < btm[-1] and (positions.empty? or not is_hold_sell) and not is_sell
          actions << Action::Buy.new(code,date,soks[-1].open,volume)
        elsif log[-1] > top[-1] and  (positions.empty? or not is_hold_buy) and not is_buy
          actions << Action::Sell.new(code,date,soks[-1].open,volume)
        end
      end

      if actions.empty?
        actions << Action::None.new(code,soks[-1].open)
      end

      actions
    end
  end

  class MoneyManageTwoCodes < MoneyManageHukuri

    def decide(env)
      coms = env[:coms]
      capital = env[:capital]

      action(env)
    end

    def action(env)
      coms = env[:coms]
      capital = env[:capital]
      positions = env[:positions]
      codes = env[:codes]
      date = env[:date]
      actions = []
      coms.each do |soks|
        position = positions.find {|p| p.code == soks.last.company.code}
        closes = Soks.parse(soks,:close)
        log = closes[-67..-2].log
        ave,btm,top,dev = log.bol(65,1)
        volume = volume(capital, soks)
        code = soks.last.company.code
        if not position.nil?
          gain = position.gain(soks[-2].close,1) / position.price * 100
          if gain > 20 or gain < -1
            if  position.sell?
              action =  Action::Buy.new(code,date,soks[-1].open,position.volume)
            elsif position.buy?
              action =  Action::Sell.new(code,date,soks[-1].open,position.volume)
            else
              action = Action::None.new(code,soks[-1].open)
            end
          elsif gain > 10
            if log[-1] < btm[-1] and position.sell?
              action = Action::Buy.new(code,date,soks[-1].open,position.volume + volume)
            elsif log[-1] > top[-1] and position.buy?
              action = Action::Sell.new(code,date,soks[-1].open,position.volume + volume)
            else
              action = Action::None.new(code,soks[-1].open)
            end
          elsif gain > 2
            bol = closes[-26..-2].bol(25,2.0)
            if bol[1][-1] > closes[-2] and position.sell?
              action =  Action::Buy.new(code,date,soks[-1].open,position.volume)
            elsif bol[2][-1] < closes[-2] and position.buy?
              action =  Action::Sell.new(code,date,soks[-1].open,position.volume)
            else
              action = Action::None.new(code,soks[-1].open)
            end
          else
            action = Action::None.new(code,soks[-1].open)
          end
        elsif volume > 0
          if log[-1] < btm[-1]
            action = Action::Buy.new(code,date,soks[-1].open,volume)
          elsif log[-1] > top[-1]
            action =  Action::Sell.new(code,date,soks[-1].open,volume)
          else
            action = Action::None.new(code,soks[-1].open)
          end
          capital -= action.price * action.volume if not action.none?
        end
        actions << action
      end
      actions
    end
  end
end
