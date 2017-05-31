module Kabu
  class Sok < ActiveRecord::Base
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
  end
end
