Bundler.require
include Kabu

#codes = (201..233).map {|i| "I#{i}"}
companies = Company.where("not code like 'I%'")
codes = 0.step(companies.length-1, 10).map {|i|companies[i].code}
exam = Examination2.new
exam.targets = %w(1322 1379 2264 2269 3407 4021 5105 5110 5803 5802 3105 4902 7832 7867 9101 9107 3632 3656 8303 8306 8253 8515 1515 1605 3101 3103 4503 4506 3110 5202 5901 3436 7203 7211 9504 9531 9201 9202 2768 8001 8473 8601 8801 3231 1721 1720 3863 3861 5002 5017 5411 5413 5631 6101 4543 7701 9001 9006 9302 9303 3092 3048 7181 8750 2331 2379)
exam.from = Date.parse '20000101'
exam.to = Date.parse '20170501'
strategies = codes.map do |c|
  s = Gap.new
  s.code = c
  s
end
dir = File.expand_path "../../../data/strategy2-7/"
exam.trader = Trader.new
exam.trader.percent = false
exam.trader.capital = 1000000
exam.trader.cost = 0.2
exam.plot_summary(strategies,dir)
puts exam.trader.capital
