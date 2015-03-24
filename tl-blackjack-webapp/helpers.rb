FACE_VALUES = {
  "Two"   => 2,
  "Three" => 3,
  "Four"  => 4,
  "Five"  => 5,
  "Six"   => 6,
  "Seven" => 7,
  "Eight" => 8,
  "Nine"  => 9,
  "Ten"   => 10,
  "Jack"  => 10,
  "Queen" => 10,
  "King"  => 10,
  "Ace"   => 11
}

SUITS = ["clubs", "spades", "hearts", "diamonds"]
FACE_VALUES.freeze
SUITS.freeze

helpers do 
  def create_deck
    cards = []
    SUITS.each do |suit| 
      FACE_VALUES.values.each do |value|
        cards << [suit,value]
      end
    end
    cards.shuffle!
  end

  def deal_cards
    session[:player_hand] = []
    session[:dealer_hand] = []
    session[:player_hand] << session[:deck].pop
    session[:dealer_hand] << session[:deck].pop
    session[:player_hand] << session[:deck].pop
    session[:dealer_hand] << session[:deck].pop
  end

end