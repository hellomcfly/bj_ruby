class Deck
	attr_accessor :cards

	def initialize
		@cards = []
		["Spades", "Hearts", "Diamonds", "Clubs"].each {|suit|
			[1,2,3,4,5,6,7,8,9,10,'Jk','Qn','Kg','Ace'].each {|face_value|
				@cards << Card.new(suit, face_value)
			}		
		}
		scramble!
	end

	def scramble!
		@cards.shuffle!
	end

	def deal_one
		cards.pop
	end
end

########################
class Card
	attr_accessor :suit, :face_value, :real_value

	def initialize(s, fv)
		@suit = s
		@face_value = fv
		@real_value = 
			if fv == 'Ace'
				11
			elsif fv == 'Kg'
				10
			elsif fv == 'Qn' 
				10
			elsif fv == 'Jk'
				10
			else
				fv.to_i
			end
	end

#	def change_ace(chosen_value)
#		@real_value = chose_value.to_i
#	end	

	def to_s
		"Card: #{@face_value} of #{@suit}; \tValue: #{real_value}"
	end
end

########################
class Hand
	attr_accessor :hand_cards, :person

	def initialize(person)
		@person = person
		@hand_cards = []
	end

	def new_card(card)
		@hand_cards << card
	end


	def total
		hand_value = 0
		values = @hand_cards.map {|card| card.real_value}
		hand_value = values.inject(:+)
	end

end

########################
class Player
	attr_accessor :name
end

########################
class Dealer < Player
end

########################
class Game
	attr_accessor :deck, :person, :dealer, :person_hand, :dealer_hand

	def initialize
		# Deck creation and welcome
		@deck = Deck.new 
		puts "Welcome to our game of Blackjack! What is your name?"

		# Setting player and dealer's name (for fun)
		typed_name = gets.chomp
		@person = Player.new
		person.name = typed_name
		
		@dealer = Player.new
		random_number = rand(4)
		dealer.name = 
			case random_number
			when 0
				"Atticus Finch"
			when 1
			 	"Otto von Ruthless"
			when 2
			 	"Dr. Peter Venkman"
			else
			 	"Zapp Brannigan"
			end
		puts
		puts "Your dealer for this round is #{dealer.name}."
	end
	
		# Creating the hands and dealing initial cards into the hands
		person_hand = Hand.new(@person)
		dealer_hand = Hand.new(@dealer)

		2.times {
			deal_card(person_hand)	
			deal_card(dealer_hand)	
		}
		show_cards
	end

	def deal_card(player_hand)
		player_hand.new_card(@deck.deal_one)
	end

	def show_cards
		puts "Here is #{dealer.name}'s known card:"
		puts dealer_hand.hand_cards[0]
		puts
		
		puts "#{person.name}, here is your hand for a total value of #{person_hand.total}:"
		puts person_hand.hand_cards
		puts
		hit_or_stand
	end

	def hit_or_stand
		puts "Would you like to hit or stand? Type \"hit\" or \"stand\"."
		action = gets.chomp
		if action.downcase = "hit"
			deal_card(person_hand)
			show_cards
		elsif action.downcase = "stand"
			stand
		end
	end

#		compare_for_winner

end

########################
class Bet
end

########################

blackjack = Game.new




