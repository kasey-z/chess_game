class Board
  attr_accessor :grids, :en_passant_permition

  def initialize
    @grids = {}
    @en_passant_permition = []
    insert_coordinates
  end

  def generate_coordinates
    arr = []
    1.upto(8) { |x| 1.upto(8) { |y| arr << [x,y] } }
    arr
  end

  def insert_coordinates
    arr = generate_coordinates
    arr.each do |key|
      @grids[key] = nil
    end
  end

  def add_chessman(coordinate, chessman)
    @grids[coordinate] = chessman
  end

  def move_chessman_plus(from, to)
    castled_rook_move(from, to)
    move_chessman(from, to)
    take_en_passant(from, to)
    pawn_promotion(to)
    @en_passant_permition = []
  end

  def pawn_promotion(to)
    if @grids[to].class == WhitePawn && to[1] == 8
      add_chessman(to, WhiteQueen.new('white'))
    end
    if @grids[to].class == BlackPawn && to[1] == 1
      add_chessman(to, BlackQueen.new('black'))
    end
  end


  def take_en_passant(from, to)
    move = @en_passant_permition
    if move.empty? == false
      if pawn_took_en_passant?(from, to)
        if to[1] == 3
          @grids[[to[0], 4]] = nil
        elsif to[1] == 6
          @grids[[to[0], 5]] = nil
        end
      end
    end
  end

  def pawn_took_en_passant?(from, to)
    @grids[from].class.superclass == Pawn && (from == move[0][0] || from == move[1][0]) && to == move[0][1]
  end

  def castled_rook_move(from, to)
    if @grids[from].class.superclass == King
      if moved_distance_x(from, to) == -2
        move_chessman([1, from[1]], [4, from[1]])
      end
      if moved_distance_x(from, to) == 2
        move_chessman([8, from[1]], [6, from[1]])
      end
    end
  end

  def en_passant_permit(from, to, x, y)
    if @grids[to[0] + x, to[1]].class.superclass == Pawn &&  @grids[to[0] + x, to[1]].color != @grids[from].color
      @en_passant = true
      [[to[0] + x, to[1]], [to[0], to[1] + y]]
    end
  end


  def en_passant(from, to)
    if @grids[from].class.superclass == Pawn &&
      if moved_distance_y(from, to) == -2
        @en_passant_permition << en_passant_permition(from, to, 1, -1)
        @en_passant_permition << en_passant_permition(from, to, -1, -1)
      elsif moved_distance_y(from, to) == 2
        @en_passant_permition << en_passant_permition(from, to, 1, +1)
        @en_passant_permition << en_passant_permition(from, to, -1, +1)
      end
    end
  end

  def move_chessman(from, to)
    @grids[to] = @grids[from]
    @grids[from] = nil
  end

  def moved_distance_x(from, to)
    from[0]-to[0]
  end

  def moved_distance_y(from, to)
    from[1]-to[1]
  end

  def print(chessman)
    if chessman.nil?
      "\u26F6"
    else
      chessman.symbol
    end
  end

  def display
    system('cls')
    puts ''
    puts ''
    puts "                        ~ Chess Game ~"
    puts ''
    puts "              +" + "----------------------------------+"
    8.downto(1) do |y|
      string = "            #{y} |"
      for x in (1..8) do
        string += " #{@grids[[x,y]].print} |"
      end
      puts string
      puts "              +" + "----------------------------------+"
    end
    puts "                 a   b   c    d   e   f    g   h"
    puts ''
    puts ''
  end


end
