module Kabu

  class Bunkrupt

    attr_accessor :pf, :win, :risk, :span, :n
    
    def simulate
      bunkrupt_times = 0
      n.times do 
        capital = 1
        bunkrupt = false
        span.times do 
          gain = (Random.rand <= @win ? @pf * @risk  : - @risk)
          capital += gain
          if capital < 0
            bunkrupt = true
            break
          end
        end
        bunkrupt_times += 1 if bunkrupt
      end
      bunkrupt_times.to_f / n * 100
    end
  end
end
