module Kabu

  class Pattern
    include Numo

    attr_accessor :pattern, :thr

    def initialize(pattern)
      @thr = 1.5
      @pattern = Soks[*pattern]
    end

    def correspond?(target)
      size = @pattern.length
      min = target[-size..-1].min
      reg = target[-size..-1].max - min
      ts = target[-size..-1].map {|t| (t-min).to_f / reg}
      di = 0
      ts.zip(pattern).each do |t,p|
        di += (t - p) ** 2
      end
      di = Math.sqrt(di)
      @thr > di
    end


    #|0.50|0.48|0.52|0.54|0.55|0.50| buy
    def self.pull_back2
      Pattern.new(30.times.map {|i| i.to_f/29} +
                  20.times.map {|i| 1.0 - i.to_f/19/2})
    end

    #|0.52|0.50|0.49|0.48|0.54|0.49| buy
    def self.pull_back1
      Pattern.new(40.times.map {|i| i.to_f/39} +
                  10.times.map {|i| 1.0 - i.to_f/9/2})
    end

    #|0.54|0.53|0.53|0.51|0.46|0.55| sell
    def self.peak_out1
      Pattern.new(40.times.map {|i| i.to_f/39} +
                  10.times.map {|i| 1.0 - i.to_f/9})
    end
    
    #|0.51|0.51|0.53|0.50|0.57|0.58| sell
    def self.peak_out2
      Pattern.new(30.times.map {|i| i.to_f/29} +
                  20.times.map {|i| 1.0 - i.to_f/19})
    end
    
    # |0.53|0.47|0.45|0.47|0.57|0.58| sell
    def self.peak_out3
      Pattern.new(20.times.map {|i| i.to_f/19} +
                  30.times.map {|i| 1.0 - i.to_f/29})
    end

    #|0.51|0.46|0.51|0.46|0.54|0.57| sell
    def self.single_top
      Pattern.new(25.times.map {|i| i.to_f/24} +
                  25.times.map {|i| 1.0 - i.to_f/24})
    end

    # |0.56|0.59|0.60|0.58|0.58|0.58| buy
    def self.double_bottom1
      Pattern.new(16.times.map {|i| 1.0 - i.to_f/15} +
                  16.times.map {|i| i.to_f/15/2} +
                  18.times.map {|i| 0.5 - i.to_f/17/2})
    end

    #|0.53|0.53|0.62|0.62|0.55|0.56| buy
    def self.double_bottom2
      Pattern.new(16.times.map {|i| 1 - i.to_f/15} +
                  16.times.map {|i| i.to_f/15} +
                  18.times.map {|i| 1 - i.to_f/17})
    end
    #|0.58|0.56|0.57|0.62|0.58|0.53| buy
    def self.double_bottom3
      Pattern.new(16.times.map {|i| 1.0 - i.to_f/15/2} +
                  16.times.map {|i| 0.5 + i.to_f/15/2} +
                  18.times.map {|i| 1.0 - i.to_f/17})
    end

    def self.double_top
      Pattern.new(16.times.map {|i| i.to_f/15} +
                  16.times.map {|i| 1 - i.to_f/15/2} +
                  18.times.map {|i| 0.5 + i.to_f/17/2})
    end

    def self.incresing
      Pattern.new(50.times.map {|i| i.to_f/49})
    end

    def self.decresing
      Pattern.new(50.times.map {|i| 1 - i.to_f/49})
    end

    #|0.54|0.52|0.51|0.50|0.52|0.51|
    def self.zig_zag_up
      Pattern.new(10.times.map {|i| 0.5 - i.to_f/9/2} +
                  20.times.map {|i| i.to_f/19} +
                  10.times.map {|i| 1.0 - i.to_f/10/2})
    end
  end
end
