# GameBoard contains the grid of cells for the Connect 4 game.  The grid is
# layed out with the following format:
#
#        Columns
#     0 1 2 3 4 5 6
#   0 . . . . . . .
# R 1 . . . . . . .
# o 2 . . . . . . .
# w 3 . . . . . . .
# s 4 . . . . . . .
#   5 . . . . . . .
#
# Each cell contains a Cell object, which has an owner, with 0 representing
# an available cell, 1 for player 1 or 2 for player 2.  This is implemented as
# nexted arrays, with the column index as the outer array, and the row indexed
# on the inner array.

class GameBoard
  attr_reader :num_col, :num_row, :winner

  def initialize(player_types)
    build_player_queue(player_types)
    @num_col = 7
    @num_row = 6
    @cells = Array.new(@num_col) { Array.new(@num_row) { Cell.new(@player_queue.empty) } }
    @winner = nil
  end

  def build_player_queue(player_types)
    @player_queue = PlayerQueue.new
    player_number = 1
    player_types.each do |type|
      if type == :human
        @player_queue.add(HumanPlayer.new(player_number))
      elsif type == :simple_ai
        @player_queue.add(SimpleAiPlayer.new(player_number))
      else
        raise ArgumentError("Invalid player_type #{type}.")
      end
      player_number = player_number + 1
    end
  end

  # TODO improve error handling, bad size or values will result in invalid game
  def parse(board)
    # split rows and then columns, resulting in array indexed by row and then
    # by column, opposite of how @cells is indexed.
    cell_values = board.split("\n").map { |row| row.split(" ") }
    player_moves = Hash.new(0)

    (0..num_col-1).each do |col|
      (0..num_row-1).each do |row|
        player = find_player_by_number(cell_values[row][col].to_i)
        @cells[col][row].assign(player)
        player_moves[player] = player_moves[player] + 1
      end
    end

    set_player_queue_order(player_moves)
  end

  def set_player_queue_order(player_moves)
    player_moves.delete(@player_queue.empty)
    new_player_order = player_moves.to_a.sort do |a, b|
      if a[1] == b[1]
        # same number of moves order by player number
        a[0].player_number <=> b[0].player_number
      else
        # otherwise sort by number of moves
        a[1] <=> b[1]
      end
    end
    @player_queue.queue = new_player_order.map { |a| a[0] }
  end

  def find_player_by_number(player_number)
    @player_queue.find { |player| player.player_number == player_number }
  end

  def to_s
    cell_values = Array.new(@num_row) { Array.new(@num_col) }

    (0..@num_row-1).each do |row|
      (0..@num_col-1).each do |col|
        cell_values[row][col] = player_at(col, row).player_number
      end
    end

    cell_values.map { |row| row.join(" ") }.join("\n")
  end

  def column_available?(col)
    player_at(col, 0).empty?
  end

  def drop(col)
    # Using fetch to cause IndexError rather than return nil
    # TODO Look for a cleaner way to raise errors (with friendly messages)
    row = @cells.fetch(col).rindex { |cell| cell.available? }
    @cells[col].fetch(row).assign(@player_queue.current_player)
    update_winner(col, row)
    update_next_player
  end

  def player_at(col, row)
    if (valid_coordinates?(col, row))
      @cells[col][row].owner
    else
      @player_queue.empty
    end
  end

  def current_player
    @player_queue.current_player
  end

  def valid_coordinates?(col, row)
    0 <= col && col < @num_col && 0 <= row && row < @num_row
  end

  def update_winner(col, row)
    if (@winner.nil?)
      @winner = check_for_winner(col, row, @player_queue.current_player)
    end
    if (@winner.nil? && draw?)
      @winner = @player_queue.empty
    end
  end

  # Don't set the winner status here, it will later be used by the AI to decide when
  # to pick a column in order to win or block the player from winning.
  def check_for_winner(col, row, player)
    # TODO clean this method up, it's pretty ugly right now
    left_count = get_count(col, row, player) { |col, row| [col - 1, row] }
    right_count = get_count(col, row, player) { |col, row| [col + 1, row] }
    # checking as we add, so no need to check up from current coordinates
    down_count = get_count(col, row, player) { |col, row| [col, row + 1] }
    down_left_count = get_count(col, row, player) { |col, row| [col - 1, row + 1] }
    up_right_count = get_count(col, row, player) { |col, row| [col + 1, row - 1] }
    up_left_count = get_count(col, row, player) { |col, row| [col - 1, row - 1] }
    down_right_count = get_count(col, row, player) { |col, row| [col + 1, row + 1] }


    if (left_count + 1 + right_count >= 4 ||
        down_count + 1 >= 4 ||
        down_left_count + 1 + up_right_count >= 4 ||
        up_left_count + 1 + down_right_count >= 4)
      return player
    else
      return nil
    end
  end

  def draw?
    (0..@num_col-1).all? { |col| !player_at(col, 0).empty? }
  end

  def get_count(col, row, player, &block)
    new_coordinates = block.call(col, row)
    new_col = new_coordinates[0]
    new_row = new_coordinates[1]

    if (player_at(new_col, new_row) == player)
      return 1 + get_count(new_col, new_row, player, &block)
    else
      return 0
    end
  end

  def update_next_player
    @player_queue.next_player

    if @player_queue.current_player.ai?
      drop(@player_queue.current_player.find_next_move(self))
    end
  end
end
