require 'webmock/rspec'
require 'json'
require 'mongoid'
require 'database_cleaner'
require 'timecop'

Dir["lib/**/*.rb"].sort.each {|file| require_relative "../#{file}" }
Mongoid.load!("./config/mongoid.yml", :test)
#Mongoid.logger = Logger.new($stdout)
#Moped.logger = Logger.new($stdout)

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
