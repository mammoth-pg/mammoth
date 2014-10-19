require 'pg_connection'

module Mammoth::Controllers::PgQuery
  class Index
    include Mammoth::Action
    include Mammoth::PgConnection

    def call(params)
      self.format = :json

      sql_query = params[:sql_query]

      stat_conn = connection_for_class(::PgInfo::Stats) or return

      self.body = stat_conn.sql(sql_query).to_json
      self.status = 200
    rescue Sequel::DatabaseError => e
      self.body = {
        error: e.message
      }.to_json
      self.status = 400
    end
  end
end
