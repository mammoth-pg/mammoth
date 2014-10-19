require 'bundler/setup'
require 'lotus'
require 'active_support/all'

# Shit just got real
require 'logger'
$logger = Logger.new($stdout)

module Mammoth
  class Application < Lotus::Application
    configure do
      load_paths << 'app'

      routes 'config/routes'

      layout :application
    end
  end
end


# FIXME(arp): hopefully Lotus has a better way of loading files...
$LOAD_PATH.unshift(::Mammoth::Application.configuration.root.join('app', 'models'))
$LOAD_PATH.unshift(::Mammoth::Application.configuration.root.join('app', 'controllers'))
$LOAD_PATH.unshift(::Mammoth::Application.configuration.root.join('app', 'layouts'))
