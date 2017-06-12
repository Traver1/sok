require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './chart', File.dirname(__FILE__)
include Kabu

@code = ARGV[0]
@code ||= "I201"
@strategy = PatternStrategy.new

dirname = File.basename File.dirname(__FILE__)
@strategy_n = PatternStrategyN.new
@strategy_n.pattern = Pattern.double_bottom3
@dir_c = File.expand_path "../../../data/#{dirname}/#{@code}/chart"
@dir = File.expand_path "../../../data/#{dirname}/#{@code}"
FileUtils.rm_r @dir if File.exists? @dir
@chart = SmaChart.new
@exam = Examination.new
