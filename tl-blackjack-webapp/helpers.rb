
helpers do 
  def deal_cards
    session[:player_hand] = []
    session[:dealer_hand] = []
    session[:player_hand] << session[:deck].pop
    session[:dealer_hand] << session[:deck].pop
    session[:player_hand] << session[:deck].pop
    session[:dealer_hand] << session[:deck].pop
  end

  def calculate_total(cards)
    55
  end

end