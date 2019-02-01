require "./constant"
require "./player"

class Human < Player
  def put_stone(game, board, putable_cells)
    cell_list = "" #着手可能場所の一覧
    putable_cells.each do |cell|
      cell_list += "(" + COL_NUM.invert[cell[1]] + ROW_NUM.invert[cell[0]] + ")"
    end
    move = gets.to_s.chomp #手の取得
    if move =~ /[a-h][1-8]/
      cell = move.split("")
      col = COL_NUM[cell[0]]
      row = ROW_NUM[cell[1]]
      cell = [row, col]
      if putable_cells.includes?(cell)
        return cell
      else
        print("そのマスには打つことはできません\n")
        print("打てるマスは#{cell_list}です\n")
        put_stone(game, board, putable_cells)
      end
    else
      print("正しいマスを指定してください\n")
      put_stone(game, board, putable_cells)
    end
  end
end