#Creating the shuffled deck for the game
def make_deck
	suits = [' of Spades',' of Hearts',' of Diamonds',' of Clubs']
	card = ['1','2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace']

	deck_hash = Hash.new  #Create an empty hash to insert card-value pairs
	suits.each {|x|  #Create a nested .each loop over the arrays to combine suits and cards, then add a value to them based on location in the card array
		i = 1
		card.each {|y|
			deck_hash[y+x] = i
			if card[0..8].include? y
				i += 1
			elsif card[9..11].include? y
				i += 0
			else 
				i += 1
			end
		}
	}

	deck = Hash[deck_hash.to_a.shuffle]  #Returning the shuffled deck in hash format
end

def calc_hand(hand)
	hand.values.inject(:+)
end

#Create a betting mechanism
def make_bet(money)
	bet = 0
	loop {
		puts "\nYou have $#{money}. How much would you like to bet? Use whole numbers only. If you don't this program will break.\n"
		wager = gets.chomp
		elsif Integer(wager) == 0
			puts "Fine, but you're a chicken!\n"
			bet = 0
			break
		elsif Integer(wager) < 0
			puts "Nice try, but you can't bet negative.\n"
		elsif Integer(wager) > money
			puts "You don't have that much!\n"
		elsif Integer(wager) > 0 && Integer(wager) <= money
			bet = wager.to_i
			puts "You bet $#{bet}."
			break
		else
			puts "I don't understand. Did you use a whole number? Let's try again."	
		end
	}
	bet
end

#This is my method to deal with aces. It counts the aces, determines the type of aces, and returns them. 
def count_aces(hand)
	aces = []
	ace_count = 0
	if hand.keys.include? 'Ace of Spades'
		ace_count += 1
		aces << 'Ace of Spades'
	end
	if hand.keys.include? 'Ace of Hearts'
		ace_count += 1
		aces << 'Ace of Hearts'
	end
	if hand.keys.include? 'Ace of Clubs'
		ace_count += 1
		aces << 'Ace of Clubs'
	end
	if hand.keys.include? 'Ace of Diamonds'
		ace_count += 1
		aces << 'Ace of Diamonds'
	end
	results = [ace_count, aces]
end

