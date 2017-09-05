require 'spec_helper'
require 'game'

describe Game do
  let(:player1) {Player.new('Jessica','white')}
  let(:player2) {Player.new('Erin', 'black')}
  let(:game)    {Game.new(player1, player2)}

  describe "#initialize" do
    it "initialize the between_capture to zero" do
      expect(game.between_capture).to eql(0)
    end

    it "initialize the board [1,1] a whiteRook" do
      expect(game.board.grids[[1,1]].class).to eql(WhiteRook)
    end
  end

  describe "#knight_legal_moves" do
    it "returns the knight's possible move" do
      expect(game.knight_legal_moves([2,1])).to include([3,3])
    end
  end

  describe "#choose_moves" do
    it "returns the possible moves of the knight" do
      expect(game.choose_moves([2,1])).to include([3,3])
    end

    it "does not include the illegal move" do
      expect(game.choose_moves([2,1])).not_to include([3,2])
    end
  end

  describe "#pawn_legal_moves" do
    it "returns the possible move of a pawn" do
      expect(game.pawn_legal_moves([2,2])).to include([2,3])
    end
  end

  describe "#not_occupied?" do
    it "check if the grids is empty" do
      expect(game.not_occupied?([3,3])).to eql(true)
    end
  end

  describe "#in_check?" do
    it "returns true for [3,6]" do
      expect(game.in_check?([3,6])).to eql(true)
    end

    it "returns false for [3,3]" do
      expect(game.in_check?([3,4])).to eql(false)
    end
  end

  describe "#all_legal_moves" do
    it "returns all legal from,to" do
      expect(game.all_legal_moves).to include([[2,1],[3,3]])
    end
  end

end
