class PlayerQueue
  attr_reader :empty

  def initialize
    @empty = EmptyPlayer.new
    @queue = []
  end

  def all_players
    [@empty] + @queue
  end

  def find(&block)
    all_players.find(&block)
  end

  def add(player)
    @queue.push(player)
  end

  def queue=(queue)
    @queue = queue
  end

  def current_player
    @queue.first
  end

  def next_player
    # Move current player to end of queue
    @queue.push(@queue.shift)

    current_player
  end


end