#this is the primary game.
def gameplay(moolah)
	money = moolah.to_i
	bet = 0
	hash_deck = make_deck #A shuffle deck is created and returned.

	#The player and dealer are given two cards from the shuffled deck and they are turned into a hash.
	player_hand = Hash[*(hash_deck.shift + hash_deck.shift).flatten] 
	dealer_hand = Hash[*(hash_deck.shift + hash_deck.shift).flatten] 
	
	#The hash values in the player's and dealer's hand are summed
	player_score = calc_hand(player_hand) 
	dealer_score = calc_hand(dealer_hand)  

	#Local ace booleans are created and then switched to true if the player/dealer has an ace
	player_ace = false 
	dealer_ace = false
	ace = true if player_hand.key(11) != nil
	dealer_ace = true if dealer_hand.key(11) != nil

	#This is where betting occurs.
	bet = make_bet(money)

	#This loop present the dealer's visible card and the players hand.
	#Loops were used to force the user to input the correct entry when prompted. If they type something unexpected, the loop just asks them to try again.
	loop {
		puts "Dealer's second card is a #{dealer_hand.keys[1]} for a known value of #{dealer_hand.values[1]}.\n \nYour hand value is #{player_score} and your cards are:"
		player_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts

		#This is where we resolve aces. If the player has them, the number of them and type are determined in the count_aces method and returned.
		if ace == true
			ace_result = count_aces(player_hand)
			ace_count = ace_result[0]
			aces = ace_result[1]
			
			#For grammatical reasons, the prompt for 1 vs. many aces is different. 
			case ace_count
			when 1
				loop {
					puts "You have an ace in your hand! Do you want to set it's value to 1 or 11? Type \"1\" or \"11\"."
					choice = gets.chomp
						if choice.downcase == "1"
							player_hand[aces[0]] = 1
							puts "\nValue of #{aces[0]} set to #{choice}.\n"
							break
						elsif choice.downcase == "11"
							player_hand[aces[0]] = 11
							puts "\nValue of #{aces[0]} set to #{choice}\n"
							break
						else
							puts "I don't understand! Please try again\n"
						end
				}
			else
				puts "You have #{ace_count} aces in your hand!\n"
				
				#They are given the opportunity to choose a value for each ace. Values are then updated in the player_hand hash.
				aces.each { |x|
					loop {
						puts "Do you want to set the value of your #{x} to 1 or 11? Type \"1\" or \"11\"."
						choice = gets.chomp
							if choice.downcase == "1"
								player_hand[x] = 1
								puts "Value of #{aces[0]} set to #{choice}"
								break
							elsif choice.downcase == "11"
								player_hand[x] = 11
								puts "Value of #{aces[0]} set to #{choice}"
								break
							else
								puts "I don't understand!"
							end
					}
				}					
			end

			#Score ie recalculated based on decision with aces.
			player_score = calc_hand(player_hand) 
			puts
			puts "Your hand value is #{player_score}!\n"
		end	
		
		#Here the player decided to hit or stand. Hitting continues the game, but you can bust 
		#(unless an ace is what busts you, then you have an opportunity to reduce its value in another loop.
		puts "\nType \"hit\" or \"stand\"."
		action = gets.chomp
		puts
		if action.downcase == "hit"
			dealt_card = hash_deck.shift  #this returns a new card as an array, deleting it from the deck
			player_hand[dealt_card[0]] = dealt_card[1]  #this adds it to the player hand hash
			ace = true if player_hand.key(11) != nil  #this lets us know if the player now has a new ace
			player_score = calc_hand(player_hand) 
			if player_score > 21 && dealt_card[1] != 11  #this busts the player is over 21 and the new card is not an ace
				
				#If the player busts, the dealer gets an opportunity to draw to their final score. Once that is done, whe loop breaks and the game resolves.
				while dealer_score < 17  
					dealt_card = hash_deck.shift
					dealer_hand[dealt_card[0]] = dealt_card[1]

					#The dealer's aces automatically reduce in value if 21 is exceeded on the draw.
					ace = true if dealer_hand.key(11) != nil 
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
					dealer_score = calc_hand(dealer_hand) 
				end
				break
			end

		#The dealer is given an opportunity to draw and then the loop breaks to resolve the game.
		elsif action.downcase == "stand"
			while dealer_score < 17
				dealt_card = hash_deck.shift
				dealer_hand[dealt_card[0]] = dealt_card[1]
				dealer_score = calc_hand(dealer_hand)  
				ace = true if player_hand.key(11) != nil
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
				dealer_score = calc_hand(dealer_hand) 
			end
			break
		else
			puts "I don't understand!" #Validates input. Loop cycle repeats if they don't input in "hit" or "stand"
		end
	}

	#Checks scores and states, and resolves the game while displaying dealer cards and scores.
	if player_score > 21
		puts "You busted. Final hand with a value of #{player_score}:"
		player_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts "\nYou lose $#{bet}!"
		money -= bet
	elsif dealer_score == player_score
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts "\nDealer and player both have #{player_score}. Game ends in a tie! No change in money."
		return money
	elsif dealer_score > 21
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts "\nDealer busted - player wins! You win $#{bet}."
		money += bet
	elsif dealer_score > player_score
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts "\nDealer has #{dealer_score} to player's #{player_score}. Dealer wins! You lose $#{bet}!"
		money -= bet 
	else
		puts "Dealer's final cards with a value of #{dealer_score}:"
		dealer_hand.each {|k,v| puts "Card: #{k} \tValue:#{v}"}
		puts "\nDealer has #{dealer_score} to player's #{player_score}. Player wins! You win $#{bet}."
		money += bet
	end
end
	

#Creating a mechanism to start the game, to play a new game, and to end the game
def start(moolah)
	money = moolah.to_i
	puts 'Want to play Blackjack? Type "Yes" if so and "No" to quit!'
	answer = gets.chomp

	#Starts the game. It is recursive to the game can keep going on infinitely. 
	if answer.downcase == "yes"
		puts
		money = gameplay(money)
		puts
		start(money)

	#Ends the game.
	elsif answer.downcase == "no"
		return "Thanks for playing!"
	
	#Validates input
	else
		puts "I don't understand!"
		start(money)
	end
end


#Start the game
start(1000)
puts "\nThanks for playing!"