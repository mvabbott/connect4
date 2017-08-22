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
  attr_reader :num_col, :num_row, :next_player, :winner

  def initialize
    @num_col = 7
    @num_row = 6
    @cells = Array.new(@num_col) { Array.new(@num_row) { Cell.new } }
    @next_player = :player1
    @winner = nil
    @player_controller = {}
    set_player_controller(:player1, :human)
    set_player_controller(:player2, :human)
  end

  # TODO improve error handling, bad size or values will result in invalid game
  def parse(board)
    int_to_player = { 0 => :empty, 1 => :player1, 2 => :player2 }

    # split rows and then columns, resulting in array indexed by row and then
    # by column, opposite of how @cells is indexed.
    cell_values = board.split("\n").map { |row| row.split(" ") }
    player_moves = { empty: 0, player1: 0, player2: 0 }

    (0..num_col-1).each do |col|
      (0..num_row-1).each do |row|
        player = int_to_player[cell_values[row][col].to_i]
        @cells[col][row].assign(player)
        player_moves[player] = player_moves[player] + 1
      end
    end

    if (player_moves[:player1] > player_moves[:player2])
      @next_player = :player2
    else
      @next_player = :player1
    end
  end

  def to_s
    player_to_int = { empty: 0, player1: 1, player2: 2 }
    cell_values = Array.new(@num_row) { Array.new(@num_col) }

    (0..@num_row-1).each do |row|
      (0..@num_col-1).each do |col|
        cell_values[row][col] = player_to_int[player_at(col, row)]
      end
    end

    cell_values.map { |row| row.join(" ") }.join("\n")
  end

  def column_available?(col)
    player_at(col, 0) == :empty
  end

  def drop(col)
    # Using fetch to cause IndexError rather than return nil
    # TODO Look for a cleaner way to raise errors (with friendly messages)
    row = @cells.fetch(col).rindex { |cell| cell.available? }
    @cells[col].fetch(row).assign(@next_player)
    update_winner(col, row, @next_player)
    update_next_player
  end

  def player_at(col, row)
    if (valid_coordinates?(col, row))
      @cells[col][row].owner
    else
      :empty
    end
  end

  def valid_coordinates?(col, row)
    0 <= col && col < @num_col && 0 <= row && row < @num_row
  end

  def update_winner(col, row, player)
    if (@winner.nil?)
      @winner = check_for_winner(col, row, player)
    end
    if (@winner.nil? && draw?)
      @winner = :empty
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
    (0..@num_col-1).all? { |col| player_at(col, 0) != :empty }
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
    @next_player = @next_player == :player1 ? :player2 : :player1

    if @player_controller[@next_player].ai?
      drop(@player_controller[@next_player].find_next_move(self))
    end
  end

  def player_controller(player)
    @player_controller[player].symbol
  end

  # TODO add additional error checks
  def set_player_controller(player, controller)
    if controller == :human
      @player_controller[player] = HumanPlayer.new
    elsif controller == :simple_ai
      @player_controller[player] = SimpleAiPlayer.new
      if player == @next_player
        drop(@player_controller[player].find_next_move(self))
      end
    end
  end
end
