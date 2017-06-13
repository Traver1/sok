module Kabu
  class Strategy
    attr_accessor :company, :code, :soks, :date, :position, :capital, :length, :n

    def set_env
    end

    def <=>(other)
      code <=> other.code
    end

    def date
      @date
    end

    def position
      @position
    end

    def length
      @length
    end

    def soks
      @soks
    end

    def code
      @code
    end

    def company
      @company
    end
  end
end
