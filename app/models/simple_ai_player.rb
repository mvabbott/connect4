class SimpleAiPlayer < Player
  def ai?
    true
  end

  def find_next_move(game)
    move = find_winning_move(game)
    move = find_blocking_move(game) if move.nil?
    move = find_available_column(game) if move.nil?

    move
  end

  def find_winning_move(game)
    find_winning_move_for(game, self)
  end

  def find_blocking_move(game)
    find_winning_move_for(game, opponent(game))
  end

  def find_winning_move_for(game, player)
    (0..game.num_col-1).find do |col|
      row = game.get_available_row(col)
      if row.nil?
        false
      else
        game.winning_move?(col, row, player)
      end
    end
  end

  def find_available_column(game)
    available_moves = (0..game.num_col-1).select do |col|
      row = game.get_available_row(col)
    end

    available_moves[rand(available_moves.length)]
  end

  def opponent(game)
    opponent_number = player_number == 1 ? 2 : 1
    game.find_player_by_number(opponent_number)
  end
end
