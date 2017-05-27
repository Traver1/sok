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
      next if args["codefrom"] and args["codefrom"] > code 
      while not reader.read_stocks(code, args["from"] ,args["to"])
        sleep 60
      end
      stc_cnt  = 0 
      reader.stocks.each do |stock| 
        stc_cnt += stock.save
      end
      spt_cnt  = reader.splits.inject(0) {|s, split| s += split.save}
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
else
end
