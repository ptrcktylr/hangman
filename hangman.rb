require 'json'

dictionary_file = File.readlines('5desk.txt').map(&:chomp)
DICTIONARY = Array.new(dictionary_file.select{|word| word.length >= 5 && word.length <= 12})

class Hangman
  attr_reader :number_of_guesses

  def initialize(
                  secret_word = DICTIONARY.sample, 
                  incorrect_guesses_remaining = 6, 
                  guessed_letters = Array.new, 
                  hidden_word = Array.new(secret_word.length, "_")
                )

    @secret_word = secret_word
    @incorrect_guesses_remaining = incorrect_guesses_remaining
    @guessed_letters = guessed_letters
    @hidden_word = hidden_word
  end

  def display_guesses
    puts "You have #{@incorrect_guesses_remaining} incorrect guesses remaining!"
  end

  def display_guessed_letters
    puts "Guessed letters: [#{@guessed_letters.join(" ")}]"
  end

  def display_hidden_word
    puts @hidden_word.join(" ")
  end

  def valid_guess(char)
    if char.length != 1
      puts "Enter only 1 letter!"
      return false
    end

    regex = /^[a-z]{1}$/i

    if !regex.match(char)
      puts "Enter letters only!"
      return false
    end

    if @guessed_letters.include?(char)
      puts "Letter already guessed!"
      return false
    end

    return true
  end

  def fill_hidden_word!(input_char)
    @secret_word.each_char.with_index do |char, idx|
      if input_char.downcase == char.downcase
        @hidden_word[idx] = char
      end
    end
  end

  def won?
    if @hidden_word.none?{|char| char == "_"}
      puts "You win!"
      return true
    else
      return false
    end
  end

  def loss?
    if @incorrect_guesses_remaining <= 0
      puts "You lose!"
      return true
    else
      return false
    end
  end

  def over?
    won? || loss?
  end

  def make_guess # if users enters SAVE, save current game as a file
    puts "Enter your guess:"
    guessed_letter = gets.chomp.downcase

    if guessed_letter == "save"
      system "clear"
      puts "Saved game. Quitting.."
      save_game
      exit
    end

    until valid_guess(guessed_letter)
      puts "Enter your guess:"
      guessed_letter = gets.chomp.downcase
    end

    @guessed_letters << guessed_letter

    if @secret_word.include?(guessed_letter)
      fill_hidden_word!(guessed_letter)
      return true

    else
      @incorrect_guesses_remaining -= 1
      return false
    end
  end

  def run
    puts "Starting Hangman game..."
    puts "To save and quit, enter SAVE as a guess!"
    until over?
      display_status
      make_guess
    end

    puts "The secret word was '#{@secret_word}'"
  end

  def display_status
    system "clear"
    puts "To save and quit, enter SAVE as a guess!"
    puts "--------------------------"
    display_guesses
    display_guessed_letters
    display_hidden_word
    puts "--------------------------"
  end

  def to_json
    {
      secret_word: @secret_word,
      incorrect_guesses_remaining: @incorrect_guesses_remaining,
      guessed_letters: @guessed_letters,
      hidden_word: @hidden_word
    }.to_json
  end

  def save_game
    # save data
    save_data = self.to_json

    # file name
    time = Time.new
    file_name = "./save_data/#{time.to_s.tr(" :-","_")[0...-6]}.json"

    # create file
    file = File.new(file_name, "w")
    file.puts save_data
    file.close
  end

  def self.from_json(file_name)
    # open file
    file = File.open(file_name)
    lines = file.read.chomp

    # get data
    save_data = JSON.load(lines)

    # create object with data
    init_data = [save_data['secret_word'], save_data['incorrect_guesses_remaining'], save_data['guessed_letters'], save_data['hidden_word']]
    return Hangman.new(init_data[0], init_data[1], init_data[2], init_data[3])
  end

  def self.get_save_files
    return Dir['./save_data/*']
  end

end

# when starting, load or start new game
# show current saves, saves sorted by time or hidden word, both, etc



# Now implement the functionality where, at the start of any turn, instead of making a guess the player should also have the option to save the game. Remember what you learned about serializing objects… you can serialize your game class too!
# When the program first loads, add in an option that allows you to open one of your saved games, which should jump you exactly back to where you were when you saved. Play on!

# Main

puts "Would you like to start a new game? (y/n)"
new_game = gets.chomp.downcase

until (new_game == "y" || new_game == "n")
  system "clear"
  puts "Invalid answer"
  puts "Would you like to start a new game? (y/n)"
  new_game = gets.chomp.downcase
end

if new_game == "y"
  game = Hangman.new
  game.run
else
  puts "Loading save data..."
  files = Hangman.get_save_files
  if files.empty?
    # no loads
    puts "There are no saves!"
    puts "Quitting game..."
    exit
  else
    # loading file
    system "clear"
    puts "Which save would you like to load?"
    puts "--------------------------"
    files.each_with_index {|file, idx| puts "#{idx} #{file[12..-6]}"}
    puts "--------------------------"

    # getting input to load
    file_idx_to_load = gets.chomp

    # check input
    re = /^\d+$/
    while !re.match?(file_idx_to_load) || !file_idx_to_load.to_i.between?(0,files.length-1)
      puts "Invalid option. Please choose a number cooresponding to a save."
      puts "Which save would you like to load?"
      puts "--------------------------"
      files.each_with_index {|file, idx| puts "#{idx} #{file[12..-6]}"}
      puts "--------------------------"
      file_idx_to_load = gets.chomp
    end

    # load and run game
    game = Hangman.from_json(files[file_idx_to_load.to_i])
    game.run

  end
end


# puts "Choose a save to load: "
# display saves and user inputs a number
  # if number between num of saves load game else
  # get a number again

