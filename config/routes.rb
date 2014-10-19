get '/', to: 'home#index'

get '/manage',    to: 'manage#index'
get '/analytics', to: 'analytics#index'
get '/query',     to: 'query#index'

get '/pg_info/:stat_name.json', to: 'pg_info#index'
post '/pg_creds/new', to: 'pg_creds#create'
