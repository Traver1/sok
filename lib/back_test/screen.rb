module Kabu

  class Screen

    attr_accessor :strategies, :trader, :actions

    def self.load(path)
      File.open(path, 'rb') do |file|
        Marshal.load(file)
      end
    end

    def self.save(screen, path)
      File.open(path, 'bw') do |file|
        file << Marshal.dump(screen)
      end
    end

    def screen(date=Date.today)
      @actions = []
      @strategies.each do |strategy|
        soks = Sok.joins(:company).where('code=? and date <=?',strategy.code,date).order(:date)
        next if @actions.select{|a|a.code == soks.last.company.code}.nil?
        strategy.soks = Soks[*soks.last(strategy.length)]
        strategy.date = soks.last.date
        strategy.position = @trader.positions.any? ? @trader.positions[0] : nil
        strategy.capital = @trader.capital(false)
        strategy.company = soks.last.company
        strategy.set_env
        @actions << strategy.decide(nil)
        @trader.receive [@actions.last]
      end
      @actions = @actions.select {|a|not a.none?}
      puts @actions; @actions
    end
  end
end
