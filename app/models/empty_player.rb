class EmptyPlayer < Player
  def initialize
    super(0)
  end

  def empty?
    true
  end
end
