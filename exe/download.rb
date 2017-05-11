require File.expand_path '../lib/sok', File.dirname(__FILE__)

if ARGV[0].nil? or ARGV[1].nil?
  puts 'to use download, you need code and year.'
  puts 'ex) sok download 1301 2017'
  exit
end

company = Kabu::Company.find_by_code ARGV[0]

raise 'unexists code in your database:' + ARGV[0] if company.nil? 

soks = 
  Kabu::KDb.download_annualy_csv(company, ARGV[1]).map do |hash|
    Kabu::Sok.new(hash.merge(company: company))
  end

Kabu::Sok.import soks

