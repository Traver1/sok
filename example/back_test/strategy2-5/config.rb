require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './vidya_chart', File.dirname(__FILE__)
include Kabu

@code = ARGV[0]
@code ||= "I201"
@strategy = ExpMaStrategy.new


dirname = File.basename File.dirname(__FILE__)
@strategy_n = DevTAt.new
@dir_c = File.expand_path "../../../data/#{dirname}/#{@code}/chart"
@dir = File.expand_path "../../../data/#{dirname}/#{@code}"
FileUtils.rm_r @dir if File.exists? @dir
@chart = SmaChart.new
@exam = Examination.new
