require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './chart', File.dirname(__FILE__)
include Kabu

@code = ARGV[0]
@code ||= "I201"
@strategy = Sma65Cc3.new
@strategy_cbpb = CbPbHighStopLoss.new
@strategy_kama = KamaEmb.new
@strategy_kama.s_len = 4
@strategy_kama.l_len = 30
@strategy_kama.m = 10
dirname = File.basename File.dirname(__FILE__)
@dir_c = File.expand_path "../../../data/#{dirname}/#{@code}/chart"
@dir = File.expand_path "../../../data/#{dirname}/#{@code}"
FileUtils.rm_r @dir if File.exists? @dir
@chart = SmaChart.new
@exam = Examination.new
@exam.targets = %w(1322 1379 2264 2269 3407 4021 5105 5110 5803 5802 3105 4902 7832 7867 9101 9107 3632 3656 8303 8306 8253 8515 1515 1605 3101 3103 4503 4506 3110 5202 5901 3436 7203 7211 9504 9531 9201 9202 2768 8001 8473 8601 8801 3231 1721 1720 3863 3861 5002 5017 5411 5413 5631 6101 4543 7701 9001 9006 9302 9303 3092 3048 7181 8750 2331 2379)
@exam.from = Date.parse '20070101'
@exam.to = Date.parse '20170501'
