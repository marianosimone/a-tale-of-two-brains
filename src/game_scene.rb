require 'gtk2'
require 'domain'
require 'control'
require 'matrix_data_structure'
require 'sounds_player'

class GameScene < Gtk::DrawingArea
  def initialize(background_filename, game, &info_about_cell_callback)
    super()
    @matrix = game.matrix
    @info_about_cell_callback = info_about_cell_callback
    @game = game
    add_events(Gdk::Event::BUTTON_PRESS_MASK)
    @background = Gdk::Pixbuf.new(background_filename)
    #seteo el tamaño de la imagen al layout
    set_size_request(@background.width, @background.height)
    @is_selected_char = false
    @pos_x = 0
    @pos_y = 0
    show_all
       
    signal_connect("expose_event"){ draw_scene }

    signal_connect("button-press-event") {|owner, event|
      draw_scene
      row, col = image_to_matrix_coord(event.y, event.x)
      selected_content = @matrix.element_at(row,col)
      @info_about_cell_callback.call(selected_content) # Callabck to update the CharInfoBox
      @game.active_player.controller.notify(selected_content, row, col) {
        |player, attacker|
        if (player)
          win=AttackWindow.new(player, attacker,col,row)
          win.set_modal(true)
          win.show_all
        else
          mark_possible_actions(selected_content)
        end
      } # Notification to the controller so it can decide what to do
    }
    SoundsPlayer.instance.play_background(BackgroundMusic)
  end

  def update_from_action(taken_action)
    if taken_action.class == Move
      draw_cell(taken_action.previous_y, taken_action.previous_x)
      draw_cell(taken_action.y, taken_action.x)
    elsif taken_action.class == DoAttack
      defender = taken_action.defender
      @info_about_cell_callback.call(defender)
      if not defender.alive?
        draw_cell(defender.y, defender.x)
      end
    end
  end

  def end_of_game
    imagen = Gdk::Pixbuf.new(GameOverLocation)
    window().draw_pixbuf(style.black_gc, imagen, 0, 0, 0, 0, imagen.width, imagen.height,Gdk::RGB::DITHER_NONE, 0, 0)
    context = window().create_cairo_context
    context.set_font_size(16)
    context.select_font_face('Old London', 'normal', 'bold')
    context.set_font_size(45)
    context.move_to(300,220)
    context.show_text(@game.pasive_player.name)
    context.stroke
  end

private
  # Returns row, col
  def image_to_matrix_coord(y, x)
   return ((y*@matrix.n_rows)/@background.height).floor, ((x*@matrix.n_cols)/@background.width).floor
  end

  # Rerturns y, x
  def matrix_to_image_coord(row, col)
    return row*(@background.height/@matrix.n_rows), col*(@background.width/@matrix.n_cols)
  end

  def draw_cell(row, col)
    y , x = matrix_to_image_coord(row, col)
    window().draw_pixbuf(style.black_gc, @background, x, y, x, y, cell_width, cell_height,Gdk::RGB::DITHER_NONE, 0, 0) #First we draw the background
    element = @matrix.element_at(row, col)
    if (not element.nil?) # And then, maybe, a character
      sprite = Gdk::Pixbuf.new(element.file_image_name)
      window().draw_pixbuf(style.black_gc, sprite, 0, 0, x, y, -1, -1, Gdk::RGB::DITHER_NONE, 0, 0)
    end
  end
  
  #en base al personaje seleccionado marco posibles movimientos/ataques
  def mark_possible_actions(selected_content)
  #posibles movimientos
  selected_content.positions_to_move.each{|x,y|
      mark_cell(y,x,[0.8,0.8,0.8])  
  } 
  end
  
  def mark_cell(row,col,color)
    y , x = matrix_to_image_coord(row, col)
    context = window.create_cairo_context
    context.set_source_rgb(color[0],color[1],color[2]) #negro
    context.move_to(x,y)
    context.rel_line_to(0,(@background.height/@matrix.n_rows))#dibujo el lado izquierdo
    context.rel_line_to((@background.width/@matrix.n_cols),0)#dibujo el lado inferior
    context.rel_line_to(0,1-1*(@background.height/@matrix.n_rows))#dibujo el lado derecho
    context.close_path #cierro el poligono
    context.set_line_width(1.5) #ancho de linea
	context.stroke     
  
  end

  def cell_width
    @background.width/@matrix.n_cols
  end

  def cell_height
    @background.height/@matrix.n_rows
  end

  def draw_scene
    @matrix.rows.each_with_index{|row,y|
      row.each_with_index{|element,x|
        draw_cell(y, x)
      }
    }
  end
end
