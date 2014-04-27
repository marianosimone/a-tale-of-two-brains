require 'game_layout'
require 'control'
require 'player'
require 'game'

class ConfigPanel < Gtk::VBox
  def initialize(mainwindow)
    super 
    set_border_width(5)
    @main_window = mainwindow
    @players_brain_info=[]
    @layout_box = Gtk::VBox.new
    @layout_box.set_border_width(10)

    @layout_players = Gtk::Table.new(3,3,false)
    @layout_players.attach_defaults(Gtk::Label.new("Tipo jugador:"), 0,1,0,1)
    @layout_players.attach_defaults(Gtk::Label.new("Nombre jugador:"),0,1, 1,2)
    @layout_players.attach_defaults(Gtk::Label.new("Color jugador:"),0,1, 2,3)

    #Cosa loca: Creamos dinámicamente todos los inputs. Esto nos permitiría hace juegos de más de 2 jugadores y agregar o quitar colores y "cerebros" tocando sólo las constantes
    @player_creation_inputs = []
    NumberOfPlayers.times do |i|
      @player_creation_inputs[i] = []

      @player_creation_inputs[i][0] = Gtk::ComboBox.new(true)
      
      Brain.subclasses.each {|brain| @player_creation_inputs[i][0].append_text(brain.nice_name) } 
      @player_creation_inputs[i][0].set_active(i)
      @player_creation_inputs[i][0].signal_connect("changed"){
          @players_brain_info[i].text = "#{NicelyNamed::get_class_from_name(@player_creation_inputs[i][0].active_text).class_description}"
      }
      
      @player_creation_inputs[i][1] = Gtk::Entry.new

      @player_creation_inputs[i][2] = Gtk::ComboBox.new(true)
      AvailableColors.each {|color| @player_creation_inputs[i][2].append_text(color) } 
      @player_creation_inputs[i][2].set_active(i)
    end
       
    
    #Ahora agarramos cada uno de esos, y los metemos en la tabla
    @player_creation_inputs.each_with_index { |player_inputs, i|
      @layout_players.attach_defaults(player_inputs[0],i+1,i+2,0,1)
      @layout_players.attach_defaults(player_inputs[1],i+1,i+2,1,2)
      @layout_players.attach_defaults(player_inputs[2],i+1,i+2,2,3)
      label_brain_info = Gtk::Label.new("#{NicelyNamed::get_class_from_name(@player_creation_inputs[i][0].active_text).class_description}")
      label_brain_info.wrap = true
      label_brain_info.width_chars = 40
      @players_brain_info << label_brain_info
      @layout_players.attach_defaults(label_brain_info,i+1,i+2,3,4)
    }

    @layout_box.pack_start(@layout_players, false, false, 0)

    @box_map = Gtk::HBox.new
    @box_map.set_border_width(10)
    @box_map.pack_start(Gtk::Label.new("Mapa para jugar: "))
    @selected_map = Gtk::ComboBox.new(true)
    available_maps.each {|map| @selected_map.append_text(map) } 
    @selected_map.set_active(0)
    @box_map.pack_start(@selected_map)
    @layout_box.pack_start(@box_map,false, false, 10)  
 
    @box_buttons = Gtk::HBox.new    
    @box_buttons.pack_start(start_game_button,false, false, 5)
    @box_buttons.pack_start(cancel_game_button,false, false, 5)
    @layout_box.pack_start(@box_buttons, false, false, 10)

    pack_start(@layout_box, false, false, 0)
   end

private

  def start_game_button
    unless @start_game_button
      @start_game_button = Gtk::Button.new("Comenzar")

      @start_game_button.signal_connect("clicked") {
        if ready_to_start?
          @main_window.remove_widget
           players = []
          NumberOfPlayers.times do |i|
            controller = @player_creation_inputs[i][0].active_text
            name = "#{@player_creation_inputs[i][1].text}"
            color = @player_creation_inputs[i][2].active_text
            player = Player.new(name, color,NicelyNamed::get_class_from_name(controller))
            players << player
          end
          game_scene = GameLayout.new(@main_window,"#{MapsLocation}/#{@selected_map.active_text}.png", CombatGame.new(players))
          @main_window.add(game_scene)
        else
          dialog = Gtk::MessageDialog.new(@main_window, 
                                Gtk::Dialog::DESTROY_WITH_PARENT,
                                Gtk::MessageDialog::ERROR,
                                Gtk::MessageDialog::BUTTONS_CLOSE,
                                "Debe completar los nombres de los jugadores")
          dialog.run
          dialog.destroy
       end
      }
    end
    @start_game_button
  end

  def cancel_game_button
    cancel_game_button = Gtk::Button.new("Cancelar")
    cancel_game_button.signal_connect("clicked") {
      @main_window.backToInitWin()
    }
    return cancel_game_button
  end

  def available_maps
    maps = []
    Dir.glob("#{MapsLocation}/*.png") {|file|
      maps << File.basename(file, ".png")
    }
    return maps
  end

  def all_names_filled?
return true
    NumberOfPlayers.times do |i|
      if @player_creation_inputs[i][1].text.empty?
        return false
      end
    end
  end

  def ready_to_start? 
    all_names_filled?
  end
end
