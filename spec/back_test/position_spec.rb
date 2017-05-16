require File.expand_path '../spec_helper', File.dirname(__FILE__)

describe Kabu::Position do

  let(:position1) {Kabu::Position::Buy.new(1305, Date.parse('20150301'), 1000,10)}
  let(:position2) {Kabu::Position::Buy.new(1305, Date.parse('20150304'), 1200,10)}
  let(:position3) {Kabu::Position::Sell.new(1305, Date.parse('20150304'), 1200,10)}
  let(:positions) {[position1, position2]}

  describe '#total_gain' do

    it 'should calc correctly' do
      expect(Kabu::Position.total_gain(positions, 1100)).to eq 0
      expect(Kabu::Position.total_gain(positions, 1300)).to eq 4000
      expect(Kabu::Position.total_gain([position3,position1], 1300)).to eq 2000
    end
  end
end
