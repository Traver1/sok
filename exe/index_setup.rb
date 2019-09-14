require File.expand_path '../lib/sok', File.dirname(__FILE__)

companies = Kabu::Company.where('code like  ?', 'I%')
companies.each do |company|
  2007.step(2017,1).each do |year|
    soks = 
      Kabu::KDb.download_annualy_csv(company, year, :indices).map do |hash|
        Kabu::Sok.new(hash.merge(company: company))
      end

    sleep 10
    begin
      Kabu::Sok.import soks
    rescue => ex
      puts ex
    end
  end
end
