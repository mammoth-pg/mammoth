require 'pg_connection'

module Mammoth::Controllers::PgExplain
  class Create
    include Mammoth::Action
    include Mammoth::PgConnection

    def call(params)
      self.format = :json

      sql_query = params[:sql_query]

      # remove EXPLAIN ANALYZE in case it's already present
      sql_query.gsub! /^EXPLAIN\s+/i, ''
      sql_query.gsub! /^ANALYZE\s+/i, ''

      sql_query.prepend "EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS, TIMING, FORMAT JSON) "

      stat_conn = connection_for_class(::PgInfo::Stats) or return

      result_json = stat_conn.sql(sql_query).first[:"QUERY PLAN"]

      self.body = result_json
      self.status = 200
    rescue Sequel::DatabaseError => e
      self.body = {
        error: e.message
      }.to_json
      self.status = 400
    end
  end
end
