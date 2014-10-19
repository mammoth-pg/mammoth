# This is a helper for reading pg connection creds from session
# Inteded to be used in Pg controllers

require 'lotus/action/session'
require 'pg_info/pg_creds'

module Mammoth::PgConnection
  include Lotus::Action::Session

  protected

  def connection_for_class(klass)
    if session[:db_cred_id]
      connection_string = ::PgInfo::PgCreds.decrypt_creds(session[:db_cred_id])
    else
      $logger.debug "Somehow session[:db_cred_id] is empty, redirecting to the root page."
      session[:error] = "No connection credentials in the current HTTP session. Please re-enter them again."
      redirect_to '/'

      return nil
    end

    stat_conn = if connection_string
      klass.connect(connection_string)
    else
      klass.test_heroku # your_bunny_wrote db by default
    end

    return stat_conn
  end
end
