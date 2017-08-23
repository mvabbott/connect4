require 'test_helper'

class PlayerQueueTest < ActiveSupport::TestCase
  def setup
    @player_queue = PlayerQueue.new
    @player1 = Player.new(1)
    @player2 = Player.new(2)
    @player_queue.add(@player1)
    @player_queue.add(@player2)
  end

  test "New PlayerQueue has EmptyPlayer" do
    assert_not_nil @player_queue.empty
  end

  test "All players includes empty player" do
    assert_equal [@player_queue.empty, @player1, @player2], @player_queue.all_players
  end

  test "next_player advances to next player" do
    assert_equal @player1, @player_queue.current_player
    assert_equal @player2, @player_queue.next_player
    assert_equal @player2, @player_queue.current_player
  end
end
