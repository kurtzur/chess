# encoding: UTF-8 
require "colorize"
load './pieces.rb'
class Board
  attr_accessor :rows
  def initialize(populate = true)
    @rows = Array.new(8) { Array.new(8) {nil} }
    
    players_hash = {black: 0, white: 7}
    if populate
      players_hash.each do |color, y|
        self[[0,y]] = Rook.new(self, [0,y], color)
        self[[1,y]] = Knight.new(self, [1,y], color)
        self[[2,y]] = Bishop.new(self, [2,y], color)
        self[[3,y]] = Queen.new(self, [3,y], color)
        self[[4,y]] = King.new(self, [4,y], color)
        self[[5,y]] = Bishop.new(self, [5,y], color)
        self[[6,y]] = Knight.new(self, [6,y], color)
        self[[7,y]] = Rook.new(self, [7,y], color)
      end
    
      (0..7).each do |x|
        self[[x,1]] = Pawn.new(self, [x,1], :black)
        self[[x,6]] = Pawn.new(self, [x,6], :white) 
      end
    end
    
  end 
  
  def display
    color = :light_red
    @rows.each_with_index do |row, y|
      print "#{8 - y} "
      row.each_index do |x|
        current_piece = self[[x, y]]
        str = (current_piece.nil? ? "  " : current_piece.to_s)
        print str.colorize(:background => color)
        color = toggle_color(color)
      end
      color = toggle_color(color)
      puts " "
    end
    puts "  A B C D E F G H" 
    nil   
  end
  
  def toggle_color(color)
    color == :light_red ? :default : :light_red
  end
  
  def dup
    duplicate = Board.new(false)
    @rows.each_with_index do |row, y|
      row.each_index do |x|
        current_item = self[[x,y]]
        next if current_item.nil?
        current_dup = current_item.class.new(duplicate, [x,y], current_item.color)
        duplicate[[x,y]] = current_dup
      end
    end
    duplicate
  end

  def move(start, destination, current_color)
    columns = ["A", "B", "C", "D", "E", "F", "G", "H"]
    start_indices = [columns.index(start[0]), 8 - start[1]]
    dest_indices = [columns.index(destination[0]), 8 - destination[1]]
    piece = self[start_indices]
    raise MoveError.new "Enter a non-empty index!" if piece.nil?
    raise MoveError.new "Move your own piece!" unless piece.color == current_color
    raise MoveError.new "Invalid move!" unless piece.valid_moves.include?(dest_indices)
    move!(start_indices, dest_indices)
  end
  
  def move!(start, destination)
    piece = self[start]
    self[start] = nil
    self[destination] = piece
    piece.position = destination
  end
  
  def [](position)
    return nil unless in_bounds?(position)
    @rows[position[1]][position[0]]
  end
  
  def []=(position, value)
    @rows[position[1]][position[0]] = value
  end
  
  def valid?(color, position)
    if in_bounds?(position)
      return true if (self[position].nil? || self[position].color != color)
    end
    false
  end
 
  def capture_valid?(color, position)
    if in_bounds?(position)
      unless self[position].nil?
        return true if self[position].color != color
      end
    end
    false
  end
  
  def in_bounds?(position)
    (position[0] >= 0 && position[0] <= 7) && (position[1] >= 0 && position[1] <= 7)
  end
  
  def get_color(color)
    @rows.flatten.compact.select{ |piece| piece.color == color }
  end
  def get_king(color)
    get_color(color).find{ |piece| piece.is_a? King }
  end
  
  def in_check?(color)
    enemy_color = (color == :white ? :black : :white)
    
    opp_pieces = get_color(enemy_color)
    king_pos = get_king(color).position
    opp_pieces.any?{ |piece| piece.moves.include?(king_pos) }
  end
  
  def check_mate?(color)
    pieces = get_color(color) 
    if in_check?(color) 
      return true if pieces.all? { |piece| piece.valid_moves == []}
    end
    false
  end
end

class Game
  def initialize(board)
    @board = board
  end
  
  def play_game
    @board.display
    current_color = :white
    until game_over?
      begin
        puts
        puts "#{current_color.to_s.capitalize}:"
        puts
        puts "Please input the index of the piece you want to move."
        input = gets
        piece = parse(input)
        puts
        puts "Please input the destination index:"
        input = gets
        destination = parse(input)
        @board.move(piece, destination, current_color)
        #@board[piece].valid_moves
      rescue MoveError => e
        puts
        puts "Error: #{e.message} Please try again."
        puts "-" * 60
        retry
      end
      puts "\e[H\e[2J" # clear terminal window
      @board.display
      current_color = get_opp_color(current_color)
    end
    current_color = get_opp_color(current_color)
    puts
    puts "Checkmate, #{current_color.to_s} wins!"
  end
  
  def parse(input)
    chars = input.chomp.split("")
    chars[0].to_s.upcase!
    chars[1] = chars[1].to_i
    chars
  end
  
  def get_opp_color(color)
    color == :white ? :black : :white
  end
  
  def game_over?
    @board.check_mate?(:black) || @board.check_mate?(:white)
  end
  
end

class MoveError < StandardError
end
