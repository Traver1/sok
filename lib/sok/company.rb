module Kabu
  class Company < ActiveRecord::Base
    has_many :soks
    accepts_nested_attributes_for :soks
    validates :code, presence: true, uniqueness: {scope: :market}

    def to_s
      if market == " "
        code
      else
        "#{code}-#{market}"
      end
    end

    def unit
      return @unit if @unit
      s = soks.order('date').last(20)
      return 1 if not exist_volume?(s)
      result = gcd_euclid(s[-1].volume, s[-1].volume)
      s[-20..-1].each do |sok|
        result = gcd_euclid(sok.volume, result)
      end
      @unit = result
    end

    def exist_volume?(soks)
      soks.each do |sok|
        return false if sok.volume.nil?
      end
      true
    end

    def adjusteds
      return @adjusteds if @adjusteds
      rate = 1
      @adjusteds = soks.order('date desc').each do |sok|
        sok.close = sok.close * rate
        sok.high = sok.high * rate
        sok.low = sok.low * rate
        sok.open = sok.open * rate
        if sok.split
          rate = sok.split.before.to_f / sok.split.after 
        end
      end.reverse
    end

    def gcd_euclid(u, v)
      u = u.to_f
      v = v.to_f
      while (0 != v) do
        r = u % v
        u = v
        v = r
      end
      return u;
    end
  end
end
