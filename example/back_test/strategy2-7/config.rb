require File.expand_path '../../../lib/sok', File.dirname(__FILE__)
require File.expand_path './chart', File.dirname(__FILE__)
include Kabu

@code = ARGV[0]
@code ||= "I201"
@strategy = Gap.new

dirname = File.basename File.dirname(__FILE__)
@dir_c = File.expand_path "../../../data/#{dirname}/#{@code}/chart"
@dir = File.expand_path "../../../data/#{dirname}/#{@code}"
FileUtils.rm_r @dir if File.exists? @dir
@chart = SmaChart.new
@exam = Examination.new
@exam.targets = %w(1301 1377 2229 2269 3407 4021 5186 5191 5726 5857 3105 4902 7862 7867 9101 9107 3632 3636 8303 8306 8253 8439 1515 1605 3101 3103 4503 4506 3110 5202 5901 5909 7203 7211 9504 9531 9201 9202 2692 2874 8473 8601 8801 3458 1721 1720 3863 3861 5002 5017 5411 5413 5631 6101 4543 7701 9001 9006 9302 9303 2792 2678 7181 8750 2127 2168)
