require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

class Sma65Cc3

  def decide(env)
    code = env[:code]
    date = env[:date]
    closes = env[:closes]
    open = env[:open]
    position = env[:position]

    aves = closes[-67..-1].ave(65)
    is_buy = 3.times.inject(true) do |ret, i|
      ret = (ret and (closes[-1-i] > aves[-i-1]))
    end

    is_sell = 3.times.inject(true) do |ret, i|
      ret = (ret and (closes[-1-i] < aves[-i-1]))
    end

    if not position.nil? and position.buy?
      if is_sell
        Action::Sell.new(code,date,open,2)
      else
        Action::None.new(code,open)
      end
    elsif not position.nil? and position.sell?
      if is_buy
        Action::Buy.new(code,date,open,2)
      else
        Action::None.new(code,open)
      end
    else
      if is_buy
        Action::Buy.new(code,date,open,1)
      elsif is_sell
        Action::Sell.new(code,date,open,1)
      else
        Action::None.new(code,open)
      end
    end
  end
end

class Chart
  def plot(record, file_path)
    soks = Sok.joins(:company).where('companies.code=? and date >= ? and date <= ?',
                                     record.code, 
                                     record.from - 120,
                                     record.to + 20,
                                    ).order('date')
    
    dates = Kabu::Soks.parse(soks,:date)
    values = Kabu::Soks.parse(soks,:open,:high,:low,:close)
    closes = values[3]
    bols = closes.bol(65)
    marks = Soks.new
    dates.zip(closes).each do |date, close|
      marks << case date
      when record.from, record.to
        close
      else
        Float::NAN
      end
    end

    case record.position
    when :buy
      mark_point = '9'
    when :sell
      mark_point = '11'
    end

    dates, values, bols, marks = Soks.cut_off_tail(
      dates, values, bols, marks )
    up_stick, down_stick = values.split_up_and_down_sticks

    Numo.gnuplot do
      reset
      set terminal: 'jpeg'
      set output:  file_path
      set yrange: (values+bols[1..2]).yrange
      set lmargin: 8
      set rmargin: 2
      set bmargin: true
      set xtics: dates.xtics
      set grid: true
      set grid: true
      plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
        [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
        [dates.x, marks.y, with: :points, notitle: true, pt: mark_point, ps: 2, lc: "'dark-green'"],
        [dates.x, bols[0].y, with: :lines, notitle: true, lc: "'salmon'"],
        [dates.x, bols[1].y, with: :lines, notitle: true, lc: "'salmon'", lt: 0],
        [dates.x, bols[2].y, with: :lines, notitle: true, lc: "'salmon'", lt: 0],
        [dates.x, bols[3].y, axes: :x1y2, with: :lines, notitle: true, lc: "'orange'"]
    end
  end
end

codes = []
net_incomes = []
trades = []
wins = []
pfs = []
averages = []
dds = []

companies = Company.where('code like ?', 'I2%').order(:code).select(:code)
companies.each do |company|

  codes << company.code

  trader = Trader.new
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
  trader.summary

  net_incomes << Record.net_income(trader.records)
  trades << Record.trades(trader.records)
  wins << Record.win_rate(trader.records)
  pfs << Record.profit_factor(trader.records)
  averages << Record.average(trader.records)
  dds << Record.max_drow_down(trader.records)

  #dir = File.expand_path "../../../data/strategy1-1/record/#{company.code}", File.dirname(__FILE__)
  #FileUtils.mkdir_p dir
  #trader.plot_recorded_chart(dir,Chart.new)
end

codes.zip(net_incomes,trades,wins,pfs,averages,dds).each do |array|
  puts "|#{array.map{|v| (v.is_a? Float) ? v.round(2) : v}.join("|")}|"
end

indecis = [net_incomes, trades, wins, pfs,averages, dds].map do |vs|
  (vs.inject(0){|r,v| r+= v}/vs.length).round(1)
end 
puts "|#{["    ", indecis].flatten.join("|")}|"
