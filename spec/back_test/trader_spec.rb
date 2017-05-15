require File.expand_path '../spec_helper', File.dirname(__FILE__)

describe Kabu::Trader do

  describe '.receive' do

    let(:buy_position)  do
      Kabu::Position::Buy.new(
        1305, 
        Date.parse('20150101'),
        1000,
        100
      )
    end

    let(:buy_position2)  do
      Kabu::Position::Buy.new(
        1305, 
        Date.parse('20150102'),
        900,
        100
      )
    end

    let(:sell_position)  do
      Kabu::Position::Sell.new(
        1305, 
        Date.parse('20150101'),
        1100,
        100,
      )
    end

    let(:sell_position2)  do
      Kabu::Position::Sell.new(
        1305, 
        Date.parse('20141221'),
        1200,
        100,
      )
    end

    let(:buy_action) do
      Kabu::Action::Buy.new(
        1305, 
        Date.parse('20150102'),
        1000,
        100
      )
    end

    let(:sell_action) do
      Kabu::Action::Sell.new(
        1305, 
        Date.parse('20150102'),
        900,
        100
      )
    end

    let(:none_action) do
      Kabu::Action::None.new(1305)
    end
    context 'buy action' do
      let(:trader) {Kabu::Trader.new}
      let(:action) {buy_action}

      context 'when position is buy' do
        before { trader.positions << buy_position }
        it 'it should not change records' do
          expect{trader.receive([action])}.not_to change{trader.records}
        end
        it 'old position term is increese' do
          expect{trader.receive([action])}.to change{trader.positions[0].term}.by 1
        end
        it 'new position is created' do
          trader.receive([action])
          expect(trader.positions.length).to eq 2
          expect(trader.positions[1].date).to eq action.date
          expect(trader.positions[1].volume).to eq 100
          expect(trader.positions[1].price).to eq action.price
          expect(trader.positions[1].term).to eq 1
          expect(trader.positions[0].term).to eq 2
        end
      end

      context 'when position is sell' do
        before { trader.positions << sell_position }
        it 'it should change records' do
          expect{trader.receive([action])}.to change{trader.records}
        end

        it 'it should change records' do
          trader.receive [action]
          expect(trader.records[0].profit).to be > 0
          expect(trader.records[0].from).to eq sell_position.date
          expect(trader.records[0].to).to eq buy_action.date
          expect(trader.records[0].term).to eq 1
          expect(trader.records[0].volume).to eq 100
        end

        it 'positions should be empty' do
          trader.receive [action]
          expect(trader.positions).to be_empty
        end
      end

      context 'when position is none' do
        it 'it should not change records' do
          expect{trader.receive([action])}.not_to change{trader.records}
        end
      end

      context 'its volume over current sell position' do
        before {action.volume = 150}
        before {trader.positions << sell_position}
        it 'then sell position is closed and new buy position is created' do
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0]).to be_buy
          expect(trader.positions[0].volume).to eq 50
          expect(trader.positions[0].date).to eq action.date
          expect(trader.positions[0].price).to eq action.price
        end
        it 'record should be based on possition volume ' do
          trader.receive [action]
          expect(trader.records.length).to eq 1
          expect(trader.records[0].volume).to eq 100
          expect(trader.records[0].profit).to eq 100 * (sell_position.price - action.price)
          expect(trader.records[0].from).to eq sell_position.date
          expect(trader.records[0].to).to eq action.date
        end
      end

      context 'its volume under current sell position' do
        before {action.volume = 50}
        before {trader.positions << sell_position}
        it 'then sell position is not  closed and new buy position is not created' do
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0]).to be_sell
          expect(trader.positions[0].volume).to eq 50
          expect(trader.positions[0].date).to eq sell_position.date
          expect(trader.positions[0].price).to eq sell_position.price
        end
        it 'record should be based on action volume ' do
          trader.receive [action]
          expect(trader.records.length).to eq 1
          expect(trader.records[0].volume).to eq 50
          expect(trader.records[0].profit).to eq 50 * (sell_position.price - action.price)
          expect(trader.records[0].from).to eq sell_position.date
          expect(trader.records[0].to).to eq action.date
        end
      end

      context 'when there are two sell position' do
        before {trader.positions << sell_position2}
        before {trader.positions << sell_position}
        it 'and action do not have enoght volume to close old posotion' +
        'then old positoin should be contracted' do
          action.volume = 50
          trader.receive [action]
          expect(trader.positions.length).to eq 2
          expect(trader.positions[0].volume).to eq 50
          expect(trader.positions[1].volume).to eq 100
          expect(trader.records[0].volume).to eq 50
          expect(trader.records[0].profit).to eq 50 * (sell_position2.price - action.price)
        end
        it 'and action do not have enoght volume to close new posotion' +
        'then all of old positoin and part of new position should be contracted' do
          action.volume = 150
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0].volume).to eq 50
          expect(trader.records[0].volume).to eq 100
          expect(trader.records[0].profit).to eq 100 * (sell_position2.price - action.price)
          expect(trader.records[1].volume).to eq 50
          expect(trader.records[1].profit).to eq 50 * (sell_position.price - action.price)
        end
        it 'and action not have enoght volume to close both posotion' +
        'then all of both positoin should be contracted' do
          action.volume = 220
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0].volume).to eq 20
          expect(trader.records[0].volume).to eq 100
          expect(trader.records[0].profit).to eq 100 * (sell_position2.price - action.price)
          expect(trader.records[1].volume).to eq 100
          expect(trader.records[1].profit).to eq 100 * (sell_position.price - action.price)
        end
      end
    end

    context 'sell action' do
      let(:action) {sell_action}
      let(:trader) {Kabu::Trader.new}

      context 'when position is buy' do
        before { trader.positions << buy_position }
        it 'it should change records' do
          expect{ trader.receive([action])}.to change{trader.records}
        end
        it 'it should change records' do
          trader.receive [action]
          expect(trader.records[0].profit).to be < 0
        end
        it 'positions should be empty' do
          trader.receive [action]
          expect(trader.positions).to be_empty
        end
      end

      context 'when position is sell' do
        before { trader.positions << sell_position }
        it 'it should not change records' do
          expect{trader.receive([action])}.not_to change{trader.records}
        end
        it 'old position term is increese' do
          expect{trader.receive([action])}.to change{trader.positions[0].term}.by 1
        end
        it 'new position is created' do
          trader.receive([action])
          expect(trader.positions.length).to eq 2
          expect(trader.positions[1].date).to eq action.date
          expect(trader.positions[1].volume).to eq 100
          expect(trader.positions[1].price).to eq action.price
          expect(trader.positions[1].term).to eq 1
          expect(trader.positions[0].term).to eq 2
        end
      end

      context 'when position is none' do
        it 'it should not change records' do
          expect{trader.receive([action])}.not_to change{trader.records}
        end
      end

      context 'its volume over current buy position' do
        before {action.volume = 150}
        before {trader.positions << buy_position}
        it 'then buy position is closed and new sell position is created' do
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0]).to be_sell
          expect(trader.positions[0].volume).to eq 50
          expect(trader.positions[0].date).to eq action.date
          expect(trader.positions[0].price).to eq action.price
        end
        it 'record should be based on possition volume ' do
          trader.receive [action]
          expect(trader.records.length).to eq 1
          expect(trader.records[0].volume).to eq 100
          expect(trader.records[0].profit).to eq 100 * (-buy_position.price + action.price)
          expect(trader.records[0].from).to eq buy_position.date
          expect(trader.records[0].to).to eq action.date
        end
      end

      context 'its volume under current buy position' do
        before {action.volume = 50}
        before {trader.positions << buy_position}
        it 'then buy  position is not  closed and new sell position is not created' do
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0]).to be_buy
          expect(trader.positions[0].volume).to eq 50
          expect(trader.positions[0].date).to eq buy_position.date
          expect(trader.positions[0].price).to eq buy_position.price
        end
        it 'record should be based on action volume ' do
          trader.receive [action]
          expect(trader.records.length).to eq 1
          expect(trader.records[0].volume).to eq 50
          expect(trader.records[0].profit).to eq 50 * (-buy_position.price + action.price)
          expect(trader.records[0].from).to eq buy_position.date
          expect(trader.records[0].to).to eq action.date
        end
      end

      context 'when there are two buy position' do
        before {trader.positions << buy_position2}
        before {trader.positions << buy_position}
        it 'and action do not have enoght volume to close old posotion' +
        'then old positoin should be contracted' do
          action.volume = 50
          trader.receive [action]
          expect(trader.positions.length).to eq 2
          expect(trader.positions[1].volume).to eq 50
          expect(trader.positions[0].volume).to eq 100
          expect(trader.records[0].volume).to eq 50
          expect(trader.records[0].profit).to eq 50 * (-buy_position.price + action.price)
        end
        it 'and action do not have enoght volume to close new posotion' +
        'then all of old positoin and part of new position should be contracted' do
          action.volume = 150
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0].volume).to eq 50
          expect(trader.records[0].volume).to eq 100
          expect(trader.records[0].profit).to eq 100 * (-buy_position.price + action.price)
          expect(trader.records[1].volume).to eq 50
          expect(trader.records[1].profit).to eq 50 * (-buy_position2.price + action.price)
        end
        it 'and action not have enoght volume to close both posotion' +
        'then all of both positoin should be contracted' do
          action.volume = 220
          trader.receive [action]
          expect(trader.positions.length).to eq 1
          expect(trader.positions[0].volume).to eq 20
          expect(trader.records[0].volume).to eq 100
          expect(trader.records[0].profit).to eq 100 * (-buy_position.price + action.price)
          expect(trader.records[1].volume).to eq 100
          expect(trader.records[1].profit).to eq 100 * (-buy_position2.price + action.price)
        end
      end
    end

    context 'none action' do
      let(:trader) {Kabu::Trader.new}
      let(:action) {none_action}

      context 'when position is buy' do
        before { trader.positions << buy_position }
        it 'it should not change records' do
          expect{trader.receive([action])}.not_to change{trader.records}
        end
        it 'old position term is increese' do
          expect{trader.receive([action])}.to change{trader.positions[0].term}.by 1
        end
        it 'position dont change' do
          expect{trader.receive([action])}.not_to change{trader.positions}
        end
      end

      context 'when position is sell' do
        before { trader.positions << sell_position }
        it 'it should not change records' do
          expect{trader.receive([action])}.not_to change{trader.records}
        end
        it 'old position term is increese' do
          expect{trader.receive([action])}.to change{trader.positions[0].term}.by 1
        end
        it 'position dont change' do
          expect{trader.receive([action])}.not_to change{trader.positions}
        end
      end

      context 'when position is none' do
        it 'it should not change records' do
          expect{trader.receive([action])}.not_to change{trader.records}
        end
        it 'position dont change' do
          expect{trader.receive([action])}.not_to change{trader.positions}
        end
      end
    end
  end
end

