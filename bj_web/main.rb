require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

###############################
get '/' do
	if session[:player_name].nil?
		redirect '/set_player_names'
	else
		redirect '/game'
	end
end

###############################
get '/set_player_names' do
	erb :set_player_names
end

post '/set_player_names' do
	puts params['name']
	if params['name'].empty?
		@error = "Must input a name, no matter how wonky!"
		erb :set_player_names
	else
		session[:name] = params['name']
		redirect '/game'
	end
end

###############################
get '/game' do

	#Make sure logged-in
	if session[:name].empty?
		@error = "Must input a name, no matter how wonky!"
		erb :set_player_names
	end

	#create deck
	suits = [' of Hearts', ' of Diamonds', ' of Spades', ' of Clubs']
	face_values = ['2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace']
	session[:deck] = face_values.product(suits).shuffle

	#deal cards
	session[:dealer_cards] = []
	session[:player_cards] = []
	2.times do
		session[:player_cards] << session[:deck].pop
		session[:dealer_cards] << session[:deck].pop
	end

	#direct to appropriate template
	erb :blackjack

	#Start flow of game

end

post '/game' do
	if params['choice'] == "Hit"
		session[:player_cards] << session[:deck].pop
	else
		session[:dealer_cards] << session[:deck].pop
		@game_over = true
	end

	erb :blackjack
end

###############################
helpers do
	def show_cards(card_array)
		card_array.each {|card|
			card[0]+card[1]
		}
	end
end

###############################
## Old homework ###############
###############################
get '/flux_capicator' do
	erb :flux_template
end

get '/bttf_chars' do
	erb :"/characters/names"
end

get '/bttf_year' do
	erb :bttf_year
end

post '/yearguess' do
	puts params['year']
end