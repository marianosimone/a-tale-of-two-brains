class MatrixDataStructure
  attr_reader :default
  def initialize(rows, cols, default = nil)
    @default = default
    @matrix = []
    rows.times do
      row = []
      cols.times do
        row << @default
      end
      @matrix << row
    end
  end

  def rows
    @matrix
  end

  def set_at(row, col, element)
    elements << element unless element == @default
    if (element_at(row,col) != default)
      elements.delete(element_at(row,col))
    end
    @matrix[row][col] = element
  end

  def elements
    @elements ||= []
  end

  def element_at(row, col)
    return @matrix[row][col]
  end

  def move(element, to_row, to_col)
    from_row, from_col = position_for(element)
    @matrix[from_row][from_col] = @default
    @matrix[to_row][to_col] = element
  end

  def position_for(element)
    @matrix.each_with_index {|row, row_number|
      if row.include?(element)
        return row_number, row.index(element)
      end
    }
    raise "#{element} is not in the Matrix"
  end

  def n_rows
    @matrix.size
  end

  def n_cols
    @matrix.first.size
  end

  def is_in_range?(row,col)
    return (row >= 0 and row < n_rows and col >= 0 and col < n_cols)
  end

  def has_way_out?(row, col)
    (row-1..row+1).each{|new_row|

      (col-1..col+1).each{ |new_col|
        if (is_in_range?(new_row,new_col) and element_at(new_row,new_col) == default)
          return true
        end
      }
    }
    return false
  end
end
