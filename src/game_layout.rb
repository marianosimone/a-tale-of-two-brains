require 'game_scene'
require 'images_provider'

class GameLayout < Gtk::VBox

  def initialize(main_window,filename, game)
    super()
    @game = game
    @main_window=main_window
    time = Time.new

    layout = Gtk::VBox.new

    menubar = Gtk::MenuBar.new
    menubar.append(menu_item)
    menubar.append(acciones_item)
    layout.pack_start(menubar, false, false, 0)

    @main_window.add_events(Gdk::Event::KEY_PRESS)

    @key_press_signal_id = @main_window.signal_connect("key-press-event") do |w, e|
      if e.keyval == 116 #t
        end_turn
      end
    end

    @game_scene = GameScene.new(filename, game) { |selected| @selected_character_info.update(selected)}
    layout.pack_start(@game_scene, false, false, 0)

    info_layout = Gtk::HBox.new
    @status_bar = PlayersStatusBar.new(game)
    @status_bar.update    
    info_layout.pack_start(@status_bar, true, true, 0)
    info_layout.pack_start(Gtk::VSeparator.new,false,false,5)   
    @selected_character_info = CharacterInfoBox.new
    info_layout.pack_start(@selected_character_info, false, false, 5)
    layout.pack_start(info_layout, false, false, 0)

    pack_start(layout)
    show_all
  end

private
  def menu_item    
    menu_item = Gtk::MenuItem.new("Menu")
    game_menu = Gtk::Menu.new
    menu_item.set_submenu(game_menu)
    item_back = Gtk::MenuItem.new("Volver a empezar")
 
    item_help=Gtk::MenuItem.new("Ayuda")
    item_exit = Gtk::MenuItem.new("Salir del Juego")
    game_menu.append(item_back)
    game_menu.append(item_help)
    game_menu.append(item_exit)

    item_back.signal_connect("activate"){
          @main_window.remove(self)
          @main_window.signal_handler_disconnect(@key_press_signal_id) if @main_window.signal_handler_is_connected?(@key_press_signal_id)
          SoundsPlayer.instance.play_background(MainMenuMusic)
          @main_window.toConfigWin
    }
    item_help.signal_connect("activate"){}
   
    item_exit.signal_connect("activate"){          
          save_info_for_reports
          Gtk.main_quit
     }    
    return menu_item
  end
    
    
  def acciones_item
    acciones_item = Gtk::MenuItem.new("Acciones")
    acciones_menu = Gtk::Menu.new
    acciones_item.set_submenu(acciones_menu)
    item_fin_turno = Gtk::MenuItem.new("Fin de turno")

    acciones_menu.append(item_fin_turno)
    item_fin_turno.signal_connect("activate"){ end_turn }
    return acciones_item
  end

  def end_turn
    taken_action = @game.play_round   
    @status_bar.update(taken_action)
    @game_scene.update_from_action(taken_action)
    @status_bar.update
    if @game.can_continue?
      #end_turn unless !@game.active_player.automatic? #TODO: Sacar en la presentacion, para poder ir viendo paso a paso
    else
      @main_window.signal_handler_disconnect(@key_press_signal_id) if @main_window.signal_handler_is_connected?(@key_press_signal_id)
      @game_scene.end_of_game
    end
  end
end

class CharacterInfoBox < Gtk::VBox
  def initialize
    super()
    #No uso el ImagesProvider porque necesito ir modificando el pixbuf y no la image
    @pixbuf = Gdk::Pixbuf.new("#{SpritesLocation}/shadow.png")
    @image = Gtk::Image.new(@pixbuf)
                                #"Miembros: 10"
    @name_label = Gtk::Label.new("Informacion ")
    @alive_memebers = Gtk::Label.new("")
    pack_start(@name_label,false, false, 0)
    pack_start(@alive_memebers, false, false, 0)
    pack_start(@image, false, false, 0)
    show_all
  end

  def update(character)
    return unless (not character.nil?) #TODO: Podriamos hacer que si no es un character, mostremos info de terreno?
    remove(@image)
    @pixbuf = Gdk::Pixbuf.new(character.file_image_name)
    @image = Gtk::Image.new(@pixbuf)
    @name_label.text = character.nice_name
    @alive_memebers.text = "Miembros: #{character.number_of_members}"
    pack_start(@image, false, false, 0)
    show_all
  end
