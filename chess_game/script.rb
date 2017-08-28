require 'yaml'
require './lib/game.rb'

play_again = 'y'
while play_again == 'y'
  system('cls')
  puts ''
  puts "                          ~ Chess Game ~"
  puts "Chess is a two-player strategy board game played on a chessboard, "
  puts "a checkered gameboard with 64 squares arranged in an 8×8 grid."
  puts "The game is played by millions of people worldwide."
  puts "Each player begins with 16 pieces: one king, one queen, "
  puts "two rooks, two knights, two bishops, and eight pawns."
  puts "Each of the six piece types moves differently,"
  puts "with the most powerful being the queen and the least powerful the pawn."
  puts "The objective is to checkmate the opponent's king by placing it"
  puts 'under an inescapable threat of capture.To this end, a player\'s pieces are used to attack'
  puts "and capture the opponent's pieces, while supporting each other."
  puts "Do you want to start a game from a saved file? If yes, press Y:"
  react = gets.chomp.downcase
  if react == 'y'
    file = YAML.load_file('save_data.yml')
    current_player = file[:current_player]
    other_player = file[:@other_player]
    game = Game.new([current_player,other_player])
    game.from_yaml
  else
    puts "Player 1, what's your name?"
    name1 = gets.chomp
    puts "which color do you want play? white or black?"
    color1 = gets.chomp.downcase

    until ['white', 'black'].include?(color1)
      color1 = gets.chomp.downcase
    end
    player1 = Player.new(name1, color1)

    puts "Player 2, what's your name?"
    name2 = gets.chomp
    color2 = (['white', 'black'] - [color1])[0]
    player2 = Player.new(name2, color2)
    game = Game.new([player1, player2])
  end

  game.start_game
  puts "Do you want to play again? If yes, input Y. If no, press ENTER :"
  play_again = gets.chomp.downcase
end
