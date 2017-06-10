module Kabu
  include Numo

  class DevTAt
  end

  class BBTAt

    attr_accessor :length, :all_data, :code

    def initialize
      @length = 102
    end

    def set_env(soks,env)
      env[:closes] = Soks.parse(soks[0..-2], :close)
      env[:open] = soks[-1].open
      env[:soks] = soks[0..-2]
    end

    def setup
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

      if capital
        volume = capital / open
        volume = (volume / com.unit).to_i * com.unit
      else
        volume = 1
      end

      s_ave, s_btm, s_top, s_dev = closes[-26..-1].bol(25,1.0)
      l_ave, l_btm, l_top, l_dev = closes[-51..-1].bol(50,1.5) 
      sbu = (closes[-1] > s_btm[-1] and closes[-2] < s_btm[-2])
      std = (closes[-1] < s_top[-1] and closes[-2] > s_top[-2])

      stu = (closes[-1] > s_top[-1] and closes[-2] < s_top[-2])
      sbd = (closes[-1] < s_btm[-1] and closes[-2] > s_btm[-2])

      st  = closes[-1] > s_top[-1]
      sb  = closes[-1] < s_btm[-1]

      avu = (closes[-1] > s_ave[-1] and closes[-2] < s_ave[-2])
      avd = (closes[-1] < s_ave[-1] and closes[-2] > s_ave[-2])

      efd = s_dev[-1] / closes[-1] * 100 > 1

      if not @trend
        @trend = 
          ((closes[-1] < l_btm[-1] or closes[-1] > l_top[-1]) and l_dev[-1] > l_dev[-2])
      else
        @trend = l_dev[-1] > l_dev[-2]
      end

      if position
        if @trend
          if st and position.sell?
            return Action::Buy.new(code, date, open, position.volume)
          elsif sb and position.buy?
            return Action::Sell.new(code, date, open, position.volume)
          else
            return Action::None.new(code,open)
          end
        else
          if position.sell? and sbd
            return Action::Buy.new(code, date, open, position.volume)
          elsif position.buy? and stu 
            return Action::Sell.new(code, date, open, position.volume)
          elsif position.sell? and avu
            return Action::Buy.new(code, date, open, position.volume)
          elsif position.buy? and avd
            return Action::Sell.new(code, date, open, position.volume)
          elsif position.gain(closes[-1], position.volume) < -3
            if position.sell? 
              return Action::Buy.new(code, date, open, position.volume)
            elsif position.buy? 
              return Action::Sell.new(code, date, open, position.volume)
            end
          else
            return Action::None.new(code,open)
          end
        end
      else
        if not @trend
          if sbu and efd
            return Action::Buy.new(code, date, open, volume)
          elsif std and efd
            return Action::Sell.new(code, date, open, volume)
          else
            return Action::None.new(code,open)
          end
        else
          return Action::None.new(code,open)
        end
      end
    end
  end
end
