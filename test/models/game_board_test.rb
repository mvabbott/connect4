require 'test_helper'

class GameBoardTest < ActiveSupport::TestCase
  def setup
    @game = GameBoard.new
  end

  test "drop fills bottom row" do
    @game.drop(1)
    assert_equal 1, @game.playerAt(1, 5), "expected cell has player 1"
    assert_equal 0, @game.playerAt(1, 4), "next row up is filled"
  end

end
