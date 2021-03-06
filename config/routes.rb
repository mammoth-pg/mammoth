get '/', to: 'home#index'

get '/manage',    to: 'manage#index'
get '/analytics', to: 'analytics#index'
get '/analytics/:type', to: 'analytics#index'
get '/query',     to: 'query#index'

get '/pg_info/:stat_name.json', to: 'pg_info#index'
post '/pg_creds/new', to: 'pg_creds#create'
get '/pg_query.json', to: 'pg_query#create' # TODO: debugging only, should be removed
post '/pg_query.json', to: 'pg_query#create'
get '/pg_explain.json', to: 'pg_explain#create' # TODO: debugging only, should be removed
post '/pg_explain.json', to: 'pg_explain#create'
