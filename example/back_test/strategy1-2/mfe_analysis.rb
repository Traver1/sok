require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu


codes = []

trader = Trader.new
trader.percent = true
companies = Company.where('code like ?', 'I2%').order(:code).select(:code)
companies.each do |company|

  codes << company.code

  strategy = Sma65Cc3.new
  trader.positions = []
  position =nil
  soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
  soks.each_cons(68) do |sok|
    closes = Soks.parse(sok[0..-2],:close)
    action = strategy.decide(code: company.code, date: sok[-1].date, 
                      closes: closes, open: sok[-1].open, position: position)
    trader.receive [action]
    position = trader.positions.any? ? trader.positions[0] : nil
  end
  trader.summary
end
puts Record.best_latent_gain_in_loose(trader.records)
puts
puts Record.worst_latent_gain_in_win(trader.records)
