require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

class Sma65Cc3

  def initialize(n)
    @n = n
  end

  def decide(env)
    code = env[:code]
    date = env[:date]
    closes = env[:closes]
    open = env[:open]
    position = env[:position]

    aves = closes[-67..-1].ave(65)
    is_buy = 3.times.inject(true) do |ret, i|
      ret = ret and (closes[-i-1] > aves[-i-1])
    end

    if not position.nil? and position.buy?
      if position.term >= @n
        Action::Sell.new(code,date,open,1)
      else
        Action::None.new(code,open)
      end
    else
      if is_buy
        Action::Buy.new(code,date,open,1)
      else
        Action::None.new(code,open)
      end
    end
  end
end

wins = []
codes = []
companies = Company.where('code like ?', 'I2%').order(:code).select(:code)
companies.each do |company|

  wins << []
  codes << company.code

  [5,10,15,20,30,50].each do |n|
    trader = Trader.new
    strategy = Sma65Cc3.new(n)

    position =nil
    soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
    soks.each_cons(68) do |sok|
      closes = Soks.parse(sok[0..-2],:close)
      action = strategy.decide(code: company.code, date: sok[-1].date, 
                        closes: closes, open: sok[-1].open, position: position)
      trader.receive [action]
      position = trader.positions.any? ? trader.positions[0] : nil
    end

    wins[-1] << Record.win_rate(trader.records)
    trader.summary
    #trader.save File.expand_path("../../../data/back_test/sma65cc3/#{company.code}/#{n}", File.dirname(__FILE__))
  end
end


wins.zip(codes).each do |win,code|
  puts "|#{[code, win.map{|w|w.round(2).to_s.ljust(4,'0')}].flatten.join("|")}|"
end

average = wins.transpose.map do |ns|
  ns.inject(0) {|ret, win| ret += win.to_f }/ ns.length
end
puts "#{["    ", average.map{|a|a.round(2).to_s.ljust(4,'0')}].flatten.join("|")}|"

