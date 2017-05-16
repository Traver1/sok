require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

class Sample1Strategy

  def decide(env)
    close = env[:close]
    date = env[:date]
    code = env[:code]

    case date.strftime('%Y%m%d')
    when '20160317'
      Action::Buy.new(code, date, close, 1)
    when '20160330'
      Action::Sell.new(code, date, close, 2)
    when '20160425'
      Action::Buy.new(code,date, close, 2)
    when '20160510'
      Action::Sell.new(code ,date, close, 1)
    else
      Action::None.new(code)
    end
  end
end

trader = Trader.new
strategy = Sample1Strategy.new

code = 1305
soks = Sok.joins(:company).where('companies.code=?',code).order('date')

soks.each do |sok|
  action = strategy.decide(code: code, date: sok.date, close: sok.close)
  trader.receive [action]
end

trader.summary
dir = File.expand_path('../../../data/test/sample2', File.dirname(__FILE__))
trader.save dir
trader.plot_recorded_chart dir + '/chart'
