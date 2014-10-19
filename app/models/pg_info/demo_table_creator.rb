require 'pg_info/stats'
require 'securerandom'
require 'uri/http'

module PgInfo
  class DemoTableCreator < ::PgInfo::Stats
    SQL_DUMP_PATH = ::Mammoth::Application.configuration.root.join("sql/world.sql").to_s.freeze

    def create_and_get(options = {})
      random_db_name = "demodb_" <<
                       SecureRandom.hex(10) <<
                       "_" <<
                       Time.now.utc.strftime('%Y%m%d_%H%M')
      $logger.debug "Creating new database #{random_db_name.inspect}."

      sql "CREATE DATABASE #{random_db_name}"

      $logger.debug "Loading sql/world.sql into #{random_db_name.inspect}."

      pg_host = @connection.opts[:host]
      pg_user = @connection.opts[:user]
      pg_password = @connection.opts[:password]

      password_option = pg_password && "PGPASSWORD=#{pg_password}"
      psql_command = `which psql`.strip
      psql_command = ::Mammoth::Application.configuration.root.join("evilbin/psql").to_s if psql_command.blank?
      host_option = pg_host && "-h #{pg_host}"
      user_option = pg_user && "-U #{pg_user}"
      dump_path_option = "-f #{SQL_DUMP_PATH}"

      psql_cmdline = [
        password_option,
        psql_command,
        host_option,
        user_option,
        dump_path_option,
        random_db_name
      ].join(' ')

      $logger.debug "Calling #{psql_cmdline.inspect}."

      psql_output = `#{psql_cmdline}`
      $logger.debug psql_output

      random_db_conn_string = URI::HTTP.new(
        'postgres',
        [*pg_user, *pg_password].join(':'),
        pg_host,
        nil,
        nil,
        "/#{random_db_name}",
        nil,
        nil,
        nil
      ).to_s
      $logger.debug "Random conn string: #{random_db_conn_string.inspect}."

      return random_db_conn_string
    end
  end
end
