class ChessPiece
  attr_reader :color
  attr_accessor :moved
  def initialize(color)
    @moved = false
    @color = color
  end
end
