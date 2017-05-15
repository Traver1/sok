module Kabu
  class Strategy
    class Random

      def decide(env)
        position = env[:position]
        close = env[:close]
        date = env[:date]
        code = env[:code]
        rv = Kernel.rand
        if not position.nil?
          case 
          when position.buy?
            if rv > 0.95
              Action::Sell.new(code, date, close, 1) 
            else
              Action::None.new(code)
            end
          when position.sell?
            if rv > 0.95
              Action::Buy.new(code, date, close, 1) 
            else
              Action::None.new(code)
            end
          end
        else
          if rv > 0.95
            Action::Sell.new(code, date, close, 1) 
          elsif rv > 0.9
            Action::Buy.new(code, date, close, 1) 
          else
            Action::None.new(code)
          end
        end
      end
    end
  end
end
