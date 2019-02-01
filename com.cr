require "./constant"
require "./player"

class Com < Player
  def initialize(color : Int32, lv : Int32)
    super(color) #親クラスのメソッド呼び出し
    @lv = lv
  end

  def put_stone(game, board, putable_cells)
    cell = [0, 0]
    case @lv
    when 1
      cell = lv1(game, board)
    when 2
      cell = lv2(game, board)
    when 3
      cell = lv3(game, board)
    when 4
      cell = lv4(game, board)
    when 5
      cell = lv5(game, board)
    end
    row = ROW_NUM.invert[cell[0]]
    col = COL_NUM.invert[cell[1]]
    move = col + row
    print(game.turn+1, "手目: ", move)
    return cell
  end

  def lv1(game, board)
    putable_cells = board.get_putable_cells(game.player.color)
    print(cell_list(putable_cells), "\n")
    put_cell = putable_cells.sample #空きますからランダムに1つ取得
    return put_cell
  end

  #BOARD_SCOREのもっとも大きくなるマスに石を打つ
  def lv2(game, board)
    cell_score = {-99999999 => [[0,0]]}
    putable_cells = board.get_putable_cells(game.player.color)
    print(cell_list(putable_cells), "\n")
    putable_cells.each do |cell|
      print(COL_NUM.invert[cell[1]] + ROW_NUM.invert[cell[0]], ": ", BOARD_SCORE[cell[0]][cell[1]], "\n")
      score = BOARD_SCORE[cell[0]][cell[1]]
      if score > cell_score.keys.last
        cell_score[score] = [cell]
      elsif score == cell_score.keys.last
        cell_score[score].push(cell)
      end
    end
    put_cell = select_com_move(cell_score)
    return put_cell
  end

  def lv3(game, board)
    cell_score = {-99999999 => [[0,0]]}
    putable_cells = board.get_putable_cells(game.player.color)
    print(cell_list(putable_cells), "\n")
    putable_cells.each do |cell|
      game.reverse(cell)
      score = 0
      board.board.each_with_index do |row, i|
        row.each_with_index do |col, j|
          if col == @color
            score += BOARD_SCORE[i][j]
          end
        end
      end
      print(COL_NUM.invert[cell[1]] + ROW_NUM.invert[cell[0]], ": ", score, "\n")
      game.undo
      if score > cell_score.keys.last
        cell_score[score] = [cell]
      elsif score == cell_score.keys.last
        cell_score[score].push(cell)
      end
    end
    put_cell = select_com_move(cell_score)
    return put_cell
  end

  def lv4(game, board)
    cell_score = {-99999999 => [[0,0]]}
    depth = 5 #先読みの深さ
    putable_cells = board.get_putable_cells(game.player.color)
    print(cell_list(putable_cells), "\n")
    putable_cells.each do |cell|
      game.reverse(cell)
      if depth == 0 || game.status == FINISH
        score = board_score(game, board)
      else
        score = search(game, board, depth-1, BOARD)
      end
      print(COL_NUM.invert[cell[1]] + ROW_NUM.invert[cell[0]], ": ", score, "\n")
      game.undo
      if score.to_s.to_i > cell_score.keys.last
        cell_score[score.to_s.to_i] = [cell]
      elsif score == cell_score.keys.last
        cell_score[score.to_s.to_i].push(cell)
      end
    end
    put_cell = select_com_move(cell_score)
    return put_cell
  end

  def lv5(game, board)
    cell_score = {-99999999 => [[0,0]]}
    depth = 5 #先読みの深さ
    putable_cells = board.get_putable_cells(game.player.color)
    print(cell_list(putable_cells), "\n")
    putable_cells.each do |cell|
      game.reverse(cell)
      if depth == 0 || game.status == FINISH
        score = perfect_score(game, board)
      else
        if game.turn > 47
          score = search(game, board, 99, PERFECT)
        else
          score = search(game, board, depth-1, BOARD)
        end
      end
      print(COL_NUM.invert[cell[1]] + ROW_NUM.invert[cell[0]], ": ", score, "\n")
      game.undo
      if score.to_s.to_i > cell_score.keys.last
        cell_score[score.to_s.to_i] = [cell]
      elsif score == cell_score.keys.last
        cell_score[score.to_s.to_i].push(cell)
      end
    end
    put_cell = select_com_move(cell_score)
    return put_cell
  end

  def search(game, board, depth, search_type)
    minmax = 9999
    putable_cells = board.get_putable_cells(game.player.color)
    putable_cells.each do |cell|
      game.reverse(cell)
      if depth == 0 || game.status == FINISH
        case search_type
        when BOARD
          score = board_score(game, board)
        when PERFECT
          score = perfect_score(game, board)
        end
      else
        score = search(game, board, depth-1, search_type)
      end
      game.undo
      #スコアの選択(αβ法)
      if minmax == 9999
        minmax = score
      elsif game.player.color == @color
        if score.to_s.to_i > minmax.to_s.to_i
          minmax = score
        end
      else
        if score.to_s.to_i < minmax.to_s.to_i
          minmax = score
        end
      end
    end
    return minmax
  end

  def board_score(game, board)
    score = 0
    #スコアの算出
    board.board.each_with_index do |row, i|
      row.each_with_index do |col, j|
        if col == @color
          score += BOARD_SCORE[i][j]
        end
      end
    end
    return score
  end

  def perfect_score(game, board)
    #スコアの算出
    result = board.count
    score = @color * (result[0] - result[1]) #石差
    return score
  end

  def cell_list(putable_cells)
    cell_list = "" #着手可能場所の一覧
    putable_cells.each do |cell|
      cell_list += "(" + COL_NUM.invert[cell[1]] + ROW_NUM.invert[cell[0]] + ")"
    end
    return cell_list
  end

  def select_com_move(cell_score)
    score = cell_score.keys.last
    cell = cell_score[score]
    cell = cell.sample
    return cell
  end
end
