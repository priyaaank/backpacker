require 'webmock/rspec'

Dir["lib/**/*.rb"].sort.each {|file| require_relative "../#{file}" }

