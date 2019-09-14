require File.expand_path '../lib/sok', File.dirname(__FILE__)

if ARGV[0].nil? or ARGV[1].nil? or ARGV[2].nil?
  puts 'to use dump, you need code,from,to'
  puts 'ex) sok download 1301 20170101 20170501'
  exit
end


puts Kabu::Sok.joins(:company).where(
      'code = ? and date >= ? and date <= ?',
      ARGV[0], Date.parse(ARGV[1]), Date.parse(ARGV[2]
    ))
