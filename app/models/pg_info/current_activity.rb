require 'pg_info/stats'

module PgInfo
  class CurrentActivity < ::PgInfo::Stats

    # Example:
    # ::PgInfo::CurrentActivity.test_local.get :order => :query_start, :show_connections => :all
    def get(options = {})
      order = sql_option(options[:order], :xact_start)
      order_direction = sql_option(options[:order_direction], :ASC)

      active_filter = case (options[:show_connections] || :all)
      when :active
        "WHERE state = 'active'"
      when :idle
        "WHERE state != 'active'"
      when :all
        ""
      else
        fail "Unsuported show_connections value: " <<
          options[:show_connections].inspect
      end

      return sql <<-END
        SELECT * FROM pg_stat_activity
          #{active_filter}
          ORDER BY #{order} #{order_direction}
      END
    end
  end
end
