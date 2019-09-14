require File.expand_path '../lib/sok', File.dirname(__FILE__)

data = 
  Kabu::KDb.read_codes.map do |code_market|
    code, market = code_market.split('-')
    [code, market]
  end

output_file_path = File.expand_path '../db/seeds.rb', File.dirname(__FILE__)

File.open(output_file_path, 'w') do |file|
  file << "require File.expand_path '../lib/sok', File.dirname(__FILE__)\n"
  data.each do |code, market|
    file << "Kabu::Company.new(code: '#{code}', market: '#{market}').save\n"
  end
end

data =
  Kabu::KDb.read_indecies.map do |code|
    [code, " "]
  end

File.open(output_file_path, 'a') do |file|
  data.each do |code, market|
    file << "Kabu::Company.new(code: '#{code}', market: '#{market}').save\n"
  end
end
