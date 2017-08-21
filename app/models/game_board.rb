class GameBoard
  def initialize
    @num_col = 7
    @num_row = 6
    @cells = Array.new(@num_col) { Array.new(@num_row) { Cell.new } }
  end

  def drop(col)
    row = @cells[col].rindex { |cell| cell.available? }
    @cells[col][row].assign(1)
  end

  def playerAt(col, row)
    @cells[col][row].owner
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
