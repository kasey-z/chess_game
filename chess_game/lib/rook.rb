require './chesspiece'
class Rook < ChessPiece
end

class WhiteRook < Rook
  def symbol
    "\u2656"
  end
end

class BlackRook < Rook
  def symbol
    "\u265C"
  end
end
