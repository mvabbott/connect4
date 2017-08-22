require './app/models/game_board'
require './app/models/cell'

# Not sure if this is the right place for this, but it won't be needed once the
# web interface is done.
class Connect4Cli
  def initialize
    @game = GameBoard.new
  end

  def play
    while @game.winner.nil?
      play_turn
    end

    draw_board
    if @game.winner == 0
      puts "\nDraw"
    else
      puts "\nWinner is player #{@game.winner}"
    end
  end

  def play_turn
    draw_board
    print "Select column for player #{@game.next_player}: "
    col = Integer(gets) rescue nil
    if col.nil? || col < 0 || col >= @game.num_col
      puts "\nInvalid column, enter a number from 0 to #{@game.num_col - 1}"
    elsif !@game.column_available?(col)
      puts "\nColumn is full, pick again."
    else
      @game.drop(col)
    end
  end

  def draw_board
    puts "\n0 1 2 3 4 5 6"
    puts   "-------------"
    @game.display

  end
end

cli = Connect4Cli.new
cli.play
