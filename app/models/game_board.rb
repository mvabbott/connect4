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
# an available cell, 1 for player 1 or 2 for player 2. 

class GameBoard
  attr_reader :num_col, :num_row, :next_player

  def initialize
    @num_col = 7
    @num_row = 6
    @cells = Array.new(@num_col) { Array.new(@num_row) { Cell.new } }
    @next_player = 1
  end

  def drop(col)
    # Using fetch to cause IndexError rather than return nil
    # TODO Look for a cleaner way to raise errors (with friendly messages)
    row = @cells.fetch(col).rindex { |cell| cell.available? }
    @cells[col].fetch(row).assign(@next_player)
    update_next_player
  end

  def playerAt(col, row)
    @cells[col][row].owner
  end

  def update_next_player
    @next_player = @next_player == 1 ? 2 : 1
  end

  def display
    (0..@num_row-1).each do |row|
      (0..@num_col-1).each do |col|
        print "#{playerAt(col, row)} "
      end
      print "\n"
    end
  end
end
