require 'rubygems'
require 'sinatra'

# use Rack::Session::Cookie, :key => 'rack.session',
#                            :path => '/',
#                            :secret => 'BVL57Q' 

enable :sessions

get '/' do
  session[:money] = 500
  redirect 'set-name'
end

get '/set-name' do
  erb :name_form
end


post '/bet' do
  session[:username] = params[:username]
  erb :bet_form
end 

post '/game' do 

end

# get '/nested-template' do 
#   erb :'users/info'
# end 
