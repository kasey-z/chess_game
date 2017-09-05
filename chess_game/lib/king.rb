require_relative 'chesspiece.rb'
class King < ChessPiece

end

class WhiteKing < King
  def symbol
    "\u2654"
  end
end

class BlackKing < King
  def symbol
    "\u265A"
  end
end
