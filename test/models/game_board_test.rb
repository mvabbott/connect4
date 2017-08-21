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

  test "Error when dropping to invalid column" do
    assert_raise { @game.drop(@game.num_col) }
  end

  test "Error when dropping to full column" do
    # fill up column
    @game.num_row.times { @game.drop(1) }
    (0..@game.num_row-1).each { |row| assert_equal 1, @game.playerAt(1, row) }

    # try to add one more
    assert_raise { @game.drop(1) }
  end

end
