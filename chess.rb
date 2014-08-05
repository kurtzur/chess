require_relative 'pieces'
require_relative 'board'

if $PROGRAM_NAME == __FILE__
  b = Board.new
  g = Game.new(b)
  g.play_game
end