end


class AttackWindow < Gtk::Window
  def initialize(player, attacker,x,y)
    super("Ataque")
    set_icon(IconLocation)
    set_window_position(Gtk::Window::POS_CENTER)
    self.modal = true
    self.skip_taskbar_hint = true
    self.resizable = false
    @ppal_box = Gtk::VBox.new
    @ppal_box.pack_start(Gtk::Label.new("\n Seleccione el tipo de ataque para: #{attacker.nice_name} \n"),false,false,0)
    
    @central_box=Gtk::HBox.new
    @radio_box=Gtk::VBox.new
    @radio_box.set_border_width(10)
    
    @buttons_box=Gtk::HBox.new    
    @button_ok = Gtk::Button.new("Aceptar")
    @button_cancel = Gtk::Button.new("Cancelar")
    update_attacks(player, attacker,x,y)
  end

  def active_attack_type
     @buttons.each { |b| 
      b.each { |label|
        return AttackType.value_for(label.text) if b.active? 
      } 
    }
  end

  def update_attacks(player, attacker,x,y)
    @buttons=[]
    attacker.possible_attacks_to(x,y).each_with_index{|attack,index|       
       if index == 0      
         radioButton = Gtk::RadioButton.new(AttackType.name_for(attack))
         radioButton.set_active(true) 
       else 
         radioButton = Gtk::RadioButton.new(@buttons[index-1],AttackType.name_for(attack))
                 
       end
         @buttons << radioButton
         #agrego el resto de los radioButtons
         @radio_box.pack_start(radioButton,false,false,0)
    }
    @central_box.pack_start(@radio_box,false,false,0)
    @central_box.pack_start(Gtk::Image.new(Gdk::Pixbuf.new(attacker.file_image_name)))

    @buttons_box.pack_start(@button_ok)
    @buttons_box.pack_start(@button_cancel)

    @button_ok.signal_connect("clicked"){
        player.notify_selection(active_attack_type)
        hide 
    }
    @button_cancel.signal_connect("clicked"){      
          hide 
    }
    @ppal_box.pack_start(@central_box,false,false,0)
    @ppal_box.pack_start(@buttons_box,false,false,0)
    add(@ppal_box)
  end
end

class PlayersStatusBar < Gtk::Table
  def initialize(game)
    super(game.players.size, 5, false)
    @game = game
    @players_units_labels = []
    @active_player_labels = []
    @last_action_labels = []
    @game.players.each_with_index{|player, i|
      row_begin, row_end = i+1, i+2
      attach(ImagesProvider.get(:flag, player.color), 0, 1, row_begin, row_end, Gtk::SHRINK, Gtk::SHRINK, 5, 5)
      attach(Gtk::Label.new(player.name), 1, 2, row_begin, row_end, Gtk::SHRINK, Gtk::SHRINK, 5, 5)
      attach(ImagesProvider.get(:units_icon), 3, 4, row_begin, row_end, Gtk::SHRINK, Gtk::SHRINK, 5, 5)
      label_units = Gtk::Label.new(player.number_of_units.to_s)
      @players_units_labels << label_units
      attach(label_units, 4, 5, row_begin, row_end, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
      label_active_player = Gtk::Label.new("")
      @active_player_labels << label_active_player
      attach(label_active_player, 5, 6, row_begin, row_end, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
      last_action_label = Gtk::Label.new("")
      @last_action_labels << last_action_label
      attach(last_action_label, 6, 7, row_begin, row_end, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
    }
  end

  def update(taken_action = nil)
    @players_units_labels.each_with_index{|label,index|
      label.text = "#{@game.players[index].number_of_units}"
    }
    @active_player_labels.each_with_index{|label,index|
      label.text = @game.players[index] == @game.active_player ? '[X]' : ''
    }
    if taken_action
      @last_action_labels.each_with_index{|label,index|
        label.set_text("#{taken_action.description}") unless @game.players[index] == @game.active_player
      } 
    end
  end
end
