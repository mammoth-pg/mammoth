require 'bundler/setup'
require 'lotus'
require 'active_support/all'

# Shit just got real
require 'logger'
$logger = Logger.new($stdout)

module Mammoth
  class Application < Lotus::Application
    #ROOT = Pathname.new(File.expand_path(__dir__, '../..')).dirname.realpath

    configure do
      load_paths << 'app'

      routes 'config/routes'

      layout :application
    end
  end
end


# FIXME(arp): hopefully Lotus has a better way of loading files...
$LOAD_PATH.unshift(::Mammoth::Application.configuration.root.join('app', 'models'))
# FIXME(vessi): hopefully Lotus has a better way of passing default engine

class Lotus::Commands::Console
  def default_engine; ['pry', 'Pry']; end
end
