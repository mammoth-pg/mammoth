require 'bundler/setup'
require 'lotus'

module Mammoth
  class Application < Lotus::Application
    ROOT = Pathname.new(File.expand_path(__dir__, '../..')).dirname.realpath

    configure do
      load_paths << 'app'

      routes 'config/routes'

      layout :application
    end
  end
end

::Mammoth::Application.configuration.load_paths << 'app/models'
