require 'lotus/controller'
require 'lotus/action/session'
require 'pg_info/pg_creds'

PG_INFO_SUPPORTED_STATS = %w(
  current_activity
  current_locks
  index_bloat
  index_dupes
  index_sizes
  index_summary
  table_sizes
).freeze

PG_INFO_SUPPORTED_STATS.each do |supported_stat|
  require "pg_info/#{supported_stat}"
end

module Mammoth::Controllers::PgInfo
  class Index
    include Mammoth::Action
    include Lotus::Action::Session

    def call(params)
      self.format = :json

      stat_name = params[:stat_name]

      unless PG_INFO_SUPPORTED_STATS.include?(stat_name)
        self.status = 400
        self.body = {
          error: "Wrong stat_name: #{stat_name.inspect}",
          valid_values: PG_INFO_SUPPORTED_STATS
        }.to_json
        return
      end

      stat_class = PgInfo.const_get(stat_name.camelize)

      if session[:db_cred_id]
        connection_string = ::PgInfo::PgCreds.decrypt_creds(session[:db_cred_id])
      else
        $logger.debug "Somehow session[:db_cred_id] is empty, redirecting to the root page."
        session[:error] = "No connection credentials in the current HTTP session. Please re-enter them again."
        redirect_to '/'
      end

      stat_conn = if connection_string
        stat_class.connect(connection_string)
      else
        stat_class.test_heroku # your_bunny_wrote db by default
      end

      stats = stat_conn.get(params)

      self.status = 200
      self.body = stats.to_json
    end
  end
end
