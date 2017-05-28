Bundler.require
bunk = Kabu::Bunkrupt.new

pf = 1.step(3, 0.5).to_a
puts "||#{pf.join('|')}|"
25.step(50,5).each do |win|
  line = [win]
  1.step(3, 0.5).each do |pf|
    bunk.pf = pf
    bunk.win = win.to_f / 100
    bunk.risk = 0.02
    bunk.span = 1000
    bunk.n = 1000
    line << bunk.simulate.round(1)
  end
  puts "|#{line.join('|')}|"
end
