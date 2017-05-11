require File.expand_path '../spec_helper', File.dirname(__FILE__)
RSpec.describe Kabu::Company do

  describe '.save' do

    let(:company) {Kabu::Company.new}

    it 'should not be saved when all column are nil' do
      expect(company.save).to be false
    end

  end
end

