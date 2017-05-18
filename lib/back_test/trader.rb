module Kabu
  class Trader

    attr_accessor :records, :positions

    def initialize
      @positions = []
      @records = []
      @cost = 20
    end

    def receive(actions)
      contract_to_current_position actions
      increese_term
      contract_remain actions
    end

    def increese_term
      @positions.each do |position|
        position.term += 1
      end
    end

    def contract_to_current_position(actions)
      closesd = []
      each_positions(actions) do |code, action, position|
        if (position.sell? and action.buy?) or
          (position.buy? and action.sell?)
          next if action.volume <= 0
          contracted = [position.volume, action.volume].min
          if position.volume == contracted
            action.volume -= contracted
            closesd << position
          else
            position.volume -= contracted
            action.volume = 0
          end
          @records << Record.new( code,
            position.gain(action.price, contracted),
            position.term, contracted,
            position.date, action.date,
            position.buy? ? :buy : :sell )
        end
      end
      @positions -= closesd
    end

    def contract_remain(actions)
      actions.each do |action|
        if not action.none? and action.volume > 0 
          if action.buy?
            @positions << Position::Buy.new(action.code, action.date, 
                                            action.price, action.volume)
          elsif action.sell?
            @positions << Position::Sell.new(action.code, action.date, 
                                             action.price, action.volume)
          end
          action.volume = 0
        end
      end
    end

    def each_positions(actions)
      actions.group_by {|a| a.code}.each do |code, action|
        action = action[0]
        sorted = @positions.find_all {|p| p.code == code }.sort {|a,b| a.date <=> b.date }
        sorted.each do |position|
          yield code, action, position
        end
      end
    end

    def summary
      if @records.any?
        net_income = Record.net_income(@records)
        profit = Record.profit(@records)
        loss = Record.loss(@records)
        profit_factor = Record.profit_factor(@records)
        max_profit = Record.max_profit(@records)
        max_loss = Record.max_loss(@records)
        trades = Record.trades(@records)
        wins = Record.wins(@records)
        looses = Record.looses(@records)
        win_rate = Record.win_rate(@records)
        max_series_of_wins = Record.max_series_of_wins(@records)
        max_series_of_looses = Record.max_series_of_looses(@records)
        average_posess_term_of_win = Record.average_posess_term_of_win(@records)
        average_posess_term_of_loose = Record.average_posess_term_of_loose(@records)
        max_drow_down = Record.max_drow_down(@records)

        puts "======================================================"
        puts "net income:               #{net_income}"
        puts "profit | loss:            #{profit}    | #{loss}"
        puts "pf:                       #{profit_factor.round(1)}"
        puts "max profit | max loss:    #{max_profit}     | #{max_loss}"
        puts "trades | wins | looses:   #{trades}     | #{wins}     | #{looses}"
        puts "wins{%}                   #{(win_rate * 100).round(1)}"
        puts "max series of wins:       #{max_series_of_wins}"
        puts "max series of looses:     #{max_series_of_looses}"
        puts "average span{win}:        #{average_posess_term_of_win}"
        puts "average span{loose}:      #{average_posess_term_of_loose}"
        puts "max drow down:            #{max_drow_down}"
        puts "======================================================"
      else
        puts "======================================================"
        puts "no trade"
        puts "======================================================"
      end
      puts
    end

    def save(dir)
      FileUtils.mkdir_p dir
      File.open(dir+'/record', 'wb') do |file|
        file << Marshal.dump(self)
      end
      file_path = dir + '/profit_curve.jpeg'
      Chart::ProfitCurve.new.plot(@records, file_path)
      file_path = dir + '/profit_histgram.jpeg'
      Chart::ProfitHistgram.new.plot(@records, file_path)
      file_path = dir + '/monthly_profit.jpeg'
      Chart::MonthlyProfit.new.plot(@records, file_path)
    end

    def plot_recorded_chart(dir)
      FileUtils.mkdir_p dir
      @records.each do |record|
        file_path = dir + "/#{record.code}_#{record.from.strftime('%Y%m%d')}_#{record.to.strftime('%Y%m%d')}.jpeg"
        Chart::RecordedChart.new.plot(record, file_path)
      end
    end
  end
end
