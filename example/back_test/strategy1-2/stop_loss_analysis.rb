require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

net_incomes = []
max_drow_downs = []
wins = []
averages = []
records = []

companies = Company.where('code like ?', 'I2%').order(:code).select(:code)

-1.step(-10,-1).each do |loss_cut_line|

  net_incomes << []
  max_drow_downs << []
  wins << []
  averages << []
  records << []

  companies.each do |company|
    trader = Trader.new
    trader.percent = true
    strategy = Sma65Cc3StopLoss.new(loss_cut_line)
    position =nil
    soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
    soks.each_cons(68) do |sok|
      closes = Soks.parse(sok[0..-2],:close)
      action = strategy.decide(code: company.code, date: sok[-1].date, 
                        closes: closes, open: sok[-1].open, position: position)
      trader.receive [action]
      position = trader.positions.any? ? trader.positions[0] : nil
    end

    r = trader.records
    net_incomes[-1] << Record.net_income(r)
    max_drow_downs[-1] << Record.max_drow_down(r)
    wins[-1] << Record.wins(r)
    averages[-1] << Record.average(r)
    records[-1] << r
  end
end

net_incomes << []
max_drow_downs << []
wins << []
averages << []
records << []

companies.each do |company|
  trader = Trader.new
  trader.percent = true
  strategy = Sma65Cc3.new
  position =nil
  soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
  soks.each_cons(68) do |sok|
    closes = Soks.parse(sok[0..-2],:close)
    action = strategy.decide(code: company.code, date: sok[-1].date, 
                      closes: closes, open: sok[-1].open, position: position)
    trader.receive [action]
    position = trader.positions.any? ? trader.positions[0] : nil
  end

  r = trader.records
  net_incomes[-1] << Record.net_income(r)
  max_drow_downs[-1] << Record.max_drow_down(r)
  wins[-1] << Record.wins(r)
  averages[-1] << Record.average(r)
  records[-1]  << r
end


dir = File.expand_path '../../../data/strategy1-2', File.dirname(__FILE__)
FileUtils.mkdir_p dir
File.open(dir + '/stop_loss_analysis_dump_data', 'wb') do |file|
  file << Marshal.dump([net_incomes, max_drow_downs, wins, averages, records])
end
