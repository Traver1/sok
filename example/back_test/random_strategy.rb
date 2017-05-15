require File.expand_path '../../lib/sok', File.dirname(__FILE__)
include Kabu

trader = Trader.new
strategy = Kabu::Strategy::Random.new


code = 1305
soks = Sok.joins(:company).where('companies.code=?',code).order('date')
position = nil

soks.each do |sok|
  action = strategy.decide(code: code, date: sok.date, 
                    close: sok.close, position: position)
  trader.receive [action]
  position = trader.positions.any? ? trader.positions[0] : nil
end

trader.summary
trader.save File.expand_path('../../data/sample1', File.dirname(__FILE__))
