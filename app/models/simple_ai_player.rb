class SimpleAiPlayer < Player
  def ai?
    true
  end

  def empty?
    false
  end

  def symbol
    :simple_ai
  end

  def find_next_move(game)
    0
  end
end
