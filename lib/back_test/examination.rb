module Kabu
  class Examination

    attr_accessor :trader, :targets, :from, :to

    def initialize
      @targets = (201..233).map {|s| "I#{s}"}
    end

    def n(strategy)
      wins = []
      codes = []
      records = Soks.new(6,[])
      companies = Company.where('code in (?)', @targets).order(:code).select(:code)
      companies.each do |company|
        next if codes.include? company.code
        wins << []
        codes << company.code
        strategy.code = company.code
        [5,10,15,20,30,50].each_with_index do |n,i|
          @trader = Trader.new
          @trader.percent = true
          strategy.setup if strategy.respond_to? :setup
          strategy.n = n
          soks = select_soks(company.code)
          soks.each_cons(strategy.length) do |sok|
            set_env(sok.last.date, sok, strategy)
            action = strategy.decide(nil)
            @trader.receive [action]
          end
          wins[-1] << Record.win_rate(@trader.records)
          records[i] += @trader.records
          @trader.summary
        end
      end
      wins.zip(codes).each do |win,code|
        puts "|#{[code, win.map{|w|w.round(2).to_s.ljust(4,'0')}].flatten.join("|")}|"
      end
      puts "#{["    ", records.map{|a|Record.win_rate(a).round(2).to_s.ljust(4,'0')}].flatten.join("|")}|"
    end

    def select_soks(code)
      args = []
      args << code
      args << @to if @to
      args << @from if @from
      if Sok.joins(:company,:split).where('companies.code=?',code).length > 0
        com = Company.where('code=?',code)
        com.first.adjusteds(from, to)
      else
        query = "companies.code=?"
        query += 'and date <= ?' if @to
        query += 'and date >= ?' if @from
        Sok.joins(:company).where(query,*args).order('date')
      end
    end

    def plot_recorded_chart(strategy, code, chart, dir)
      @trader = Trader.new
      @trader.percent = true
      strategy.code = code
      strategy.setup if strategy.respond_to? :setup
      soks = select_soks(code)
      soks.each_cons(strategy.length) do |sok|
        set_env(sok.last.date, sok, strategy)
        action = strategy.decide(nil)
        @trader.receive [action]
      end
      @trader.plot_recorded_chart(dir, chart)
    end

    def deviation(strategy)
      net_incomes = []
      dds = []
      wins = []
      averages = []
      pfs = []
      codes = []
      trades = []

      companies = Company.where('code in (?)', @targets).order(:code).select(:code)

      companies.each do |company|
        next if codes.include? company.code
        codes << company.code
        @trader = Trader.new
        @trader.percent = true
        strategy.code = company.code
        strategy.setup if strategy.respond_to? :setup
        soks = select_soks(company.code)
        soks.each_cons(strategy.length) do |sok|
          set_env(sok.last.date, sok, strategy)
          action = strategy.decide(nil)
          @trader.receive [action]
        end

        @trader.summary
        r = @trader.records
      
        net_incomes << Record.net_income(r).to_f
        dds << Record.max_drow_down(r).to_f
        wins << (Record.win_rate(r) * 100).to_f
        averages << Record.average(r).to_f
        pfs << Record.profit_factor(r).to_f
        trades << Record.trades(r).to_f
      end

      codes.zip(net_incomes,trades,wins,pfs,averages,dds).each do |array|
        puts "|#{array.map{|v| (v.is_a? Float) ? v.round(2) : v}.join("|")}|"
      end

      indecis = [net_incomes, trades, wins, pfs,averages, dds].map do |vs|
        (vs.inject(0){|r,v| r+= v.finite? ? v : 0}/vs.select{|s|s.finite?}.length).round(1)
      end 
      puts "|#{["    ", indecis].flatten.join("|")}|"

      indecis = [net_incomes, trades, wins, pfs,averages, dds].map do |vs|
        ave = vs.inject(0){|r,v| r+= v.finite? ? v : 0}/vs.select{|s|s.finite?}.length
        (Math.sqrt(vs.inject(0){|r,v|r+= v.finite? ? (v-ave)**2 : 0}/vs.select{|s|s.finite?}.length)).round(2)
      end 
      puts "|#{["    ", indecis].flatten.join("|")}|"
    end

    def mfe(strategy,dir)
      codes = []
      @trader = Trader.new
      @trader.percent = true
      companies = Company.where('code in (?)', @targets).order(:code).select(:code)
      companies.each do |company|
        next if codes.include? company.code
        codes << company.code
        @trader.positions = []
        strategy.code = company.code
        strategy.setup if strategy.respond_to? :setup
        soks = select_soks(company.code)
        soks.each_cons(strategy.length) do |sok|
          set_env(sok.last.date, sok, strategy)
          action = strategy.decide(nil)
          @trader.receive [action]
        end
        @trader.summary
      end

      FileUtils.mkdir_p dir
      histgram_chart = Chart::Histgram.new
      histgram_chart.plot(*Record.best_latent_gain_in_loose(@trader.records), dir + '/mfe_loose.jpeg')
      histgram_chart.plot(*Record.worst_latent_gain_in_win(@trader.records), dir + '/mfe_win.jpeg')
      xb, bests = Record.best_latent_gain_in_loose(@trader.records)
      bests = bests.cumu.insert(0,0)
      xb << Float::NAN
      bests = bests.map {|v| v.to_f/ bests[-1]*100}
      xw, worsts = Record.worst_latent_gain_in_win(@trader.records)
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

      companies = Company.where('code in (?)', @targets).order(:code).select(:code)

      range.each do |loss_cut_line|

        net_incomes << []
        max_drow_downs << []
        wins << []
        averages << []
        records << []

        companies.each do |company|
          @trader = Trader.new
          @trader.percent = true
          stop_strategy.code = company.code
          stop_strategy.setup if stop_strategy.respond_to? :setup
          stop_strategy.loss_line = loss_cut_line
          soks = select_soks(company.code)
          soks.each_cons(stop_strategy.length) do |sok|
            set_env(sok.last.date, sok, stop_strategy)
            action = stop_strategy.decide(nil)
            @trader.receive [action]
          end

          r = @trader.records
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
        @trader = Trader.new
        @trader.percent = true
        base_strategy.code = company.code
        base_strategy.setup if base_strategy.respond_to? :setup
        soks = select_soks(company.code)
        soks.each_cons(base_strategy.length) do |sok|
          set_env(sok.last.date, sok, base_strategy)
          action = base_strategy.decide(nil)
          @trader.receive [action]
        end

        r = @trader.records
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
      if not @trader 
        @trader = Trader.new
        @trader.bunkrupt = true
        @trader.percent = true
      end
      strategy.code = code
      strategy.setup if strategy.respond_to? :setup
      soks = select_soks(company.code)
      soks.each_cons(strategy.length) do |sok|
        set_env sok[-1].date, sok, strategy
        action = strategy.decide(nil)
        @trader.receive [action].flatten
      end
      @trader.summary
      @trader.save(dir)
    end

    def scramble(strategy, code, n)
      net_incomes = []
      dds = []
      wins = []
      averages = []
      pfs = []
      trades = []

      com = Company.find_by_code code
      soks = com.soks

      10.times do 

        diffs = Soks.new
        shuffled = Soks.new

        soks.each_cons(2) do |prev,curnt|
          pc = prev.close
          diffs << [curnt.open/pc, curnt.high/pc, curnt.low/pc, curnt.close/pc]
        end

        shuffled << soks[-1]
        (n-1).times do 
          i = Random.rand(soks.length-1)
          pc = shuffled[-1].close
          s = Sok.new
          s.open = diffs[i][0] * pc
          s.high = diffs[i][1] * pc
          s.low = diffs[i][2] * pc
          s.close = diffs[i][3] * pc
          shuffled << s
        end

        @trader = Trader.new
        @trader.percent = true
        strategy.setup if strategy.respond_to? :setup
        shuffled.each_cons(strategy.length) do |sok|
          set_env(sok.last.date, sok, strategy)
          action = strategy.decide(nil)
          @trader.receive [action]
        end
        r = @trader.records
        net_incomes << Record.net_income(r)
        dds << Record.max_drow_down(r)
        wins << Record.win_rate(r) * 100
        averages << Record.average(r)
        pfs << Record.profit_factor(r)
        trades << Record.trades(r)
        @trader.summary
      end

      10.times.to_a.zip(net_incomes,trades,wins,pfs,averages,dds).each do |array|
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

    def set_env(date, sok, strategy)
      strategy.date = date
      strategy.position = @trader.positions.any? ? @trader.positions[0] : nil
      strategy.capital = @trader.capital(false)
      strategy.company = sok.last.company
      strategy.soks = Soks[*sok]
      strategy.set_env
    end
  end

  class Examination2

    attr_accessor :trader, :from, :to

    def plot_summary(strategies, dir)
      codes = strategies.map {|s| s.code}
      companies = Company.where('code in (?)', codes)
      if not @trader
        @trader = Trader.new
        @trader.bunkrupt = true
        @trader.percent = true
      end
      @trader.off_increse_term = true
      strategies.each {|s| s.setup if s.respond_to? :setup}
      strategies.each {|s| s.company = companies.select{|c|c.code == s.code}.first}
      max = strategies.inject(0) {|m,s|[m,s.length].max}
      query = 'companies.code in (?)'
      query += ' and date >= ?' if from
      query += ' and date <= ?' if to
      args = [codes]
      args << from if from
      args << to if to
      dates = Sok.joins(:company).where(query,*args).order(:date).group(:date).select(:date)
      soks_pool = codes.inject({}) {|h,c| h.update c=>[]}
      dates.each do |sok|
        date = sok.date
        select_values(codes, date, soks_pool, max)
        strategies.each do |strategy|
          set_env(date, soks_pool, strategy)
        end
        strategies.select{|s| s.pass?}.sort.each do |strategy|
          next if soks_pool[strategy.code].length < max
          next if not soks_pool[strategy.code].last.date == date
          strategy.capital = @trader.capital(false)
          action = strategy.decide(nil)
          @trader.receive [action].flatten
        end
        @trader.increese_term
        puts [date, @trader.capital(true).round(1), @trader.positions.length].join(' ')
      end
      @trader.summary
      @trader.save(dir)
    end

    def set_env(date, soks_pool, strategy)
      return if soks_pool[strategy.code].empty? or not soks_pool[strategy.code].last.date == date
      strategy.date = date
      positions = @trader.positions.select {|p| p.code == strategy.code}
      strategy.position = positions.any? ? positions[0] : nil
      strategy.capital = @trader.capital(false)
      strategy.soks = Soks[*soks_pool[strategy.code]]
      strategy.set_env
    end

    def select_values(codes, date, soks_pool, max)
      Sok.find_by_sql(["select * from soks, (select * from companies where code in (?)) a where soks.company_id = a.id and date = ?", codes, date]).each do |sok|
        pool = soks_pool[sok.company.code]
        next if pool.last and pool.last.date == sok.date
        sok.adjust_values! pool.last.rate if pool.any?
        pool << sok
        pool.shift if pool.length > max
      end
      soks_pool
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
          results[i].insert(0,nil)
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
