Bundler.require
class Command

  def initialize 
    @yahoo = Kabu::Yahoo.new
    @k_db  = Kabu::KDb.new
  end

  def update(options = {})
    args = {"from" => nil, 
            "to"   =>nil,
            "code" =>nil,
            "codefrom" =>nil,
            "stop" => false,
    }.merge(options)
    p args
    args["from"] = Date.parse args["from"]
    args["to"]   = Date.parse args["to"]
    codes  = args["code"] ? 
      [args["code"]] : Kabu::KDb.read_codes
    reader =  @yahoo
    codes.each do |code|
      code = code[0..3]
      next if args["codefrom"] and args["codefrom"] > code 
      while not reader.read_stocks(code, args["from"] ,args["to"])
        sleep 60
      end
      stc_cnt  = 0 
      reader.stocks.each do |stock| 
        stc_cnt += stock.save ? 1 : 0
      end
      spt_cnt  = reader.splits.inject(0) {|s, split| s += split.save ? 1 : 0}
      puts "insert stocks #{code}: #{stc_cnt}/#{reader.stocks.length}"
      puts "insert splits #{code}: #{spt_cnt}/#{reader.splits.length}"
    end
  end

  def schedule
    binding.pry
    #codes  = Kabu::KDb.read_codes
    codes = %w(2540-T 9984-T)
    reader =  @yahoo

    codes.each do |code_market|
      code, market = code_market.split('-')
      company = Kabu::Company.find_by_code code
      if company
        from = company.soks.order(:date).last.date + 1
        to = Date.today
      else
        Kabu::Company.new(code: code, market: market).save
        from = Date.parse('20000101')
        to = Date.today
      end
      while not reader.read_stocks(code, from, to)
        sleep 60
      end
      stc_cnt  = 0 
      reader.stocks.each do |stock| 
        stc_cnt += stock.save ? 1 : 0
      end
      spt_cnt  = reader.splits.inject(0) {|s, split| s += split.save ? 1 : 0}
      puts "insert stocks #{code}: #{stc_cnt}/#{reader.stocks.length}"
      puts "insert splits #{code}: #{spt_cnt}/#{reader.splits.length}"
    end
  end

end

command = Command.new
case ARGV.shift
when "update"
  command.update(ARGV.getopts("",
                             "from:",
                             "to:",
                             "code:",
                             "codefrom:"))
when "schedule"
  command.schedule
else

end
