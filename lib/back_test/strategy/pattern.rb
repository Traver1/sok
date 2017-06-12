module Kabu
  include Numo

  class PatternStrategy < Strategy

    def initialize
      @length = 102
    end

    def set_env
      @closes = Soks.parse(@soks[0..-2], :close)
      @open = @soks[-1].open
      @soks = @soks[0..-2]
    end

    def decide(env)
      buy_patterns =  [Pattern.double_bottom1,
                       Pattern.double_bottom2,
                       Pattern.double_bottom3,
                       Pattern.pull_back1,
                       Pattern.pull_back2,
                       Pattern.peak_out1,
      ]

      if @capital
        volume = @capital / @company.unit / @open
        volume = volume.to_i * @company.unit
      else
        volume = 1
      end

      buy_patterns.each {|p| p.thr = 1}
      if @position
        highs = @soks[-15..-1].high(14)
        high = (not highs[-1] == @soks[-1].high and highs[-2] == @soks[-2].high)
        gain = @position.gain(@closes[-1],1)
        if @position.buy?
          if high
            return Action::Sell.new(@code, @date, @open, @position.volume)
          elsif @position.term > 5 and gain < 0
            return Action::Sell.new(@code, @date, @open, @position.volume)
          end
        end
        return Action::None.new(@code,  @open)
      else
        low = @soks[-11..-1].low(10)
        high = @soks[-11..-1].high(10)
        buy_patterns.each do |pattern|
          if pattern.correspond? @closes[-51..-2] and low[-2] == @soks[-2].low and 
            not pattern.correspond? @closes[-50..-1] 
            return Action::Buy.new(@code, @date, @open, volume)
          end
        end
        return Action::None.new(@code,  @open)
      end
    end
  end

  class PatternStrategyN
    attr_accessor :length, :all_data, :code, :n, :pattern

    def initialize
      @length = 102
      @pattern = Pattern.pull_back1
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

      if position
        if position.term >= @n
          return Action::Sell.new(code, date, open, 1)
        else
          return Action::None.new(code,  open)
        end
      else
        low = soks[-10..-1].low(10)[-1]
        if @pattern.correspond? closes[-50..-1] and low == soks[-1].low
          return Action::Buy.new(code, date, open, 1)
        else
          return Action::None.new(code,  open)
        end
      end
    end
  end
end
