#Creating the shuffled deck for the game
def make_deck
	suits = [' of Spades',' of Hearts',' of Diamonds',' of Clubs']
	card = ['1','2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace']
	deck = Hash.new
	suits.each {|x|
		i = 1
		card.each {|y|
			deck[y+x] = i
			if card[0..8].include? y
				i += 1
			elsif card[9..11].include? y
				i += 0
			else 
				i += 1
			end
		}
	}
	deck = Hash[deck.to_a.shuffle]
end

def gameplay
	hash_deck = make_deck
	player_hand = Hash[*(hash_deck.shift + hash_deck.shift).flatten]
	dealer_hand = Hash[*(hash_deck.shift + hash_deck.shift).flatten]
	player_score = player_hand.values.inject(:+)
	dealer_score = dealer_hand.values.inject(:+)
	ace = false
	dealer_ace = false
	ace = true if player_hand.key(11) != nil
	dealer_ace = true if dealer_hand.key(11) != nil
	# Code not implemented yet: puts "**IMPORTANT NOTE**: Aces will counts as 11 unless you or the dealer exceed 21 in which case they will count as 1."
	while (player_score < 22 && ace == false) || (player_score < 33 && ace == true)
		puts "Dealer's second card is a #{dealer_hand.keys[1]} for a known value of #{dealer_hand.values[1]}.\n \nYour hand value is #{player_score} and your cards are:"
		player_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts
		if ace == true
			puts "You have an Ace in your hand! Would you like to set/keep it's value to 1 or 11? Type \"1\" or \"11\"." 
			ace_action = gets.chomp
			if ace_action == '1'
				if player_hand.keys.include? 'Ace of Spades'
					player_hand['Ace of Spades'] = 1
				elsif player_hand.keys.include? 'Ace of Diamonds'
					player_hand['Ace of Diamonds'] = 1
				elsif player_hand.keys.include? 'Ace of Clubs'
					player_hand['Ace of Clubs'] = 1
				else
					player_hand['Ace of Hearts'] = 1
				end
				player_score = player_hand.values.inject(:+)
				puts "Ace value changed to/kept at 1. New hand value is #{player_score}\n"
			elsif ace_action == '11'
				if player_hand.keys.include? 'Ace of Spades'
					player_hand['Ace of Spades'] = 11
				elsif player_hand.keys.include? 'Ace of Diamonds'
					player_hand['Ace of Diamonds'] = 11
				elsif player_hand.keys.include? 'Ace of Clubs'
					player_hand['Ace of Clubs'] = 11
				else
					player_hand['Ace of Hearts'] = 11
				end
				player_score = player_hand.values.inject(:+)
				puts "Ace value changed to/kept at 11. New hand value is #{player_score}\n"
			else
				puts "I don't understand. Value will remain the same through next round.\n"
			end
		end
		puts "Type \"hit\" or \"stand\"."
		action = gets.chomp
		puts " "
		if action.downcase == "hit"
			dealt_card = hash_deck.shift
			player_hand[dealt_card[0]] = dealt_card[1]
			ace = true if player_hand.key(11) != nil
			player_score = player_hand.values.inject(:+)
		elsif action.downcase == "stand"
			while dealer_score < 17
				dealt_card = hash_deck.shift
				dealer_hand[dealt_card[0]] = dealt_card[1] 
				if dealer_ace == true && dealer_score > 21
					if dealer_hand.keys.include? 'Ace of Spades'
						dealer_hand['Ace of Spades'] = 1
					elsif dealer_hand.keys.include? 'Ace of Diamonds'
						dealer_hand['Ace of Diamonds'] = 1
					elsif player_hand.keys.include? 'Ace of Clubs'
						dealer_hand['Ace of Clubs'] = 1
					else
						dealer_hand['Ace of Hearts'] = 1
					end
				end					
				dealer_score = dealer_hand.values.inject(:+)
			end
			break
		else
			puts "I don't understand!"
		end
	end
	if player_score > 21
		puts "You busted. Final hand with a value of #{player_score}:"
		player_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts
		return "You lose!" 
	elsif dealer_score == player_score
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.keys.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts
		return "Dealer and player both have #{player_score}. Game ends in a tie!"
	elsif dealer_score > 21
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.keys.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts
		return "Dealer busted - player wins!"
	elsif dealer_score > player_score
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.keys.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts
		return "Dealer has #{dealer_score} to player's #{player_score}. Dealer wins!"
	else
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.keys.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts
		return "Dealer has #{dealer_score} to player's #{player_score}. Player wins!"
	end
end
	

#Creating a starting mechanism
def start
	puts 'Want to play Blackjack? Type "Yes" if so and "No" to quit!'
	answer = gets.chomp
	if answer.downcase == "yes"
		puts
		puts gameplay
		puts
		start
	elsif answer.downcase == "no"
		return "Thanks for playing!"
	else
		puts "I don't understand!"
		start
	end
end


#Start the game
start

