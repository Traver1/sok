describe Kabu::Soks do

  describe "#parse" do

    let(:company) {Kabu::Company.new code: 1301, market: 't'}
    let(:date1) {Date.parse('20150101')}
    let(:date2) {Date.parse('20150102')}

    before do 
      company.soks << Kabu::Sok.new(date: date1,
        open: 2000, high: 2040, low: 1880,close: 2010, volume: 40000)
      company.soks << Kabu::Sok.new(date: date2,
        open: 2020, high: 2080, low: 2020,close: 2090, volume: 30000)
    end

    context 'when some types are specified ' do
      it 'it should be parse to Array of Soks' do
        dates, closes = Kabu::Soks.parse(company.soks, :date, :close)
        expect(dates).to be_a Kabu::Soks
        expect(closes).to be_a Kabu::Soks
        expect(dates[0]).to eq date1
        expect(dates[1]).to eq date2
        expect(closes[0]).to eq 2010
        expect(closes[1]).to eq 2090
      end
    end

  end

end
