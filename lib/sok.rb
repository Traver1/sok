require 'bundler'
require 'open-uri'
Bundler.require
Dir[File.expand_path('../sok', __FILE__) << '/*.rb'].each do |file|
  require file
end
Dir[File.expand_path('../back_test', __FILE__) << '/*.rb'].each do |file|
  require file
end
Dir[File.expand_path('../back_test/strategy', __FILE__) << '/*.rb'].each do |file|
  require file
end

env = (ENV["RAILS_ENV"] or "development")

db_config = YAML.load_file File.expand_path('../db/config.yml', File.dirname(__FILE__))
db_config[env]['database'] = File.expand_path('../' + db_config[env]['database'] , File.dirname(__FILE__) )
ActiveRecord::Base.establish_connection db_config[env]
