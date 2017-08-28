require './chesspiece'
class Pawn < ChessPiece

end

class WhitePawn < Pawn
  def symbol
    "\u2659"
  end
end

class BlackPawn < Pawn
  def symbol
    "\u265F"
  end
end
