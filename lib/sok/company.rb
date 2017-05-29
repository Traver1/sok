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
      result = gcd_euclid(s[-1].volume, s[-1].volume)
      s[-20..-1].each do |sok|
        result = gcd_euclid(sok.volume, result)
      end
      @unit = result
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
