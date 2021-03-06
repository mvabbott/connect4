class Cell
  attr_reader :owner

  def initialize(owner)
    @owner = owner
  end

  def available?
    return @owner.empty?
  end

  def assign(player)
    @owner = player
    self
  end

end
