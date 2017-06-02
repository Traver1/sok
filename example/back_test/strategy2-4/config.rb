require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './vidya_chart', File.dirname(__FILE__)
include Kabu

@code = ARGV[0]
@code ||= "I201"
@strategy = Vidya.new
@strategy_n = VidyaN.new
@dir_c = File.expand_path "../../../data/strategy2-4/#{@code}/chart"
@dir = File.expand_path "../../../data/strategy2-4/#{@code}"
@chart = SmaChart.new
@exam = Examination.new
