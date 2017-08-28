require 'yaml'
require './bishop'
require './board'
require './chesspiece'
require './king'
require './knight'
require './pawn'
require './player'
require './queen'
require './rook'

class Game
  attr_accessor :players, :board, :current_player, :other_player, :between_capture

  def initialize(players, board = Board.new)
    @players = players
    @board = board
    @current_player, @other_player = players.shuffle
    @between_capture = 0
    set_board
  end

  def from_yaml
    file = YAML.load_file('save_data.yml')
    @board = file[:board]
    @current_player = file[:current_player]
    @other_player = file[:@other_player]
    @between_capture = file[:between_capture]
  end

  def save_game
    yaml_file = YAML.dump({
      board: @board,
      current_player: @current_player,
      other_player: @other_player,
      between_capture: @between_capture
    })
    File.open('save_data.yml', 'w') { |f| f.write yaml_file }
  end

  def ask_save_game
    puts "Do you want to save the game and quit? If yes, press Y or N :"
    answer = gets.chomp.downcase
    until answer == 'y' || answer = 'n'
      answer = gets.chomp.downcase
    end
    if aswer == 'y'
      save_game
      exit
    end
  end

  def start_game
    while true
      from = choose_from
      to = choose_to(from)
      move_chessman_plus(from, to)
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

  def choose_from
    puts "#{@current_player.name}, among #{color} chessman, which chessman you want to move?"
    from = ask_coordinate
    until same_team?(from)
      puts "You pick a wrong chessman."
      from = ask_coordinate
    end
    from
  end

  def choose_to(from)
    acceptable_to = false
    to = nil
    puts "#{@current_player.name}, now where do you want to put your chesspiece?"
    while acceptable_to == false
      to = ask_coordinate
      if attack_move?(from, to)
        puts "The grid you pick is occupied by your opponent, you attack it"
        @between_capture = 0
        acceptable_to = true
      elsif occupied_without_attack?(from, to)
        puts "The grid you pick is empty and it is a legal move"
        if @board.grids[from].class.superclass == Pawn
          @between_capture = 0
        else
          @between_capture += 1
        end
        acceptable_to = true
      else
        puts "It is not a legal move. Please choose another grid."
      end
    end
    to
  end

  def attack_move?(from, to)
    @board.grids[to].color == @other_player.color && choose_moves(from).include?(to)
  end

  def occupied_without_attack?(from, to)
    @board.grids[to].color == nil && choose_moves(from).include?(to)
  end

  def same_team?(coordinate)
    @board.grids[coordinate].color == @current_player.color
  end

  def not_occupied?(coordinate)
    @board.grids[coordinate].nil?
  end

  def opponent_team?(coordinate)
    @board.grids[coordinate].color == @other_player.color
  end

  def place_chessman
    puts "#{@current_player.name}, where do you want to place the chessman?"
    ask_coordinate
  end

  def ask_coordinate
    x,y = ''
    until (1..8).include?x && (1..8).include?y
      puts "Input the coordinate of the target, in this format: b,2"
      answer = gets.chomp.downcase
      x = answer.scan(/\w/)[0].ord - 96
      y = answer.scan(/\w/)[1].to_i
    end
    [x,y]
  end

