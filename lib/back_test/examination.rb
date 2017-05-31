module Kabu
  class Examination

    attr_accessor :trader

    def n(strategy)
      wins = []
      codes = []
      companies = Company.where('code like ?', 'I2%').order(:code).select(:code)
      companies.each do |company|
        wins << []
        codes << company.code
        [5,10,15,20,30,50].each do |n|
          trader = Trader.new
          trader.percent = true
          strategy.setup if strategy.respond_to? :setup
          strategy.n = n
          position =nil
          soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
          soks.each_cons(strategy.length) do |sok|
            env = {}
            env[:code] = company.code
            env[:date] = sok[-1].date
            env[:position] = position
            strategy.set_env(Soks[*sok.to_a],env)
            action = strategy.decide(env)
            trader.receive [action]
            position = trader.positions.any? ? trader.positions[0] : nil
          end
          wins[-1] << Record.win_rate(trader.records)
          trader.summary
        end
      end
      wins.zip(codes).each do |win,code|
        puts "|#{[code, win.map{|w|w.round(2).to_s.ljust(4,'0')}].flatten.join("|")}|"
      end
      average = wins.transpose.map do |ns|
        ns.inject(0) {|ret, win| ret += win.to_f }/ ns.length
      end
      puts "#{["    ", average.map{|a|a.round(2).to_s.ljust(4,'0')}].flatten.join("|")}|"
    end

    def plot_recorded_chart(strategy, code, chart, dir)
      trader = Trader.new
      trader.percent = true
      position =nil
      soks = Sok.joins(:company).where('companies.code=?',code).order('date')
      soks.each_cons(strategy.length) do |sok|
        env = {}
        env[:code] = code
        env[:date] = sok[-1].date
        env[:position] = position
        strategy.set_env(Soks[*sok.to_a], env)
        action = strategy.decide(env)
        trader.receive [action]
        position = trader.positions.any? ? trader.positions[0] : nil
      end
      trader.plot_recorded_chart(dir, chart)
    end

    def deviation(strategy)
      net_incomes = []
      dds = []
      wins = []
      averages = []
      pfs = []
      codes = []
      trades = []

      companies = Company.where('code like ?', 'I2%').order(:code).select(:code)

      companies.each do |company|
        codes << company.code
        trader = Trader.new
        trader.percent = true
        strategy.setup if strategy.respond_to? :setup
        position =nil
        soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
        soks.each_cons(strategy.length) do |sok|
          env = {}
          env[:code] = company.code
          env[:date] = sok[-1].date
          env[:position] = position
          strategy.set_env(Soks[*sok.to_a], env)
          action = strategy.decide(env)
          trader.receive [action]
          position = trader.positions.any? ? trader.positions[0] : nil
        end

        trader.summary
        r = trader.records
        net_incomes << Record.net_income(r)
        dds << Record.max_drow_down(r)
        wins << Record.win_rate(r) * 100
        averages << Record.average(r)
        pfs << Record.profit_factor(r)
        trades << Record.trades(r)
      end

      codes.zip(net_incomes,trades,wins,pfs,averages,dds).each do |array|
        puts "|#{array.map{|v| (v.is_a? Float) ? v.round(2) : v}.join("|")}|"
      end

      indecis = [net_incomes, trades, wins, pfs,averages, dds].map do |vs|
        (vs.inject(0){|r,v| r+= v}/vs.length).round(1)
      end 
      puts "|#{["    ", indecis].flatten.join("|")}|"

      indecis = [net_incomes, trades, wins, pfs,averages, dds].map do |vs|
        ave = vs.inject(0){|r,v| r+= v}/vs.length
        (Math.sqrt(vs.inject(0){|r,v|r+=(v-ave)**2}/vs.length)).round(2)
      end 
      puts "|#{["    ", indecis].flatten.join("|")}|"
    end

    def mfe(strategy,dir)
      codes = []
      trader = Trader.new
      trader.percent = true
      companies = Company.where('code like ?', 'I2%').order(:code).select(:code)
      companies.each do |company|
        codes << company.code
        trader.positions = []
        strategy.setup if strategy.respond_to? :setup
        position =nil
        soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
        soks.each_cons(strategy.length) do |sok|
          env = {}
          env[:code] = company.code
          env[:date] = sok[-1].date
          env[:position] = position
          strategy.set_env(Soks[*sok.to_a], env)
          action = strategy.decide(env)
          trader.receive [action]
          position = trader.positions.any? ? trader.positions[0] : nil
        end
        trader.summary
      end

      FileUtils.mkdir_p dir
      histgram_chart = Chart::Histgram.new
      histgram_chart.plot(*Record.best_latent_gain_in_loose(trader.records), dir + '/mfe_loose.jpeg')
      histgram_chart.plot(*Record.worst_latent_gain_in_win(trader.records), dir + '/mfe_win.jpeg')
      xb, bests = Record.best_latent_gain_in_loose(trader.records)
      bests = bests.cumu.insert(0,0)
      xb << Float::NAN
      bests = bests.map {|v| v.to_f/ bests[-1]*100}
      xw, worsts = Record.worst_latent_gain_in_win(trader.records)
      worsts = worsts.cumu.insert(0,0)
      xw << Float::NAN
      worsts = worsts.map {|v| v.to_f/ worsts[-1]*100}
      cumu_chart = Chart::Cumu.new
      cumu_chart.plot(xb,bests, dir + '/cumu_mfe_loose.jpeg')
      cumu_chart.plot(xw,worsts, dir + '/cumu_mfe_win.jpeg')
    end

    def stoploss(stop_strategy, base_strategy, range, dir)
      net_incomes = []
      max_drow_downs = []
      wins = []
      averages = []
      records = []

      companies = Company.where('code like ?', 'I2%').order(:code).select(:code)

      range.each do |loss_cut_line|

        net_incomes << []
        max_drow_downs << []
        wins << []
        averages << []
        records << []

        companies.each do |company|
          trader = Trader.new
          trader.percent = true
          stop_strategy.setup if stop_strategy.respond_to? :setup
          stop_strategy.loss_line = loss_cut_line
          position =nil
          soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
          soks.each_cons(stop_strategy.length) do |sok|
            env = {}
            env[:code] = company.code
            env[:date] = sok[-1].date
            env[:position] = position
            stop_strategy.set_env(Soks[*sok.to_a], env)
            action = stop_strategy.decide(env)
            trader.receive [action]
            position = trader.positions.any? ? trader.positions[0] : nil
          end

          r = trader.records
          net_incomes[-1] << Record.net_income(r)
          max_drow_downs[-1] << Record.max_drow_down(r)
          wins[-1] << Record.wins(r)
          averages[-1] << Record.average(r)
          records[-1] << r
        end
      end

      net_incomes << []
      max_drow_downs << []
      wins << []
      averages << []
      records << []

      companies.each do |company|
        trader = Trader.new
        trader.percent = true
        base_strategy.setup if base_strategy.respond_to? :setup
        position =nil
        soks = Sok.joins(:company).where('companies.code=?',company.code).order('date')
        soks.each_cons(base_strategy.length) do |sok|
          env = {}
          env[:code] = company.code
          env[:date] = sok[-1].date
          env[:position] = position
          base_strategy.set_env(Soks[*sok.to_a], env)
          action = base_strategy.decide(env)
          trader.receive [action]
          position = trader.positions.any? ? trader.positions[0] : nil
        end

        r = trader.records
        net_incomes[-1] << Record.net_income(r)
        max_drow_downs[-1] << Record.max_drow_down(r)
        wins[-1] << Record.wins(r)
        averages[-1] << Record.average(r)
        records[-1]  << r
      end

      FileUtils.mkdir_p dir
      File.open(dir + '/stop_loss_analysis_dump_data', 'wb') do |file|
        file << Marshal.dump([net_incomes, max_drow_downs, wins, averages, records])
      end
    end

    def plot_summary(strategy,code, dir)
      companies = Company.where('code like ?', code).order(:code).select(:code)
      if not @trader 
        @trader = Trader.new
        @trader.bunkrupt = true
        @trader.percent = true
      end
      strategy.setup if strategy.respond_to? :setup
      position =nil
      soks = Sok.joins(:company).where('companies.code=?',code).order('date')
      soks.each_cons(strategy.length) do |sok|
        env = {}
        env[:code] = code
        env[:date] = sok[-1].date
        env[:position] = position
        env[:positions] = @trader.positions
        env[:capital] = @trader.capital(false)
        strategy.set_env(Soks[*sok.to_a],env)
        action = strategy.decide(env)
        @trader.receive [action].flatten
        position = @trader.positions.any? ? @trader.positions[0] : nil
      end
      @trader.summary
      @trader.save(dir)
    end
  end

  class Examination2

    attr_accessor :trader, :from, :to

    def plot_summary(strategy,codes, dir)
      companies = Company.where('code in (?)', codes)
      if not @trader
        @trader = Trader.new
        @trader.bunkrupt = true
        @trader.percent = true
      end
      strategy.setup if strategy.respond_to? :setup
      com_soks(companies).each_cons(strategy.length) do |days|
        validate_order days
        env = {}
        env[:codes] = days[-1].map{|sok| sok ? sok.company.code : nil}.compact
        env[:date] = days[-1].select {|sok| sok}.first.date
        env[:positions] = @trader.positions
        env[:capital] = @trader.capital(false)
        env[:coms] = days.transpose.map { |sok| Soks[*sok] }
        strategy.set_env(env[:coms],env)
        action = strategy.decide(env)
        @trader.receive [action].flatten
        position = @trader.positions.any? ? @trader.positions[0] : nil
      end
      @trader.summary
      @trader.save(dir)
    end

    # length = Companies.length    length = Soks.length
    # [Soks, Soks, Soks ...]    -> [Coms, Coms, Coms ...]
    # (Coms = [Sok, Sok, Sok ... ])
    #
    def com_soks(companies)
      results = companies.map {|com| com.adjusteds}
      maxl = results.inject(results[0].length) do |r,soks|
        r = [soks.length,r].max
      end
      results.length.times do |i|
        (maxl-results[i].length).times do
          resutls[i].insert(0,nil)
        end
      end
      results.transpose
    end

    def validate_order(days)
      date = days[-1][0].date
      days[-1][1..-1].each do |sok|
        if sok and not sok.date == date
          raise 'date order missmatch error'
        end
      end
    end
  end
end
