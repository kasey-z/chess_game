require_relative 'chesspiece.rb'
class Knight < ChessPiece
  def possible_moves(coordinate)
    x = coordinate[0]
    y = coordinate[1]
    moves = [[x + 1, y + 2],[x + 1, y - 2],[x - 1, y + 2],[x - 1, y - 2],
             [x + 2, y + 1],[x + 2, y - 1],[x - 2, y + 1],[x - 2, y - 1]].select{|arr| (1..8).include?(arr[0]) && (1..8).include?(arr[1])}
  end

end

class WhiteKnight < Knight
  def symbol
    "\u2658"
  end
end

class BlackKnight < Knight
  def symbol
    "\u265E"
  end
end
