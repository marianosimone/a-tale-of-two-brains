class Gruff::SideBar < Gruff::Base
protected

  # Instead of base class version, draws vertical background lines and label
  def draw_line_markers
    return if @hide_line_markers

    @d = @d.stroke_antialias false

    # Draw horizontal line markers and annotate with numbers
    @d = @d.stroke(@marker_color)
    @d = @d.stroke_width 1
    number_of_lines = 5

    # TODO Round maximum marker value to a round number like 100, 0.1, 0.5, etc.
    increment = @y_axis_increment || significant(@maximum_value.to_f / number_of_lines) #MARIANO'S PATCH!!

    (0..number_of_lines).each do |index|

      line_diff    = (@graph_right - @graph_left) / number_of_lines
      x            = @graph_right - (line_diff * index) - 1
      @d           = @d.line(x, @graph_bottom, x, @graph_top)
      diff         = index - number_of_lines
      marker_label = diff.abs * increment

      unless @hide_line_numbers
        @d.fill      = @font_color
        @d.font      = @font if @font
        @d.stroke    = 'transparent'
        @d.pointsize = scale_fontsize(@marker_font_size)
        @d.gravity   = CenterGravity
        # TODO Center text over line
        @d           = @d.annotate_scaled( @base_image,
                          0, 0, # Width of box to draw text in
                          x, @graph_bottom + (LABEL_MARGIN * 2.0), # Coordinates of text
                          marker_label.to_s, @scale)
      end # unless
      @d = @d.stroke_antialias true
    end
  end

  ##
  # Draw on the Y axis instead of the X

  def draw_label(y_offset, index)

    if !@labels[index].nil? && @labels_seen[index].nil?
      @d.fill             = @font_color
      @d.font             = @font if @font
      @d.stroke           = 'transparent'
      @d.font_weight      = NormalWeight
      @d.pointsize        = scale_fontsize(@marker_font_size)
      @d.gravity          = EastGravity
      @d                  = @d.annotate_scaled(@base_image,
                              1, 1,
                              -@graph_left + LABEL_MARGIN * 2.0, y_offset,
                              @labels[index], @scale)
      @labels_seen[index] = 1
    end
  end
end

module Gruff
class Base
attr_accessor :force_integer_increment
    def significant(inc) # :nodoc:
      return 1 if inc == 0 # Keep from going into infinite loop
      factor = 1.0
      while (inc < 10)
        inc *= 10
        factor /= 10
      end

      while (inc > 100)
        inc /= 10
        factor *= 10
      end

      res = inc.floor * factor
      res = res.floor if @force_integer_increment #MARIANO'S PATCH!
      if (res.to_i.to_f == res)
        res.to_i
      else
        res
      end
    end
end
end
