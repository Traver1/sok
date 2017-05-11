module Kabu
  class KDb

    def self.download_annualy_csv(company, year)
      ret = []
      url = "http://k-db.com/stocks/#{company.to_s}/1d/#{year}?download=csv"
      open(url) do |page|
        puts page
        lines = page.readlines[1..-1]
        raise 'csv was not found at:' + url if lines.nil?
        lines.map do |line|
          date, open, high, low, close, volume, = line.split(',')
          ret << { 
            date: Date.parse(date),
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume}
        end
      end
      ret
    end

    def self.read_codes
      open("http://k-db.com/stocks/?download=csv") do |r|
        r.readlines[2..-1].map do |line|
          line.split(',')[0]
        end
      end
    end
  end
end
