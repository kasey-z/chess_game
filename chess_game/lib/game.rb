require 'yaml'
require_relative 'bishop.rb'
require_relative 'board.rb'
require_relative 'chesspiece.rb'
require_relative 'king.rb'
require_relative 'knight.rb'
require_relative 'pawn.rb'
require_relative 'player.rb'
require_relative 'queen.rb'
require_relative 'rook.rb'

class Game
  attr_accessor :players, :board, :current_player, :other_player, :between_capture

  def initialize(player1, player2, board = Board.new)
    @board = board
    @current_player = player1
    @other_player = player2
    @between_capture = 0
    set_board
  end

#resume game from a saved file
  def from_yaml
    file = YAML.load_file('save_data.yml')
    @board = file[:board]
    @current_player = file[:current_player]
    @other_player = file[:@other_player]
    @between_capture = file[:between_capture]
  end

#save game to a ymal file
  def save_game
    yaml_file = YAML.dump({
      board: @board,
      current_player: @current_player,
      other_player: @other_player,
      between_capture: @between_capture
    })
    File.open('save_data.yml', 'w') { |f| f.write yaml_file }
  end

#ask the player if he want to save the game, if yes, use method save game and exit
  def ask_save_game
    puts "Do you want to save the game and quit? If yes, press Y or N :"
    answer = gets.chomp.downcase
    until answer == 'y' || answer == 'n'
      answer = gets.chomp.downcase
    end
    if answer == 'y'
      save_game
      exit
    end
  end

#the game process. the loop will end if anyone loose or draw.
  def start_game
    while true
      @board.display
      ask_save_game
      from = choose_from
      to = choose_to(from)
      @board.move_chessman_plus(from, to)
      break if lost? || draw?
      switch_players
    end
    puts "The game is over."
    puts "#{@current_player.name}, you lost!" if lost?
    puts "You are draw!" if draw?
  end

  def switch_players
    @current_player, @other_player = @other_player, @current_player
  end

#ask the player to choose a chesspiece, return the coordinate
  def choose_from
    puts "#{@current_player.name}, among #{@current_player.color} chesspieces, which chesspiece you want to move?"
    from = ask_coordinate
    until team?(from, @current_player.color)
      puts "You pick a wrong chessman."
      from = ask_coordinate
    end
    from
  end

#after chosen a chesspiece, ask the player where he wants to move the chesspiece. keep asking until it is a legal move.
#at the same time, keep checking the between_capture moves.

def choose_to(from)
  to = nil
  puts "#{@current_player.name}, you chose a #{@board.grids[from].class}. Now where do you want to put your chesspiece?"
  while true
    to = ask_coordinate
    if all_legal_moves.include?([from, to])
      set_between_capture(from, to)
      break
    else
      puts "Not a legal move"
    end
  end
  to
end

#track how many move between either capture or moving a pawn.
  def set_between_capture(from, to)
    if not_occupied?(to) != true
      puts "The grid you pick is occupied by your opponent, you attack it"
      @between_capture = 0
    elsif not_occupied?(to)
      puts "The grid you pick is empty and it is a legal move"
      if (@board.grids[from]).class.superclass == Pawn
        @between_capture = 0
      else
        @between_capture += 1
      end
    end
  end

#check if it is a empty grid
  def not_occupied?(coordinate)
    (@board.grids[coordinate]).nil?
  end

#check if it is a grid taken by a certain color player
  def team?(coordinate, chesspiece_color)
    return false if not_occupied?(coordinate)
    (@board.grids[coordinate]).color == chesspiece_color
  end

#ask the player a coordinate, and change the letter coordinate to a integer, return an array as coordinate
  def ask_coordinate
    x, y = ''
    until (1..8).include?(x) && (1..8).include?(y)
      puts "Input the coordinate of the target, in this format: b,2"
      answer = gets.chomp.downcase
      x = answer.scan(/\w/)[0].ord - 96
      y = answer.scan(/\w/)[1].to_i
    end
    [x,y]
  end

