Bundler.require
include Kabu

def plot(soks, file_path)
  dates = Soks.parse(soks,:date)
  values = Soks.parse(soks,:open,:high,:low,:close)
  up_stick, down_stick = values.split_up_and_down_sticks

  marks = []
  values[0].each_with_index do |o,i|
    marks << (i == 49 ? o : Float::NAN)
  end

  Numo.gnuplot do
    reset
    set terminal: 'jpeg'
    set output:  file_path
    set xtics: dates.xtics
    set grid: true
    plot [dates.x, *up_stick.y, with: :candlesticks, lt: 6, notitle: true],
      [dates.x, *down_stick.y, with: :candlesticks, lt: 7, notitle: true],
      [dates.x, marks, with: :point, pt: 2, ps: 5,  notitle: true]
  end
end


dir_path = File.expand_path "../../data/pattern/sample1", File.dirname(__FILE__)
FileUtils.rm_r dir_path if File.exists? dir_path
FileUtils.mkdir_p dir_path 

pattern = Pattern.pull_back2
pattern.thr = 1.3
(201..233).each do |code|
  com = Company.find_by_code 'I' + code.to_s
  com.soks.each_cons(70) do |soks|
    close = Soks.parse(soks[0..49],:close)
    low = Soks[*soks[35..49]].low(15)[-1]
    if pattern.correspond?(close) and low == soks[49].low
      file_path = dir_path + "/#{soks[-1].company.code}_#{soks[-1].date}.jpeg"
      puts "#{soks[-1].company.code}/#{soks[-1].date}"
      plot(soks, file_path)
    end
  end
end
