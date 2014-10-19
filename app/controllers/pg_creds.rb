require 'lotus/controller'
require 'lotus/action/session'
require 'pg_info/pg_creds'
require 'uri'

module Mammoth::Controllers::PgCreds
  class Create
    include Mammoth::Action
    include Lotus::Action::Session

    def call(params)
      if params[:conection_string]
        connection_string = params[:connection_string]

        begin # db URL validation
          URI.parse(connection_string)
        rescue URI::InvalidURIError
          session[:error] = "Connection string is not valid: #{ERB::Util.html_escape(connection_string)}."
          redirect_to '/'

          return
        end

        session[:db_cred_id] = ::PgInfo::PgCreds.encrypt_creds(params[:connection_string])
      else
        session[:db_cred_id] ||= ::PgInfo::PgCreds.generate_new_cred_id
      end

      redirect_to '/analytics'
    end
  end
end
