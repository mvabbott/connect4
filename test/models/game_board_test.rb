require 'test_helper'

class GameBoardTest < ActiveSupport::TestCase
  def setup
    @game = GameBoard.new
  end

  test "drop fills bottom row" do
    dropAndValidate(1, @game.num_row - 1, 1)
    assert_equal 0, @game.playerAt(1, 4), "next row up is filled"
  end

  test "Error when dropping to invalid column" do
    assert_raise { @game.drop(@game.num_col) }
  end

  test "Error when dropping to full column" do
    # fill up column
    @game.num_row.times { |i| dropAndValidate(1, @game.num_row - (i+1), i%2 + 1) }

    # try to add one more
    assert_raise { @game.drop(1) }
  end

  test "Drop alternates players" do
    3.times do |i|
      dropAndValidate(1, @game.num_row - (i+1), i%2 + 1)
    end
  end

  def dropAndValidate(col, expectedRow, expectedPlayer)
    @game.drop(col)
    assert_equal expectedPlayer, @game.playerAt(col, expectedRow)
  end

end
