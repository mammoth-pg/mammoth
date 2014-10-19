get '/', to: 'home#index'

get '/manage', to: 'manage#index'
get '/anal',   to: 'analytics#index'
get '/query',  to: 'query#index'

get '/pg_info.json', to: 'pg_info#index'
