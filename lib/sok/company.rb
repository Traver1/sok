module Kabu
  class Company < ActiveRecord::Base
    has_many :soks
    accepts_nested_attributes_for :soks
    validates :code, presence: true, uniqueness: {scope: :market}

    def to_s
      "#{code}-#{market}"
    end
  end
end
