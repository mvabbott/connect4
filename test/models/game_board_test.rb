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

  test "Parse round trip" do
    cell_values = "0 0 1 1 2 2 0\n" +
                  "0 0 1 2 2 1 0\n" +
                  "0 2 1 1 1 2 1\n" +
                  "0 1 2 2 2 1 1\n" +
                  "0 1 2 1 2 1 1\n" +
                  "0 2 1 1 2 1 2"

    @game.parse(cell_values)
    assert_equal cell_values, @game.to_s
    # spot check to ensure the right type
    assert_equal 2, @game.playerAt(3, 3)
  end

  test "Detect no win" do
    @game.parse("0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 2 0 0\n" +
                "0 0 0 0 1 0 0\n" +
                "0 0 2 1 1 0 0\n" +
                "0 2 1 2 2 1 2")
    dropAndDetectWinner(3, 3, 1, nil)
  end

  test "Detect horizontal win on end" do
    @game.parse("0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "1 1 1 0 2 2 2")
    dropAndDetectWinner(3, 5, 1, 1)
  end

  test "Detect horizontal win in middle" do
    @game.parse("0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "1 1 0 1 2 2 2")
    dropAndDetectWinner(2, 5, 1, 1)
  end


  test "Detect vertical win" do
    @game.parse("0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "1 0 0 0 0 0 0\n" +
                "1 0 0 0 0 0 0\n" +
                "1 0 0 0 2 2 2")
    dropAndDetectWinner(0, 2, 1, 1)
  end

  test "Detect bottom left to top right diagonal win" do
    @game.parse("0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 0 0 0 2 0 0\n" +
                "0 0 0 0 1 0 0\n" +
                "0 0 2 1 1 0 0\n" +
                "0 2 1 2 2 1 1")
    dropAndDetectWinner(3, 3, 2, 2)
  end

  test "Detect top left to bottem right diagonal win" do
    @game.parse("0 0 0 0 0 0 0\n" +
                "0 0 0 0 0 0 0\n" +
                "0 2 0 0 0 0 0\n" +
                "0 1 2 0 0 0 0\n" +
                "0 1 1 0 0 0 0\n" +
                "0 2 1 2 2 1 1")
    dropAndDetectWinner(3, 4, 2, 2)
  end

  test "Detect not draw yet" do
    @game.parse("2 2 0 1 1 0 2\n" +
                "1 1 2 2 2 1 1\n" +
                "2 2 1 1 1 2 2\n" +
                "1 1 2 2 2 1 1\n" +
                "2 2 1 1 1 2 2\n" +
                "1 1 2 2 2 1 1")
    dropAndDetectWinner(2, 0, 1, nil)
  end

  test "Detect draw" do
    @game.parse("2 2 1 1 1 0 2\n" +
                "1 1 2 2 2 1 1\n" +
                "2 2 1 1 1 2 2\n" +
                "1 1 2 2 2 1 1\n" +
                "2 2 1 1 1 2 2\n" +
                "1 1 2 2 2 1 1")
    dropAndDetectWinner(5, 0, 2, 0)
  end

  def dropAndValidate(col, expected_row, expected_player)
    @game.drop(col)
    assert_equal expected_player, @game.playerAt(col, expected_row)
  end

  def dropAndDetectWinner(col, expected_row, expected_player, expected_winner)
    #no winner yet
    assert_nil @game.winner

    #drop 4th across to win (unless expected_winner is nil)
    dropAndValidate(col, expected_row, expected_player)
    if (expected_winner.nil?)
      assert_nil @game.winner
    else
      assert_equal expected_winner, @game.winner
    end
  end
end
