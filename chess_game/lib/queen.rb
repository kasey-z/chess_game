require_relative 'chesspiece.rb'
class Queen < ChessPiece
end

class WhiteQueen < Queen
  def symbol
    "\u2655"
  end
end

class BlackQueen < Queen
  def symbol
    "\u265B"
  end
end
