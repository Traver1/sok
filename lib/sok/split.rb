module Kabu
  class Split < ActiveRecord::Base
    belongs_to :sok
    validates_uniqueness_of :sok_id, allow_nil: false
    validates :sok, presence: true
    validates_numericality_of :before, :after
  end
end
