require_relative 'chesspiece.rb'
class Bishop < ChessPiece

end

class WhiteBishop < Bishop
  def symbol
    "\u2657"
  end
end

class BlackBishop < Bishop
  def symbol
    "\u265D"
  end
end
