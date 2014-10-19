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
      connection = connection_cache(connection_string)
      return self.new(connection)
    end

    def self.test_heroku
      self.connect(TEST_CONNECTION_STRING_HEROKU)
    end

    def self.test_local
      self.connect(TEST_CONNECTION_STRING_LOCAL)
    end

    protected

    def self.cleanup_connection_cache!
      stale_connections = []

      @@connection_cache.each do |connection_string, connection_attrs|
        if (Time.now.utc - connection_attrs[:last_used_at]) > 5.minutes
          stale_connections << [connection_string, connection_attrs]
        end
      end

      stale_connections.each do |stale_connection|
        connection_string, connection_attrs = stale_connection
        $logger.debug "Disconnecting #{connection_string.inspect} after idle period of 5 mins."
        connection_attrs = @@connection_cache.delete(connection_string)
        connection_attrs[:connection].disconnect
      end
    end

    def self.connection_cache(connection_string)
      @@connection_cache ||= {}
      self.cleanup_connection_cache!

      $logger.debug "Connecting to #{connection_string.inspect}."
      @@connection_cache[connection_string] ||= {
        :connection => Sequel.connect(connection_string, COMMON_CONNECTION_OPTIONS)
      }

      @@connection_cache[connection_string][:last_used_at] = Time.now.utc

      return @@connection_cache[connection_string][:connection]
    end

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
