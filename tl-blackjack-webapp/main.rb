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

  def card_image(card)
    "<img src=/images/cards/#{card.join('_')}.jpg  
    align=\'middle\' style=\'width:162px;height:235px\' hspace=\'5\'>"
  end

  def compare
    dealer_total = calculate_total(session[:dealer_hand])
    player_total = calculate_total(session[:player_hand])

    if player_total == dealer_total 
      "tie"
    elsif dealer_total > player_total
      "loss"
    else player_total > dealer_total
      "win"
    end
  end

  def compare_blackjack
    if blackjack?(session[:player_hand]) && blackjack?(session[:dealer_hand]) 
      "blackjack_tie"
    elsif blackjack?(session[:dealer_hand])
      "blackjack_loss"
    else
      "blackjack_win"
    end
  end

  def blackjack?(cards)
    cards.size == 2 && calculate_total(cards) == 21
  end
end

not_found do
  erb :no_such_page
end

before do
  @show_hit_or_stay = true
  @show_card_cover = true
end

before '/game/dealer' do
  @show_card_cover = false
  @show_hit_or_stay = false
  @show_total = true
end 

before '/game/comparison' do
  @show_card_cover = false
  @show_hit_or_stay = false
  @dealer_turn = false
  @show_total = true
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
  redirect'game'
end

get '/game' do
  values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'jack', 'queen', 'king', 'ace']
  suits = ["clubs", "spades", "hearts", "diamonds"]
  session[:deck] = suits.product(values).shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  erb :game
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop   
  if calculate_total(session[:player_hand]) > 21
    @error = 
    "Sorry,#{session[:player_name]}
    busted with a total of 
    #{calculate_total session[:player_hand]}." 
    @show_hit_or_stay = false
    @round_over = true
    halt erb(:game)
  end
erb :game
end

post '/game/player/stay' do
  redirect '/game/dealer'
end

get '/game/dealer' do
  @info = "You decided to stay."
  dealer_total = calculate_total(session[:dealer_hand])

  @dealer_turn = true  
  @show_total = true
  @show_only_player_total = true
  @show_hit_or_stay = false
  
  if dealer_total > 21
    @success = "The Dealer has busted, #{session[:player_name]} wins!"
    @show_card_cover = false
    halt erb(:game)
  elsif dealer_total >= 17 && dealer_total <= 21 || @blackjack
    redirect '/game/comparison'
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_hand] << session[:deck].pop
  redirect back
end

get '/game/comparison' do
  result = 
  (blackjack?(session[:dealer_hand]) || blackjack?(session[:player_hand])) ?
  compare_blackjack : compare

  @success = "#{session[:player_name]} wins!" if result == "win"
  @alert = "The round ended in a tie." if result == "tie"
  @error = "The Dealer won the round." if result == "loss"

  if result == "blackjack_win"
    @success = "#{session[:player_name]} has BlackJack and wins!"
  elsif result == "blackjack_tie"
    @alert = "Both #{session[:player_name]} and the Dealer have BlackJack, the round ends in a tie."
  elsif result == "blackjack_loss"
    @error = "The Dealer has BlackJack and wins the round." 
  end
  
  @show_only_player_total = true
  erb :game
end

# get '/dealer_turn' do 
#    erb :game
   
# end 