#create chesspiece in the board
  def set_board
    #white chessman
    1.upto(8){ |x|add_chessman([x, 2], WhitePawn.new('white')) }
    add_chessman([1, 1], WhiteRook.new('white'))
    add_chessman([2, 1], WhiteKnight.new('white'))
    add_chessman([3, 1], WhiteBishop.new('white'))
    add_chessman([4, 1], WhiteQueen.new('white'))
    add_chessman([5, 1], WhiteKing.new('white'))
    add_chessman([6, 1], WhiteBishop.new('white'))
    add_chessman([7, 1], WhiteKnight.new('white'))
    add_chessman([8, 1], WhiteRook.new('white'))
    #black chessman
    1.upto(8){ |x|add_chessman([x, 7], BlackPawn.new('black')) }
    add_chessman([1, 7], BlackRook.new('black'))
    add_chessman([2, 7], BlackKnight.new('black'))
    add_chessman([3, 7], BlackBishop.new('black'))
    add_chessman([4, 7], BlackQueen.new('black'))
    add_chessman([5, 7], BlackKing.new('black'))
    add_chessman([6, 7], BlackBishop.new('black'))
    add_chessman([7, 7], BlackKnight.new('black'))
    add_chessman([8, 7], BlackRook.new('black'))
  end

  def knight_legal_moves(coordinate)
    @board.grids[coordinate].possible_moves(coordinate)
  end

  def rook_legal_moves(coordinate)
    check_vertically_top(coordinate) + check_vertically_bottom(coordinate) +
    check_horizonally_left(coordinate) + check_horizonally_right(coordinate)
  end

  def check_vertically_top(coordinate)
    x, y = coordinate[0], coordinate[1]
    moves = []
    while y < 8
      y += 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def check_vertically_bottom(coordinate)
    x, y = coordinate[0], coordinate[1]
    moves = []
    while y > 1
      y -= 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def check_horizonally_left(coordinate)
    x, y = coordinate[0], coordinate[1]
    moves = []
    while x > 1
      x -= 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def check_horizonally_right(coordinate)
    x, y = coordinate[0], coordinate[1]
    moves = []
    while x < 8
      x += 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def bishop_legal_moves(coordinate)
    check_diagonally_ascend_right(coordinate) + check_diagonally_ascend_left(coordinate) +
    check_diagonally_descend_right(coordinate) + check_diagonally_descend_left(coordinate)
  end

  def check_diagonally_ascend_right(coordinate, d = 8, e = 8)
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == d || y == e
      x += 1
      y += 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def check_diagonally_ascend_left(coordinate, d = 1, e = 1)
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == d || y == e
      x -= 1
      y -= 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def check_diagonally_descend_right(coordinate, d = 8, e = 1)
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == d || y == e
      x += 1
      y -= 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def check_diagonally_descend_left(coordinate, d = 1, e = 8)
    x, y = coordinate[0], coordinate[1]
    moves = []
    until  x == d || y == e
      x -= 1
      y += 1
      moves << [x, y]  if not_occupied?([x, y]) || opponent_team?([x, y])
      break if  opponent_team?([x, y]) || same_team?([x, y])
    end
    moves
  end

  def queen_legal_moves(coordinate)
    bishop_legal_moves(coordinate) + rook_legal_moves(coordinate)
  end

  def pawn_legal_moves(coordinate)
    en_passant = @board.en_passant_permition
    moves = []
    if coordinate == en_passant[0][0] || coordinate == en_passant[1][0]
      moves << en_passant[0][1]
    end
    if @board.grids[coordinate].class == BlackPawn
      moves += blackpawn_legal_moves(coordinate)
    else
      moves += whitepawn_legal_moves(coordinate)
    end
    moves
  end

  def whitepawn_legal_moves(coordinate)
    x, y = coordinate[0], coordinate[1]
    if @board.grids[coordinate].moved == true
      one_step(x, y, 1)
    else
      one_step(x, y, 1) + two_step(x, y, 2)
    end
  end



  def one_step(x, y, a)
    moves = []
    moves << [x, y + a] if not_occupied?([x, y + a])
    moves << [x + 1, y + a] if opponent_team?([x + 1, y + a])
    moves << [x - 1, y + a] if opponent_team?([x - 1, y + a])
    moves
  end

  def two_step(x, y, a)
    moves = []
    moves << [x, y + a] if not_occupied?([x, y + a]) && not_occupied?([x, y + a/2])
    moves
  end

  def blackpawn_legal_moves(coordinate)
    x, y = coordinate[0], coordinate[1]
    if @board.grids[coordinate].moved == true
      one_step(x, y, -1)
    else
      one_step(x, y, -1) + two_step(x, y, -2)
    end
  end

  def king_legal_moves(coordinate)
    moves = king_possibel_moves(coordinate).select{|key| in_check?(key) == false && same_team?(key) == false }
    moves += king_castal_move(coordinate)
  end

  def king_possibel_moves(coordinate)
    x, y = coordinate[0], coordinate[1]
    moves = [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1], [x + 1, y + 1],
             [x - 1, y + 1], [x + 1, y - 1], [x - 1, y - 1]].select{ |arr| (1..8).include?arr[0] && (1..8).include?arr[1] }
    if left_castling?(@current_player.color)
      moves << [x - 2, y]
    elsif right_castling?(@current_player.color)
      moves << [x + 2, y]
    end
  end

  def king_castal_move(coordinate)
    x, y = coordinate[0], coordinate[1]
    moves = []
    if left_castling?(@current_player.color)
      moves << [x-2, y]
    end
    if right_castling?(@current_player.color)
      moves << [x+2, y]
    end
  end

  def in_check?(coordinate)
    opponent_checkpices = @board.grids.select{|key,value| value.color == @other_player.color}
    opponent_checkpices.any?{ |key,value|choose_moves(key).include?(coordinate) }
    end
  end

  def choose_moves(coordinate)
    moves = []
    chesspiece = @board.grids[coordinate].class.superclass
    case chesspiece
    when Bishop
      moves += bishop_legal_moves(coordinate)
    when King
      moves += king_legal_moves(coordinate)
    when Knight
      moves += king_possibel_moves(coordinate)
    when Pawn
       moves += pawn_legal_moves(coordinate)
    when Queen
      moves += queen_legal_moves(coordinate)
    when Rook
      moves += rook_legal_moves(coordinate)
    end
    moves
  end

  def left_castling?(color)
    y = color == 'white'? 1 : 8
    left_between = [[2, y], [3, y], [4, y]]
    @board.grids[[5, y]].moved == false  &&  @board.grids[[1, y]].moved == false  &&  in_check?([5, y])== false && left_between.none?{ |key| in_check?(key) } && left_between.all?{ |key| not_occupied?(key) }
  end

  def right_castling?(color)
    y = color == 'white'? 1 : 8
    right_between = [[6, y], [7, y]]
    @board.grids[[5, y]].moved == false  &&  @board.grids[[8, y]].moved == false  &&  in_check?([5, y])== false && right_between.none?{ |key| in_check?(key) } && right_between.all?{ |key| not_occupied?(key) }
  end

  def check_mate?
    key = @board.grids.select{|key,value| value.class == King && value.color == @current_player.color }.keys[0]
    king_legal_moves(key).empty? ? true : false
  end

  def fifty_move?
    @between_capture >= 50
  end

  def stalemate?
    chesspiece_inteam = @board.grids.select{|key,value|value.color == @current_player.color}.keys
    chesspiece_inteam.all?{|key|(choose_moves(key)-chesspiece_inteam).empty? == true}
  end

  def lost?
    check_mate?
  end

  def draw?
    fifty_move? || stalemate?
  end

end
