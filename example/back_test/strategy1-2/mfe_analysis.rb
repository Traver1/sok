require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
include Kabu

def plot(x, y, file_path, ytics: nil)
	count = [10, x.length].min
	step = x.length / count
	step = 1 if step == 0
	xlabels = []
	x.each_with_index do |label,i|
		xlabels << "\"#{label.round(1)}\" #{i}" if i % step == 0
	end
	xtics = "(#{xlabels.join(',')})"

	Numo.gnuplot do
		reset
		set terminal: 'jpeg'
		set output:  file_path
		set yrange: (0..100)
		set ytics: '(0,10, 50, 80, 100)'
		set lmargin: 8
		set rmargin: 2
		set bmargin: true
		set xtics: xtics
		set grid: true
		plot [x.length.times.to_a, y.y, with: :lines, lt: 1, lc: "'black'", notitle: true]
		unset logscale: :y
	end
end


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

dir = File.expand_path '../../../data/strategy1-2', File.dirname(__FILE__)
FileUtils.mkdir_p dir
histgram_chart = Chart::Histgram.new
histgram_chart.plot(*Record.best_latent_gain_in_loose(trader.records), dir + '/mfe_loose.jpeg')
histgram_chart.plot(*Record.worst_latent_gain_in_win(trader.records), dir + '/mfe_win.jpeg')
xb, bests = Record.best_latent_gain_in_loose(trader.records)
bests = bests.cumu.insert(0,0)
xb << Float::NAN
bests = bests.map {|v| v.to_f/ bests[-1]*100}
xw, worsts = Record.worst_latent_gain_in_win(trader.records)
worsts = worsts.cumu.insert(0,0)
xw << Float::NAN
worsts = worsts.map {|v| v.to_f/ worsts[-1]*100}
plot(xb,bests, dir + '/cumu_mfe_loose.jpeg', ytics: '(0,10,20,50,80,90,100)')
plot(xw,worsts, dir + '/cumu_mfe_win.jpeg')
