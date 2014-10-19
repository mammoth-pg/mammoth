require 'pg_info/stats'

module PgInfo
  class TableSizes < ::PgInfo::Stats
    def get(options = {})
      order = sql_option(options[:order], 2)
      order_direction = sql_option(options[:order_direction], :DESC)

      return sql <<-END
        SELECT nspname || '.' || relname AS "relation",
               pg_size_pretty(pg_relation_size(C.oid)) AS "size"
          FROM pg_class C
     LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
         WHERE nspname NOT IN ('pg_catalog', 'information_schema')
      ORDER BY #{order} #{order_direction}
      END
    end
  end
end
