class Player
  attr_reader :player_number

  def initialize(player_number)
    @player_number = player_number
  end

  def empty?
    false
  end

  def draw?
    false
  end
end
