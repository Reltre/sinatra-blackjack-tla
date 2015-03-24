require 'rubygems'
require 'sinatra'
require 'pry'
require_relative 'helpers.rb'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'BVL57Q' 


get '/' do
  erb :name_form
end

post '/bet' do
  session[:username] = params[:username]
  session[:money] = 500
  redirect 'bet'  
end

get '/bet' do 

  erb :bet_form
end

post '/game' do
  session[:deck] = create_deck
  deal_cards
  #binding.pry
  redirect'game'
end

get '/game' do
  erb :game
end

not_found do
  erb :no_such_page
end


# get '/nested-template' do 
#   erb :'users/info'
# end 
