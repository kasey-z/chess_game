require './chesspiece'
class King < ChessPiece

end

class WhiteKing < King
  def print
    "\u2654"
  end
end

class BlackKing < King
  def print
    "\u265A"
  end
end
