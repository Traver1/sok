module Kabu
  class Sok < ActiveRecord::Base
    attr_accessor :rate
    belongs_to :company
    has_one :split
    validates_uniqueness_of :company_id, scope: :date, allow_nil: false
    validates :company, presence: true
    validates :date, presence: true
    validates_date :date
    validates_numericality_of :open, :high, :low, :close, :volume, allow_nil: true

    def to_s(separator=',')
      [company.to_s, open, high, low, close, volume].join(separator)
    end

    def adjust_values!(r)
      if split
        r = 1 if not r
        @rate = r * split.after / split.before
        self.open = self.open * @rate
        self.high = self.high * @rate
        self.low = self.low * @rate
        self.close = self.close * @rate
        self.volume = self.volume / @rate
      else
        @rate = 1 if not r or r == 1
        return if  @rate == 1
        @rate = r
        self.open = self.open * r
        self.high = self.high * r
        self.low = self.low * r
        self.close = self.close * r
        self.volume = self.volume / r
      end
    end

  end
end
