require "./constant"
require "./board"
require "./human"
require "./com"


class Game
  @turn = 0
  @record = {} of Int32 => Tuple(Array(Int32), Com | Human, Array(Array(Int32)))
  @board = Board.new

  def initialize(order, lv : Int32)
    case order
    when FIRST
      @first = Human.new(BLACK)
      @second = Com.new(WHITE, lv)
    when SECOND
      @first = Com.new(BLACK, lv)
      @second = Human.new(WHITE)
    else
      @first = Human.new(BLACK)
      @second = Human.new(WHITE)
    end
    @player = @first #黒石からスタート
    start()
  end

  def initialize()
    @first = Human.new(BLACK)
    @second = Human.new(WHITE)
    @player = @first #黒石からスタート
    start()
  end

  def initialize(lv : Array(Int32))
    @first = Com.new(BLACK, lv[0])
    @second = Com.new(WHITE, lv[1])
    @player = @first #黒石からスタート
    start()
  end

  def start()
    @board.show_board
    phase
  end

  getter :player
  getter :turn
  getter :record

  #手番の流れ
  def phase
    case status
    when FINISH
      end_game
    when PASS
      print("#{@turn+1}手目\n")
      print("#{COLOR[-@player.color]}の手番です\n")
      print("パスしました\n")
      @board.show_board
      phase
    when MOVE
      putable_cells = @board.get_putable_cells(@player.color)
      print("#{COLOR[@player.color]}の手番です\n")
      print("#{@turn+1}手目:")
      move = @player.put_stone(self, @board, putable_cells)
      reverse(move.as(Array(Int32)))
      @board.show_board
      phase
    end
  end

  #状態判定
  def status
    if @board.get_putable_cells(@player.color).size == 0
      change_phase
      if @board.get_putable_cells(@player.color).size == 0
        return FINISH
      else
        return PASS
      end
    else
      return MOVE
    end
  end

  def reverse(move : Array(Int32))
    row = move[0].to_i
    col = move[1].to_i
    change = @board.reverse(row, col, @player.color)
    @record[@turn] = {move, @player, change}
    @turn += 1
    change_phase
  end
  
  def undo
    if @turn != 0 #1ターン目でない時
      @turn -= 1
      cell = @record[@turn][0]
      @player = @record[@turn][1]
      change = @record[@turn][2]
      @board.undo(cell, @player.color, change)
    end
  end

  def change_phase
    if @player == @first
      @player = @second
    else
      @player = @first
    end
  end

  def end_game
    count = @board.count
    black = count[0]
    white = count[1]
    if black > white
      print("\n黒:#{black} 対 白:#{white} で黒の勝ち\n\n")
      return BLACK
    elsif white > black
      print("\n黒:#{black} 対 白:#{white} で白の勝ち\n\n")
      return WHITE
    else
      print("\n黒:#{black} 対 白:#{white} で引き分け\n\n")
      return EMPTY
    end
  end
end