class Cell
  attr_reader :owner

  def initialize(owner=0)
    @owner = owner
  end

  def available?
    return @owner == 0
  end

  def assign(player)
    @owner = player
    self
  end

end
