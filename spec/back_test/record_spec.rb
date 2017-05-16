require File.expand_path '../spec_helper', File.dirname(__FILE__)

describe Kabu::Record do

  let(:records) do
    records = []
    records << Kabu::Record.new(
      1305, 100, 2, 100, Date.parse('20160201'), Date.parse('20160203'), :buy)
    records << Kabu::Record.new(
      1305, 300, 2, 100, Date.parse('20160203'), Date.parse('20160205'), :buy)
    records << Kabu::Record.new(
      1305, -200, 10, 100, Date.parse('20160207',), Date.parse('20160219'), :buy)
  end

  describe '#net_income' do
    it 'should calc correctly' do
      expect(Kabu::Record.net_income records).to eq 200
    end
  end

  describe '#profit' do
    it 'should calc correctly' do
      expect(Kabu::Record.profit records).to eq 400
    end
  end

  describe '#loss' do
    it 'should calc correctly' do
      expect(Kabu::Record.loss records).to eq(-200)
    end
  end

  describe '#profit_factor' do
    it 'should calc correctly' do
      expect(Kabu::Record.profit_factor records).to eq(2)
    end
  end

  describe '#max_profit' do
    it 'should calc correctly' do
      expect(Kabu::Record.max_profit records).to eq(300)
    end
  end

  describe '#max_loss' do
    it 'should calc correctly' do
      expect(Kabu::Record.max_loss  records).to eq(-200)
    end
  end

  describe '#trades' do
    it 'should calc correctly' do
      expect(Kabu::Record.trades  records).to eq(3)
    end
  end

  describe '#wins' do
    it 'should calc correctly' do
      expect(Kabu::Record.wins  records).to eq(2)
    end
  end

  describe '#looses' do
    it 'should calc correctly' do
      expect(Kabu::Record.looses  records).to eq(1)
    end
  end

  describe '#win_rate' do
    it 'should calc correctly' do
      expect(Kabu::Record.win_rate  records).to eq(2.0/3)
    end
  end

  describe '#max_series_of_wins' do
    before do
      records << Kabu::Record.new(
        1305, 100, 2, 100, Date.parse('20160219'), Date.parse('20160221'), :buy)
      records << Kabu::Record.new(
        1305, -100, 2, 100, Date.parse('20160221'), Date.parse('20160223'), :buy)
      records << Kabu::Record.new(
        1305, -200, 1, 100, Date.parse('20160227'), Date.parse('20160228'), :buy)
    end
    it 'should calc correctly' do
      expect(Kabu::Record.max_series_of_wins  records).to eq(2)
    end
  end

  describe '#max_series_of_looses' do
    before do
      records << Kabu::Record.new(
        1305, 100, 2, 100, Date.parse('20160219'), Date.parse('20160221'), :buy)
      records << Kabu::Record.new(
        1305, -100, 2, 100, Date.parse('20160221'), Date.parse('20160223'), :buy)
      records << Kabu::Record.new(
        1305, -200, 1, 100, Date.parse('20160227'), Date.parse('20160228'), :buy)
      records << Kabu::Record.new(
        1305, -200, 2, 100, Date.parse('20160228'), Date.parse('20160229'), :buy)
    end
    it 'should calc correctly' do
      expect(Kabu::Record.max_series_of_looses  records).to eq(3)
    end
  end

  describe '#average_posess_term_of_win' do
    it 'should calc correctly' do
      expect(Kabu::Record.average_posess_term_of_win  records).to eq 2
    end
  end

  describe '#average_posess_term_of_loose' do
    it 'should calc correctly' do
      expect(Kabu::Record.average_posess_term_of_loose  records).to eq 10
    end
  end

  describe '#max_drow_down' do
    before do
      records << Kabu::Record.new(
        1305, 100, 2, 100, Date.parse('20160219'), Date.parse('20160221'), :buy)
      records << Kabu::Record.new(
        1305, -100, 2, 100, Date.parse('20160221'), Date.parse('20160223'), :buy)
      records << Kabu::Record.new(
        1305, -200, 1, 100, Date.parse('20160227'), Date.parse('20160228'), :buy)
      records << Kabu::Record.new(
        1305, -200, 2, 100, Date.parse('20160228'), Date.parse('20160229'), :buy)
    end
    it 'should calc correctly' do
      expect(Kabu::Record.max_drow_down  records).to eq(-500)
    end
  end

  describe '#cumu_profit' do
    it 'should calc correctly' do
      cums = Kabu::Record.cumu_profit(records)
      expect(cums.length).to eq 3
      expect(cums[0]). to eq 100
      expect(cums[1]). to eq 400
      expect(cums[2]). to eq 200
    end
  end

  describe '#histgram' do
    before do
      records << Kabu::Record.new(
        1305, 100, 2, 100, Date.parse('20160219'), Date.parse('20160221'), :buy)
      records << Kabu::Record.new(
        1305, -100, 2, 100, Date.parse('20160221'), Date.parse('20160223'), :buy)
      records << Kabu::Record.new(
        1305, -200, 1, 100, Date.parse('20160227'), Date.parse('20160228'), :buy)
      records << Kabu::Record.new(
        1305, -200, 2, 100, Date.parse('20160228'), Date.parse('20160229'), :buy)
    end
    it 'should calc correctly' do
      x,histgram = Kabu::Record.profit_histgram(records,2)
      expect(x.length).to eq 2
      expect(x[0]).to eq(-200)
      expect(x[1]).to eq 50
      expect(histgram.length).to eq 2
      expect(histgram[0]).to  eq 4
      expect(histgram[1]).to  eq 3
    end
  end

  describe '#monthly_profit' do
    before do
      records << Kabu::Record.new(
        1305, 100, 2, 100, Date.parse('20160219'), Date.parse('20160321'), :buy)
      records << Kabu::Record.new(
        1305, -100, 2, 100, Date.parse('20160321'), Date.parse('20160323'), :buy)
      records << Kabu::Record.new(
        1305, -200, 1, 100, Date.parse('20160527'), Date.parse('20160528'), :buy)
      records << Kabu::Record.new(
        1305, -200, 2, 100, Date.parse('20160628'), Date.parse('20160629'), :buy)
    end
    it 'should calc correctly' do
      months, sums = Kabu::Record.monthly_profit(records)
      expect(months.length).to eq 4
      expect(months[0]).to  eq '2016-02'
      expect(months[1]).to  eq '2016-03'
      expect(months[2]).to  eq '2016-05'
      expect(months[3]).to  eq '2016-06'

      expect(sums.length).to eq 4
      expect(sums[0]).to eq 200
      expect(sums[1]).to eq 0
      expect(sums[2]).to eq(-200)
      expect(sums[3]).to eq(-200)
    end
  end
end
