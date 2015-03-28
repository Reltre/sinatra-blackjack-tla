require 'rubygems'
require 'sinatra'
require 'pry'


use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'BVL57Q' 


helpers do 
  def calculate_total(cards)
    result = cards.inject(0) do |sum,card| 
      if card[1] == 'ace'
        sum + 11
      else 
        sum + (card[1].to_i == 0 ? 10 : card[1]) 
      end
    end

    cards.select{ |card| card[1] == 'ace' }.count.times do 
      break if result <= 21
      result -= 10 
    end
    result
  end

  def reset
    session[:player_hand] = []
    session[:dealer_hand] = []
  end

  def card_image(card)
    "<img src=/images/cards/#{card.join('_')}.jpg  
    align=\'middle\' style=\'width:162px;height:235px\' hspace=\'5\'>"
  end
end

before do
  @show_hit_or_stay = true
end

get '/' do
  # if session[:player_name]
  #   redirect 'game'
  # else
    session[:message] = nil
    redirect 'new_player'
  # end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end
  session[:player_name] = params[:player_name]
  session[:money] = 500
  redirect 'bet' 
end

get '/bet' do 
  erb :bet_form
end

post '/bet' do
  session[:bet] = params[:bet].to_i  
  session[:money] -= session[:bet]
  redirect'game'
end
 #= session[:dealer_hand].size == 2 ? true : false

# not_found do
#   erb :no_such_page
# end

get '/game' do
  values = [2,3,4,5,6,7,8,9,10,'jack','queen','king','ace']
  suits = ["clubs", "spades", "hearts", "diamonds"]
  session[:deck] = suits.product(values).shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  @show_card_cover = true
  erb :game
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop   
  if calculate_total(session[:player_hand]) > 21
    @error = 
    "Sorry,#{session[:player_name]}
    busted with a total of 
    #{calculate_total session[:player_hand]}, 
    you have $#{session[:money]} left." 
    @show_hit_or_stay = false
  end
  # redirect 'game'
  erb :game
end

post '/game/player/stay' do
  @show_card_cover = false
  @dealer_turn = true if calculate_total(session[:dealer_hand]) < 17 
  #redirect '/game/comparison' if calculate_total(session[:dealer_hand]) >=17
  @show_hit_or_stay = false
  @stay = "You have chosen to stay."
  erb :game 
end

post '/game/dealer-turn' do
  session[:dealer_hand] << session[:deck].pop
  dealer_total = calculate_total(session[:dealer_hand])
  
  @blackjack = true if dealer_total == 21 && session[:dealer_hand].size == 2
  if dealer_total > 21
    @success = "The Dealer has busted, #{session[:player_name]} wins!"
    @dealer_turn = false
    halt erb(:game)
  elsif dealer_total >= 17 && dealer_total <= 21 || @blackjack
    redirect '/game/comparison'
  end
  @show_card_cover = false
  @show_hit_or_stay = false
  
  @dealer_turn = true  
  erb :game
end

get '/game/comparison' do
  
end

# get '/dealer_turn' do 
#    erb :game
   
# end 