#set all chess pieces in original places.
  def set_board
    #white chessman
    1.upto(8){ |x| @board.add_chessman([x, 2], WhitePawn.new('white')) }
    @board.add_chessman([1, 1], WhiteRook.new('white'))
    @board.add_chessman([2, 1], WhiteKnight.new('white'))
    @board.add_chessman([3, 1], WhiteBishop.new('white'))
    @board.add_chessman([4, 1], WhiteQueen.new('white'))
    @board.add_chessman([5, 1], WhiteKing.new('white'))
    @board.add_chessman([6, 1], WhiteBishop.new('white'))
    @board.add_chessman([7, 1], WhiteKnight.new('white'))
    @board.add_chessman([8, 1], WhiteRook.new('white'))
    #black chessman
    1.upto(8){ |x| @board.add_chessman([x, 7], BlackPawn.new('black')) }
    @board.add_chessman([1, 8], BlackRook.new('black'))
    @board.add_chessman([2, 8], BlackKnight.new('black'))
    @board.add_chessman([3, 8], BlackBishop.new('black'))
    @board.add_chessman([4, 8], BlackQueen.new('black'))
    @board.add_chessman([5, 8], BlackKing.new('black'))
    @board.add_chessman([6, 8], BlackBishop.new('black'))
    @board.add_chessman([7, 8], BlackKnight.new('black'))
    @board.add_chessman([8, 8], BlackRook.new('black'))
  end

  def knight_legal_moves(coordinate)
    (@board.grids[coordinate]).possible_moves(coordinate)
  end

  def rook_legal_moves(coordinate)
    check_vertically_top(coordinate) + check_vertically_bottom(coordinate) +
    check_horizonally_left(coordinate) + check_horizonally_right(coordinate)
  end

  def check_vertically_top(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    while y < 8
      y += 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def check_vertically_bottom(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    while y > 1
      y -= 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if  team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def check_horizonally_left(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    while x > 1
      x -= 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if  team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def check_horizonally_right(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    while x < 8
      x += 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if  team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def bishop_legal_moves(coordinate)
    check_diagonally_ascend_right(coordinate) + check_diagonally_ascend_left(coordinate) +
    check_diagonally_descend_right(coordinate) + check_diagonally_descend_left(coordinate)
  end

  def check_diagonally_ascend_right(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == 8 || y == 8
      x += 1
      y += 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if  team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def check_diagonally_ascend_left(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == 1 || y == 1
      x -= 1
      y -= 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if  team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def check_diagonally_descend_right(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == 8 || y == 1
      x += 1
      y -= 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if  team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def check_diagonally_descend_left(coordinate)
    same_color = (@board.grids[coordinate]).color
    other_color = same_color == "white" ? "black" : "white"
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == 1 || y == 8
      x -= 1
      y += 1
      moves << [x, y]  if not_occupied?([x, y]) || team?([x, y],other_color)
      break if  team?([x, y],other_color) || team?([x, y], same_color)
    end
    moves
  end

  def queen_legal_moves(coordinate)
    bishop_legal_moves(coordinate) + rook_legal_moves(coordinate)
  end

  def pawn_legal_moves(coordinate)
    moves = []
    if (@board.grids[coordinate]).class == BlackPawn
      moves += blackpawn_legal_moves(coordinate)
    else
      moves += whitepawn_legal_moves(coordinate)
    end
    moves
  end

  def whitepawn_legal_moves(coordinate)
    x, y = coordinate[0], coordinate[1]
    if (@board.grids[coordinate]).moved == true
      one_step(x, y, 1, "black")
    else
      one_step(x, y, 1, "black") | two_step(x, y, 2)
    end
  end

  def one_step(x, y, a, color)
    moves = []
    moves << [x, y + a] if not_occupied?([x, y + a])
    moves << [x + 1, y + a] if team?([x + 1, y + a], color)
    moves << [x - 1, y + a] if team?([x - 1, y + a], color)
    moves
  end

  def two_step(x, y, a)
    moves = []
    moves << [x, y + a] if not_occupied?([x, y + a]) && not_occupied?([x, y + a/2])
    moves
  end

  def blackpawn_legal_moves(coordinate)
    x, y = coordinate[0], coordinate[1]
    if (@board.grids[coordinate]).moved == true
      one_step(x, y, -1, "white")
    else
      one_step(x, y, -1, "white") | two_step(x, y, -2)
    end
  end

  def king_legal_moves(coordinate)
    same_color = (@board.grids[coordinate]).color
    x, y = coordinate[0], coordinate[1]
    moves = [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1], [x + 1, y + 1],
             [x - 1, y + 1], [x + 1, y - 1], [x - 1, y - 1]].select{ |arr| (1..8).include?(arr[0]) && (1..8).include?(arr[1]) }
    moves = moves.select{ |key| (team?(key, same_color)) == false }
  end

#return all the from_to moves for castling. can not set inside #king_legal_moves, otherwise will cause "too many layers"
#because of recursive call the method by itself
  def king_castling_moves
    moves = []
    from_to = []
    from = current_king_coordinate
    moves << [x-2, y] if left_castling?(@current_player.color)
    moves << [x+2, y] if right_castling?(@current_player.color)
    moves.each do |to|
      from_to << [from,to]
    end
    from_to
  end

  def left_castling?(color)
    y = color == 'white'? 1 : 8
    left_between = [[2, y], [3, y], [4, y]]
    ((@board.grids[[5, y]]).moved == false)  && ((@board.grids[[1, y]]).moved == false)  &&  (in_check?([5, y])== false) && (left_between.none?{ |key| in_check?(key) }) && (left_between.all?{ |key| not_occupied?(key) })
  end

  def right_castling?(color)
    y = color == 'white'? 1 : 8
    right_between = [[6, y], [7, y]]
    ((@board.grids[[5, y]]).moved == false) && ((@board.grids[[8, y]]).moved == false) && (in_check?([5, y])== false) && (right_between.none?{ |key| in_check?(key) }) && (right_between.all?{ |key| not_occupied?(key) })
  end

#check if certain coordinate is in check by any opponent's chesspiece.
  def in_check?(coordinate)
    opponent_chesspieces = (@board.grids).select{ |key,value| team?(key, @other_player.color) }.keys
    (opponent_chesspieces).any?{ |key|choose_moves(key).include?(coordinate) }
  end

#return certain chesspiece's legal moves
  def choose_moves(coordinate)
    moves = []
    chess_class = (@board.grids[coordinate]).class.superclass
    return  knight_legal_moves(coordinate) if chess_class == Knight
    return  pawn_legal_moves(coordinate) if chess_class == Pawn
    return  rook_legal_moves(coordinate) if chess_class == Rook
    return  bishop_legal_moves(coordinate) if chess_class == Bishop
    return  king_legal_moves(coordinate) if chess_class == King
    return  queen_legal_moves(coordinate) if chess_class == Queen
  end

#return all the from_to legal moves. make sure the move will not put the king in check.
  def all_legal_moves
    same_color = @current_player.color
    other_color = same_color == "white" ? "black" : "white"
    all_legal_moves_collect = []
    all_same_team_coordinates = (@board.grids).select{|key,value| team?(key, same_color) }.keys
    all_same_team_coordinates.each do |from|
      choose_moves(from).each do |to|
        if put_king_in_check?(from,to) == false
          all_legal_moves_collect << [from, to]
        end
      end
    end
    (all_legal_moves_collect | (@board.en_passant_arr)) | king_castling_moves
  end

#check if no more legal moves while the king is in check
  def check_mate?
    all_legal_moves.length == 0 && in_check?(current_king_coordinate)
  end

#return the current king's coordinate
  def current_king_coordinate
    if @current_player.color == 'white'
      key = (@board.grids).select{ |key,value| value.class == WhiteKing }.keys[0]
    else
      key = (@board.grids).select{ |key,value| value.class == BlackKing }.keys[0]
    end
    key
  end

#within 50 moves, there is no movement in pawns, or no capture
  def fifty_move?
    @between_capture >= 50
  end

#the king is not in check and no legal move
  def stalemate?
    all_legal_moves.length == 0 && in_check?(current_king_coordinate) == false
  end

  def lost?
    check_mate?
  end

  def draw?
    fifty_move? || stalemate?
  end

#check if certain move could put the king in check
  def put_king_in_check?(from, to)
    store_from = @board.grids[from]
    store_to = @board.grids[to]
    @board.grids[to] = @board.grids[from]
    @board.grids[from] = nil
    result = in_check?(current_king_coordinate)
    @board.grids[from] = store_from
    @board.grids[to] = store_to
    result
  end

end
