class HumanPlayer < Player
  def ai?
    false
  end

  def empty?
    false
  end

  def symbol
    :human
  end
end
