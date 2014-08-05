# encoding: utf-8

# require 'debugger'
class Piece
  attr_reader :board, :color
  attr_accessor :position
  constants = [:DIAGS, :HV, :LS]
  unless constants.all? { |constant| const_defined?(constant) }
    DIAGS = [ [1, 1], [-1, 1], [-1, -1], [1,-1] ]
    HV = [ [0, 1], [1, 0], [0, -1], [-1, 0] ] #horizontal and vertical
    LS = [ [2, 1], [2, -1], [-2, 1], [-2 ,-1], [1, 2], [1, -2], [-1, 2], [-1,-2] ]
  end
  
  def initialize(board, position, color)
    @board = board
    @position = position
    @color = color
  end
  
  def move_into_check?(destination)
    board_copy = @board.dup
    board_copy.move!(self.position, destination)
    board_copy.in_check?(self.color)
  end
  
  def valid_moves
    self.moves.reject{ |place| self.move_into_check?(place) }
  end
end

class SlidingPiece < Piece
  def moves
    valid_places = []
    self.dirs.each do |dir|
      dx = dir[0]
      dy = dir[1]
      x = @position[0] + dx
      y = @position[1] + dy
      possible_place = [x, y]
      #while @board.valid?(@color, possible_place)'
      if @board.in_bounds?(possible_place)
        while @board.in_bounds?(possible_place) && @board[possible_place].nil?
          valid_places << possible_place
          x += dx
          y += dy
          possible_place = [x, y]
        end
        if !@board[possible_place].nil? && @board[possible_place].color != @color
          valid_places << possible_place
        end
      end
    end
    valid_places
  end
end

class Bishop < SlidingPiece
  def dirs
    Piece::DIAGS
  end
  
  def to_s
    @color == :black ? "♝ " : "♗ "
  end
end

class Rook < SlidingPiece
  def dirs
    Piece::HV
  end
  
  def to_s
    @color == :black ? "♜ " : "♖ "
  end
end

class Queen < SlidingPiece
  def dirs
    Piece::DIAGS + Piece::HV
  end
  
  def to_s
    @color == :black ? "♛ " : "♕ "
  end
end

class SteppingPiece < Piece
  def moves
    valid_places = []
    self.dirs.each do |dir|
      dx = dir[0]
      dy = dir[1]
      x = @position[0] + dx
      y = @position[1] + dy
      possible_place = [x,y]
      valid_places << possible_place if @board.valid?(@color, possible_place)
    end
    valid_places
  end
end

class Knight < SteppingPiece
  def dirs
    Piece::LS
  end
  
  def to_s
    @color == :black ? "♞ " : "♘ "
  end
end

class King < SteppingPiece
  def dirs
    Piece::DIAGS + Piece::HV
  end
  
  def to_s
    @color == :black ? "♚ " : "♔ "
  end
end

class Pawn < Piece
  unless const_defined?(:BLACK_DELTAS) && const_defined?(:WHITE_DELTAS)
    BLACK_DELTAS = [[1, 1], [-1, 1]]
    WHITE_DELTAS = [[-1, -1], [1, -1]]
  end
  def initialize(board, position, color)
    super(board, position, color)
    @starting_position = @position
  end
  
  def moves
    valid_places = []
    x = position[0]
    y = position[1]
    
    if @color == :black
      direction = 1
      deltas = BLACK_DELTAS
    else
      direction = -1
      deltas = WHITE_DELTAS
    end
    forward_moves = [[x, y + direction]]
    forward_moves << [x, y + (2 * direction)] if @position == @starting_position
    
    if @board[forward_moves.first].nil?
      valid_places << forward_moves.first
      if @board[forward_moves.last].nil?
        valid_places << forward_moves.last
      end
    end
    
    attack_spaces = deltas.map do |delta|
      dx, dy = delta[0], delta[1]
      [x + dx, y + dy]
    end 
    
    valid_places + attack_spaces.select{ |space| @board.capture_valid?(@color, space) }
  end
  
  def to_s
    @color == :black ? "♟ " : "♙ "
  end
end
