module Kabu

  class Screen

    attr_accessor :trader, :actions

    def initialize
      @actions = []
    end

    def self.load(path)
      File.open(path, 'rb') do |file|
        Marshal.load(file)
      end
    end

    def self.save(screen, path)
      File.open(path, 'wb') do |file|
        file << Marshal.dump(screen)
      end
    end

    def screen(from, to, strategy)
      soks = Company.find_by_code(strategy.code).adjusteds(from, to)
      if soks.last and soks.length >= strategy.length
        if soks.last.date == to
          strategy.soks = Soks[*soks]
          strategy.date = soks.last.date
          position = @trader.positions.select{|s|s.code == strategy.code}
          strategy.position = position ? position[0] : nil
          strategy.capital = @trader.capital(false)
          strategy.company = soks.last.company
          strategy.set_env
          if strategy.pass?
            action = strategy.decide(nil)
            volume = action.volume
            @trader.receive [action]
            if not action.none?
              puts [strategy.code, @trader.capital(false), action.class, action.price, volume].join(' ') 
              @actions << action 
            end
          end
        end
      end
      strategy.dispose
    end
  end
end
