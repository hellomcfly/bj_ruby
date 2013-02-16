#changing this file

#require "rubygems"
#require "pry"

##################################
class Card
	attr_accessor :face_value, :suit

	def initialize(fv,s)
		@face_value = fv
		@suit = s
	end

	def name_card
		"#{face_value} of #{suit}"
	end

	def to_s
		name_card
	end

end

##################################
class Deck
	attr_accessor :cards

	def initialize
		suits  = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
		face_values = ['2','3','4','5','6','7','8','9','10', 'Jack', 'Queen', 'King', 'Ace']
		@cards = face_values.product(suits).map {|fv,s| Card.new(fv,s)}
		scramble!
	end

	def scramble!
		cards.shuffle!
	end

	def deal_one
		cards.pop
	end

	def print_deck
		puts cards
	end

end

##################################
module Hand

	def get_card(dealt_card)
		case dealt_card.face_value
			when 'Ace' then @my_hand[dealt_card] = 11
			when 'King' then @my_hand[dealt_card] = 10
			when 'Queen' then @my_hand[dealt_card] = 10
			when 'Jack' then @my_hand[dealt_card] = 10
			else @my_hand[dealt_card] = dealt_card.face_value.to_i
		end
	end

	def final_card_reveal
		total
		puts "#{name}'s' final hand for score of #{hand_value}:\n"; hand_output
		puts
	end

	def total
		@hand_value = my_hand.values.inject(:+)
	end

	def hand_output
		my_hand.each {|card, value| puts "Card: #{card}\t Value:#{value}\n"}
	end

	def has_ace?
		my_hand.select{|card,value| value == 11}.size > 0
	end

	def is_busted?
		total > Blackjack::BLACKJACK_VALUE
	end

	def is_blackjack?
		total == Blackjack::BLACKJACK_VALUE
	end

end

##################################
class Person
	include Hand
	attr_accessor :name, :my_hand, :hand_value, :aces, :money

	def initialize
		puts "What is your name?"
		@name = gets.chomp
		@hand_value = 0
		@my_hand = Hash.new
		@aces = 0
		@money = 1000
		puts
	end

	def show_cards
		puts "#{name}, here is your hand:\n"; hand_output
		puts
		total
		if has_ace?
			change_ace
			puts "Updated hand total is #{hand_value}.\n"
		else
			puts "Hand total is #{hand_value}."
		end
	end

	def change_ace
		aces = my_hand.select{|card,value| value == 11}
		aces.each {|card,value| 
			puts "Do you want the value of your #{card.name_card} to be 1 or 11? Type \"1\" or \"11\"."
			chosen_value = gets.chomp
			my_hand[card] = chosen_value.to_i
		}
		puts
		total
	end

end
##################################
class Dealer < Person
	include Hand
	attr_accessor :name, :my_hand, :hand_value, :aces

	def initialize
		@my_hand = Hash.new
		@hand_value = 0
		@aces = 0
		random_number = rand(6)
		@name = 
			case random_number
				when 0 then "Atticus Finch"
				when 1 then "Otto von Ruthless"
				when 2 then "Dr. Peter Venkman"
				when 3 then "Zapp Brannigan"
				when 4 then "Bruce Wayne"
				else "John 117"
			end
		puts "Your dealer for today is #{name}."
		puts "-------------------"; puts
	end

	def show_cards
		flop_card = Hash[@my_hand.sort_by { |k,v| -v }[0...1]]
		puts "#{name}'s known card is: #{flop_card.keys}"
		puts "-------------------"; puts
	end

	def change_ace
		aces = my_hand.select{|card,value| value == 11}
		aces.each {|card,value| 
			total
			my_hand[card] = 1 if hand_value > 21
		}
		total
		puts
	end

	def dealer_stop?
		total >= Blackjack::DEALER_STOP
	end

end

