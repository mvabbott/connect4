require './app/models/game_board'
require './app/models/cell'
require './app/models/player'
require './app/models/human_player'
require './app/models/simple_ai_player'
require './app/models/player_queue'
require './app/models/empty_player'

# Not sure if this is the right place for this, but it won't be needed once the
# web interface is done.
class Connect4Cli

  def start_game
    player1_type = get_player_type(1)
    player2_type = get_player_type(2)
    @game = GameBoard.new([player1_type, player2_type])

    play
  end

  def get_player_type(player_number)
    puts "Player #{player_number}, enter 1 for human player or 2 for ai player:"
    value = Integer(gets) rescue nil
    if value == 1
      return :human
    elsif value == 2
      return :simple_ai
    else
      puts "Invalid, try again."
      return get_player_type(player_number)
    end
  end

  def play
    while @game.winner.nil?
      play_turn
    end

    draw_board
    if @game.winner == :empty
      puts "\nDraw"
    else
      puts "\nWinner is #{@game.winner}"
    end
  end

  def play_turn
    draw_board
    print "Select column for player #{@game.current_player.player_number}: "
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
    puts @game.to_s
  end
end

cli = Connect4Cli.new
cli.start_game
