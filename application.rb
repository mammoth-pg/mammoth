require 'bundler'

Bundler.setup

require 'lotus'

module Mammoth
  class Application < Lotus::Application
    ROOT = Pathname.new(File.expand_path(__dir__, '../..')).dirname.realpath

    configure do
      load_paths << 'app'

      layout :application
      routes 'config/routes'
    end
  end
end
