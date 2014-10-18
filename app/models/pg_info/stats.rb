require 'pg'
require 'sequel'

module PgInfo
  class Stats
    TEST_CONNECTION_STRING_HEROKU = 'postgres://bunny:Kr0l3ggX@bunnybase.ch3ujgvbn987.us-east-1.rds.amazonaws.com:5432/your_bunny_wrote'
    TEST_CONNECTION_STRING_LOCAL  = 'postgres://127.0.0.1:5432/your_bunny_wrote'

    attr_reader :connection # for debugging

    def initialize(connection)
      @connection = connection
    end

    def get(options = {})
      fail "Please override in a subclass"
    end

    def self.connect(connection_string)
      connection = Sequel.connect(connection_string)
      return self.new(connection)
    end

    def self.test_heroku
      self.connect(TEST_CONNECTION_STRING_HEROKU)
    end

    def self.test_local
      self.connect(TEST_CONNECTION_STRING_LOCAL)
    end

    protected

    def sql(query)
      @connection.fetch(query).to_a
    end

    def sql_option(provided_option, default = '')
      if provided_option
        @connection.literal(provided_option)
      else
        default
      end
    end
  end
end
