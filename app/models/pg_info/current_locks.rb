require 'pg_info/stats'

module PgInfo
  class CurrentLocks < ::PgInfo::Stats

    def get(options = {})
      order = sql_option(options[:order], %i(database_name relation_name))
      order_direction = sql_option(options[:order_direction], :ASC)

      return sql <<-END
        SELECT pgl.locktype,
               pgd.datname AS database_name,
               pgcr.relname AS relation_name,
               pgl.page,
               pgl.tuple,
               pgl.virtualxid,
               pgl.transactionid,
               pgcc.relname,
               pgl.objid,
               pgl.objsubid,
               pgl.virtualtransaction,
               pgl.pid,
               pgl.mode,
               pgl.granted,
               pgl.fastpath
          FROM pg_locks pgl
     LEFT JOIN pg_database pgd
            ON pgd.oid = pgl.database
     LEFT JOIN pg_class pgcr
            ON pgcr.oid = pgl.relation
     LEFT JOIN pg_class pgcc
            ON pgcc.oid = pgl.classid
      ORDER BY #{order} #{order_direction}
      END
    end
  end
end
