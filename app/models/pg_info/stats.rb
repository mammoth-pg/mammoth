require 'pg'
require 'sequel'

module PgInfo
  class Stats
    TEST_CONNECTION_STRING_HEROKU = 'postgres://bunny:Kr0l3ggX@bunnybase.ch3ujgvbn987.us-east-1.rds.amazonaws.com:5432/your_bunny_wrote'
    TEST_CONNECTION_STRING_LOCAL  = 'postgres://127.0.0.1:5432/your_bunny_wrote'

    COMMON_CONNECTION_OPTIONS = {
      :logger => $logger,
      :sql_log_level => :debug
    }.freeze

    attr_reader :connection # for debugging

    def initialize(connection)
      @connection = connection
    end

    def get(options = {})
      fail "Please override in a subclass"
    end

    def self.connect(connection_string)
      connection = Sequel.connect(connection_string, COMMON_CONNECTION_OPTIONS)
      return self.new(connection)
    end

    def self.test_heroku
      @@test_heroku_connection ||= self.connect(TEST_CONNECTION_STRING_HEROKU)
    end

    def self.test_local
      @@test_local_connection ||= self.connect(TEST_CONNECTION_STRING_LOCAL)
    end

    protected

    def sql(query)
      @connection.fetch(query).to_a
    end

    def sql_option(provided_options, default = '')
      sanitized_options = if provided_options
        Array(provided_options).map { |option|
          @connection.literal(option)
        }
      else
        Array(default)
      end

      return sanitized_options.join(", ")
    end
  end
end
