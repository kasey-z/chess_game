require './chesspiece'
class Knight < ChessPiece

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
