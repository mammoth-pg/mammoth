require 'pg_info/stats'

module PgInfo
  class IndexSummary < ::PgInfo::Stats
    def get(options = {})
      order = sql_option(options[:order], 2)
      order_direction = sql_option(options[:order_direction], :ASC)

      return sql <<-END
         SELECT pg_class.relname,
                pg_size_pretty(pg_class.reltuples::bigint) AS rows_in_bytes,
                pg_class.reltuples AS num_rows,
                count(indexname) AS number_of_indexes,
                CASE WHEN x.is_unique = 1 THEN 'Yes'
                                          ELSE 'No'
                END AS unique,
                SUM(CASE WHEN number_of_columns = 1 THEN 1
                                                    ELSE 0
                END) AS single_column,
                SUM(CASE WHEN number_of_columns IS NULL THEN 0
                         WHEN number_of_columns = 1 THEN 0
                         ELSE 1
                END) AS multi_column
           FROM pg_namespace
LEFT OUTER JOIN pg_class
             ON pg_namespace.oid = pg_class.relnamespace
LEFT OUTER JOIN (SELECT indrelid,
                        MAX(CAST(indisunique AS integer)) AS is_unique
                   FROM pg_index
               GROUP BY indrelid) x
             ON pg_class.oid = x.indrelid
LEFT OUTER JOIN (SELECT c.relname AS ctablename,
                        ipg.relname AS indexname,
                        x.indnatts AS number_of_columns
                   FROM pg_index x
                   JOIN pg_class c
                     ON c.oid = x.indrelid
                   JOIN pg_class ipg
                     ON ipg.oid = x.indexrelid)
                     AS foo
            ON pg_class.relname = foo.ctablename
         WHERE pg_namespace.nspname = 'public'
           AND pg_class.relkind = 'r'
      GROUP BY pg_class.relname, pg_class.reltuples, x.is_unique
      ORDER BY #{order} #{order_direction}
      END
    end
  end
end
