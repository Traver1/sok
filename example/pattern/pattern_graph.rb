Bundler.require
include Kabu

dir_path = File.expand_path "../../data/pattern/sample1", File.dirname(__FILE__)
FileUtils.rm_r dir_path if File.exists? dir_path
FileUtils.mkdir_p dir_path 

pattern = Pattern.pull_back1
v = pattern.pattern
file_path = dir_path + "/pull_back_pattern.jpeg"

Numo.gnuplot do
  reset
  set terminal: 'jpeg'
  set output:  file_path
  set grid: true
  plot [v.length.times.to_a, v, with: :line, lt: 2, notitle: true]
end