##################################
class Blackjack
	attr_accessor :deck, :player, :dealer, :wager
	BLACKJACK_VALUE = 21
	DEALER_STOP = 17

	def initialize
		puts "Welcome to Blackjack. My fortune smile upon you! \n"
		puts "-------------------"; puts
		@deck = Deck.new
		@dealer = Dealer.new
		@player = Person.new
		@wager = 0
	end

	def player_bet
		loop {
			puts "You have $#{player.money}. How much would you like to wager? Type a whole_number only."
			@wager = gets.chomp.to_i
			if wager == 0 
				puts "You either didn't enter a number, or you tried to bet nothing. Please try again."
				puts "-------------------"; puts
			elsif not wager.is_a? Fixnum
				puts "Please use whole numbers!"
				puts "-------------------"; puts												
			elsif wager < 0 
				puts "Betting negative dollars? I like your moxie, but please try again."
				puts "-------------------"; puts
			elsif wager > player.money 
				puts "You can't bet more than you have! Please try again."
				puts "-------------------"; puts
			else puts "Your wager of #{wager} is accepted."
				puts "-------------------"; puts
				break
			end
		}
	end

	def deal_cards
		2.times {
			player.get_card(deck.deal_one)
			dealer.get_card(deck.deal_one)
		}
	end

	def initial_card_reveal
		dealer.show_cards
	end

	def player_turn
		stand = false
		until stand == true or player.is_busted? or player.is_blackjack?
			player.show_cards
			puts
			puts "Do you want to hit or stay? Type \"hit\" or \"stand\"."
			response = gets.chomp.downcase
			case response
				when "hit" then player.get_card(deck.deal_one); puts "-------------------"; puts
				when "stand" then stand = true; puts "-------------------"; puts; break
				else puts "I don't understand! Let's try again.\n"; puts "-------------------"; puts
			end
		end
	end 

	def dealer_turn
		until dealer.is_busted? or dealer.is_blackjack? or dealer.dealer_stop? or player.is_busted?
			dealer.get_card(deck.deal_one)
			dealer.change_ace if dealer.has_ace?
		end
	end

	def final_hands
		puts "FINAL OUTCOME:"
		player.final_card_reveal
		puts
		dealer.final_card_reveal
		puts "-------------------"; puts
	end

	def resolve_game
		if player.is_busted?
			player.money -= wager
			puts "Sorry, you busted. You lose. You now have #{player.money}. Better luck next time.\n"
		elsif dealer.is_busted?
			player.money += wager
			puts "Dealer busted (like a chump). You win! You now have #{player.money}. \n"
		elsif player.total == dealer.total
			puts "Tie game. Kind of boring, but better than losing! No change in your money. \n"
		elsif player.is_blackjack?
			player.money += wager
			puts "Blackjack for you! It's your lucky day. You now have #{player.money}. "
		elsif player.total > dealer.total
			player.money += wager
			puts "Your score of #{player.total} defeats #{dealer.name}'s score of #{dealer.total}. You win! You now have #{player.money}. \n"
		elsif player.total < dealer.total
			player.money -= wager
			puts "#{dealer.name}'s score of #{dealer.total} beats your score of #{player.total}. You Lose. You now have #{player.money}. \n"
		else
			puts "Something happened. I don't know who won. I can't count, maybe?\n"
		end
		puts "-------------------"; puts
	end

	def new_game
		if player.money == 0
			puts "I'm afraid #{dealer.name} took all your money. Thanks for playing. Please come again!"
		else			
			puts "Would you like to play again? Type \"yes\" or \"no\"."
			response = gets.chomp.downcase
			puts "-------------------"; puts
			if response == "yes"
				deck=Deck.new
				player.my_hand = Hash.new
				dealer.my_hand = Hash.new
				wager = 0
				start
			else
				puts "Thanks for playing!" 
			end
		end
	end

	def start
		player_bet
		deal_cards
		initial_card_reveal
		player_turn
		dealer_turn
		final_hands
		resolve_game
		new_game
	end

end

###################################

game=Blackjack.new
game.start