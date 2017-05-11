require File.expand_path '../spec_helper', File.dirname(__FILE__)
RSpec.describe Kabu::Sok do

  describe '.save' do

    let(:sok) {Kabu::Sok.new}

    it 'should not be saved when company_id is nil' do
      sok.open = 1
      sok.high = 1
      sok.low = 1
      sok.close = 1
      sok.volume = 1
      sok.date = Date.parse '20140304'
      expect(sok.save).to be false
    end

  end
end

