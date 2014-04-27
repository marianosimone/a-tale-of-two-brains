require 'gtk2'
require 'rubygems'
require 'gruff'
require 'game_constants'
require 'yaml'
require 'play_round_info'
require 'tournament_info'
require 'util'
require 'gruff_hacks'
require 'ftools'

class ReporterWindow < Gtk::Window

    def theme_virma
      @colors = [yellow = '#FDD84E', blue = '#6886B4', green = '#72AE6E', red = '#D1695E',
                 purple = '#8A6EAF', orange = '#EFAA43', white = '#FFFFFF',
                 blue = '#BBC9DD', green = '#C0DABE', red = '#ECC0BB',
                 purple = '#CABDDB', orange = '#A96B0F', grey = '#C2C2C2']
    return {
      :colors => @colors,
      :marker_color => 'white',
      :font_color => 'white',
      :background_colors => ['black', '#4a465a']
    }
      
    end

   def initialize
       super("A tale of two brains Report")
       set_icon(IconLocation)
       set_window_position(Gtk::Window::POS_CENTER)
       set_border_width( 10 )
       
       @already_done=false      
       @layout=Gtk::VBox.new
       @box_files = Gtk::HBox.new
       @box_files.set_border_width(10)
       @box_files.pack_start(Gtk::Label.new("Archivos de reportes: "))
       @selected_file = Gtk::ComboBox.new(true)
       available_files.each {|file| @selected_file.append_text(file) } 
       @selected_file.set_active(0)
       @box_files.pack_start(@selected_file)
       
        ok_button = Gtk::Button.new("Cargar Reporte")
        ok_button.signal_connect("clicked"){
           if @already_done
              reset
           end
           make_reports
        }
        @box_files.pack_start(ok_button)
        
        signal_connect("delete_event"){
          Gtk.main_quit
          false
        }
        signal_connect("destroy"){
          Gtk.main_quit
          false
        }
        
        @layout.pack_start(@box_files,false, false, 10)
        add(@layout)  
        show_all
   end
   
     
   def available_files
    files = []
    Dir.glob("#{ReportsLocation}/*") {|file|
      if !File.directory?(file)
         file= File.basename(file,".yaml")
      end
      files << File.basename(file)
    }
    return files
  end
   
   def make_reports
      @already_done = true
      @filename = "#{ReportsLocation}/#{@selected_file.active_text}"
      @nb = Gtk::Notebook.new
      @nb.set_border_width( 10 )      
      @layout.pack_start(@nb)
      
      if File.directory?(@filename)
        info = TournamentInfo.new(@filename)
        make_manybrains_results_report(info)
        make_manybrains_comparison_report(info)
        make_manybrains_wins_defeats_comparison(info)
        make_manybrains_wins_units_hits_comparison(info)
        make_manybrains_rounds_to_win_comparison(info)
        make_manybrains_result(info)
      else
        File.open(@filename, 'r' ) do |file|
          @play_round_info = Marshal.load(file)
        end
        @brain1 = "#{@play_round_info[0].brain}"
        @brain2 = "#{@play_round_info[1].brain}"
        @name1 =  "#{@play_round_info[0].player_name}"
        @name2 =  "#{@play_round_info[1].player_name}"
        @rounds = @play_round_info.length/2  
        make_units_hits_report
        make_actions_report
      end
      maximize
      show_all
   end
   
   def make_units_hits_report
   
   #si todavia no se ha procesado este reporte
   if !File.exist?("#{ReportsLocation}/graficos/units#{@selected_file.active_text}.png")
      units_player1=[]
      units_player2=[]
      points_to_use = 0
       
      if @rounds > 50
         points_able = @rounds - 2 
         points_to_use =  points_able/50      
      end
      count = points_to_use
            
      @play_round_info.each_with_index{|one_round,index|
        units_hit_points=0      
        one_round.combat_group_members.each{|member|
               units_hit_points+=member.hit_points      
        }
      
        if count == points_to_use        
          if index.even?
            units_player1 << units_hit_points
          else
            units_player2 << units_hit_points
            count= 0
          end 
        else
            count += 0.5
        end
     }

      g = Gruff::Line.new('750x450')
           
      g.title = "Vida de Unidades"
      g.data("#{@brain1}-#{@name1}", units_player1)
      g.data("#{@brain2}-#{@name2}", units_player2)
      g.write("#{ReportsLocation}/graficos/units#{@selected_file.active_text}.png")
   end      
      units_box=Gtk::VBox.new
      graphic_player=Gtk::Image.new(Gdk::Pixbuf.new("#{ReportsLocation}/graficos/units#{@selected_file.active_text}.png"))
      units_box.pack_start(graphic_player)
      @nb.append_page(units_box,Gtk::Label.new("Vida de Unidades"))
   
   end
   
   def make_actions_report
      #completo con los tipos de combat_groups
      hash_combat1={}; hash_combat1.default = 0
      hash_combat2={}; hash_combat2.default = 0
      hash_defend1={}; hash_defend1.default = 0
      hash_defend2={}; hash_defend2.default = 0

      hash_attack_type1={}; hash_attack_type1.default = 0
      hash_attack_type2={}; hash_attack_type2.default = 0
      
      hash_actions1={}; hash_actions1.default=0
      hash_actions2={}; hash_actions2.default=0
   
      @play_round_info.each_with_index{|one_round,index|
        action = one_round.action
        if action
          actions_hash, combat_hash, defense_hash, attack_hash = index.even? ?
          [hash_actions1, hash_combat1, hash_defend2, hash_attack_type1] :
          [hash_actions2, hash_combat2, hash_defend1, hash_attack_type2]
          actions_hash["#{action.nice_name}"] += 1
          if action.class == DoAttack
            combat_hash["#{action.attacker.nice_name}"] += 1
            defense_hash["#{action.defender.nice_name}"] += 1
            attack_hash["#{AttackType.name_for(action.attack_type)}"] += 1
          end         
        end
      }
      
   #si todavia no se ha procesado este reporte
   if !File.exist?("#{ReportsLocation}/graficos/actions1#{@selected_file.active_text}.png")  
      g1 = Gruff::Pie.new('350x450')
      
      g1.title="#{@brain1}-#{@name1}"      
      hash_actions1.each{|key,value|
         g1.data(key,value)      
      }
      g1.legend_font_size= 20
      g1.write("#{ReportsLocation}/graficos/actions1#{@selected_file.active_text}.png")
      
      g2 = Gruff::Pie.new('350x450')
      
      g2.title="#{@brain2}-#{@name2}"   
      hash_actions2.each{|key,value|
         g2.data(key,value)      
      }
      g2.legend_font_size= 20
      g2.write("#{ReportsLocation}/graficos/actions2#{@selected_file.active_text}.png")
      
   end
      hgraphic_box=Gtk::HBox.new     
      graphic_player=Gtk::Image.new(Gdk::Pixbuf.new("#{ReportsLocation}/graficos/actions1#{@selected_file.active_text}.png"))
      hgraphic_box.pack_start(graphic_player)
      graphic_player=Gtk::Image.new(Gdk::Pixbuf.new("#{ReportsLocation}/graficos/actions2#{@selected_file.active_text}.png"))
      hgraphic_box.pack_start(graphic_player)
      @nb.append_page(hgraphic_box,Gtk::Label.new("Acciones"))
      add_general_info(hash_combat1,hash_combat2,hash_defend1,hash_defend2,hash_attack_type1,hash_attack_type2)
      
   end
  
  
   def add_general_info(hash_combat1,hash_combat2,hash_defend1,hash_defend2,hash_attack_type1,hash_attack_type2)
      array_combat1=hash_combat1.sort { |a,b| a[1]<=>b[1] }
      array_combat2=hash_combat2.sort { |a,b| a[1]<=>b[1] }
      array_defend1=hash_defend1.sort { |a,b| a[1]<=>b[1] }
      array_defend2=hash_defend2.sort { |a,b| a[1]<=>b[1] }
      array_attack_type1=hash_attack_type1.sort { |a,b| a[1]<=>b[1] }
      array_attack_type2=hash_attack_type2.sort { |a,b| a[1]<=>b[1] }
      
      general_info = Gtk::Table.new(3,5,false)
      winner_info= Gtk::Table.new(2,5,false)
      general_report_box= Gtk::HBox.new
      
      general_label= Gtk::Label.new
      general_label.markup= %Q[<span foreground="blue" size="x-large" style="normal">Informacion General\n-----------------------------</span>]
      general_info.attach(general_label,0,1,1,2, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
           
      color= Gdk::Color.new(0, 0, 65535)
      
      label_rounds= Gtk::Label.new("Rondas jugadas:")
      label_rounds.modify_fg(Gtk::STATE_NORMAL, color)
      general_info.attach(label_rounds,0,1,2,3, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      general_info.attach(Gtk::Label.new("#{@rounds}"),1,2,2,3, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      
      label_activity= Gtk::Label.new("Actividad\n")
      label_activity.modify_fg(Gtk::STATE_NORMAL, color)
      general_info.attach(label_activity,0,1,3,4, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      general_info.attach(Gtk::Label.new("#{@name1}\n#{@brain1}"),1,2,3,4, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      general_info.attach(Gtk::Label.new("#{@name2}\n#{@brain2}"),2,3,3,4, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
            
      label_atack= Gtk::Label.new("Luchador que mas ataco")
      label_atack.modify_fg(Gtk::STATE_NORMAL, color)
      general_info.attach(label_atack,0,1,4,5, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      label1="#{SpritesLocation}/shadow.png"
      label2="#{SpritesLocation}/shadow.png"
      if array_combat1.last[1]!=0
        name1= NicelyNamed::get_class_from_name(array_combat1.last[0]).name.downcase
        label1="#{SpritesLocation}/#{name1}_left.png"
      end
      if array_combat2.last[1]!=0
         name2= NicelyNamed::get_class_from_name(array_combat2.last[0]).name.downcase
         label2="#{SpritesLocation}/#{name2}_right.png"
      end
   
      general_info.attach(Gtk::Image.new( Gdk::Pixbuf.new(label1)),1,2,4,5, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      general_info.attach(Gtk::Image.new( Gdk::Pixbuf.new(label2)),2,3,4,5, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      
      label_defend= Gtk::Label.new("Luchador que mas fue atacado")
      label_defend.modify_fg(Gtk::STATE_NORMAL, color)
      general_info.attach(label_defend,0,1,5,6, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      label1="#{SpritesLocation}/shadow.png"
      label2="#{SpritesLocation}/shadow.png"
      if array_defend1.last[1]!=0
         name1= NicelyNamed::get_class_from_name(array_defend1.last[0]).name.downcase
         label1="#{SpritesLocation}/#{name1}_left.png"
      end
      if array_defend2.last[1]!=0
         name2= NicelyNamed::get_class_from_name(array_defend2.last[0]).name.downcase
         label2="#{SpritesLocation}/#{name2}_right.png"
      end
      general_info.attach(Gtk::Image.new( Gdk::Pixbuf.new(label1)),1,2,5,6, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      general_info.attach(Gtk::Image.new( Gdk::Pixbuf.new(label2)),2,3,5,6, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      
      label_atack_type= Gtk::Label.new("Tipo de ataque mas utilizado")
      label_atack_type.modify_fg(Gtk::STATE_NORMAL, color)
      general_info.attach(label_atack_type,0,1,6,7, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      label1="-"
      label2="-"
      if array_attack_type1.last[1]!=0
         label1="#{array_attack_type1.last[0]}"
      end
      if array_attack_type2.last[1]!=0
         label2="#{array_attack_type2.last[0]}"
      end
      general_info.attach(Gtk::Label.new(label1),1,2,6,7, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      general_info.attach(Gtk::Label.new(label2),2,3,6,7, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      general_info.set_border_width( 10 )
      general_info.row_spacings=10
      
      #Ahora agrego la informacion referente al ganador
      #El ultimo jugador del array es el que pierde --> el anteultimo es el que gana
      winner= @play_round_info[@play_round_info.length - 2]
      winner_label= Gtk::Label.new
      winner_label.markup= %Q[<span foreground="blue" size="x-large" style="normal">Informacion del ganador\n-----------------------------------</span>]
      winner_info.attach(winner_label,0,1,1,2, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
      
      label_winner_fighter= Gtk::Label.new("Luchador")
      label_winner_fighter.modify_fg(Gtk::STATE_NORMAL, color)
      label_winner_tlife= Gtk::Label.new("Vida ")
      label_winner_tlife.modify_fg(Gtk::STATE_NORMAL, color)
      label_winner_members= Gtk::Label.new(" Miembros ")
      label_winner_members.modify_fg(Gtk::STATE_NORMAL, color)
      winner_info.attach(label_winner_fighter,0,1,2,3, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
      winner_info.attach(label_winner_tlife,1,2,2,3, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
      winner_info.attach(label_winner_members,2,3,2,3, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
      units_hit_points = 0
      number_units = 0
      i= 0
      winner.combat_group_members.each_with_index{|member,i|                 
            winner_info.attach(Gtk::Image.new( Gdk::Pixbuf.new(member.file_image_name)),0,1,3 + i,4 + i, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
            winner_info.attach(Gtk::Label.new("#{member.hit_points}"),1,2,3 + i,4 + i, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
            winner_info.attach(Gtk::Label.new("#{member.members}"),2,3,3 + i,4 + i, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
            units_hit_points+=member.hit_points  
            number_units += member.members    
      }   
      
      label_winner_life= Gtk::Label.new("Vida al Finalizar juego: ")
      label_winner_life.modify_fg(Gtk::STATE_NORMAL, color)
      winner_info.attach(label_winner_life,0,1,4 + i,5 + i, Gtk::SHRINK, Gtk::SHRINK, 5, 0)   
      winner_info.attach(Gtk::Label.new("#{units_hit_points}"),1,2,4 + i,5 + i, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
      label_winner_units= Gtk::Label.new("Cantidad de unidades que quedaron: ")
      label_winner_units.modify_fg(Gtk::STATE_NORMAL, color)     
      winner_info.attach(label_winner_units,0,1,5 + i,6 + i, Gtk::SHRINK, Gtk::SHRINK, 5, 0)
      winner_info.attach(Gtk::Label.new("#{number_units}"),1,2,5 + i,6 + i, Gtk::SHRINK, Gtk::SHRINK, 10, 0)
                     
      winner_info.set_border_width( 10 )
      winner_info.row_spacings=10
       
      general_report_box.pack_start(general_info)
      general_report_box.pack_start(Gtk::VSeparator.new)
      general_report_box.pack_start(winner_info) 
      @nb.append_page(general_report_box,Gtk::Label.new("Reporte Detallado"))
  
   end
  
   def make_manybrains_results_report(info)
     #el nombre de la imagen va a ser similar al del directorio
     
     g = Gruff::Bar.new('750x420')
     g.legend_font_size= 16
     g.theme = theme_virma
     g.title = "Partidas Ganadas por Estrategia"

     info.wins_by_brain.each{|brain,value|
       g.data(brain,value)
     }
     g.minimum_value = 0
     g.force_integer_increment = true

     graph_location = "#{ReportsLocation}/graficos/brains_results_#{name}.png" 
     g.write(graph_location)
     graph_image = Gtk::Image.new(Gdk::Pixbuf.new(graph_location))
     @nb.append_page(graph_image,Gtk::Label.new("Ganadas"))
   end

   def make_manybrains_comparison_report(info)
     g = Gruff::SideStackedBar.new('750x420')
     g.legend_font_size= 16
     g.theme = theme_virma
     labels = {}
     info.brains_in_tournament.each_with_index{|brain,index|
       labels[index] = brain
       hsh_defeats = info.defeats_by_brain_vs_brain[brain]
       defeats = []
       info.brains_in_tournament.each{|winner_brain|
         defeats << hsh_defeats[winner_brain]
       }
       g.data(brain,defeats)
     }
     g.labels = labels     
     g.title = "Comparación de Partidas Ganadas"
     g.force_integer_increment = true
     
     graph_location = "#{ReportsLocation}/graficos/brains_comparison_results_#{info.name}.png" 
     g.write(graph_location)
     graph_image = Gtk::Image.new(Gdk::Pixbuf.new(graph_location))

     @nb.append_page(graph_image,Gtk::Label.new("Comparativa de Partidas Ganadas"))
   end

   def make_manybrains_wins_defeats_comparison(info)
     g = Gruff::SideStackedBar.new('750x420')
     g.legend_font_size= 16
     g.theme = theme_virma
     labels = {}
     wins = []
     defeats = []
     info.brains_in_tournament.each_with_index{|brain,index|
       labels[index] = brain
       wins << info.wins_by_brain[brain]
       defeats << info.defeats_by_brain[brain] 
     }
     g.data("Ganadas",wins)
     g.data("Perdidas",defeats)
     g.labels = labels
     g.title = "Partidas Ganadas/Perdidas por Inteligencia"
     g.force_integer_increment = true
     graph_location = "#{ReportsLocation}/graficos/wins_defeats_comparison_results_#{info.name}.png" 
     g.write(graph_location)
     graph_image = Gtk::Image.new(Gdk::Pixbuf.new(graph_location))

     @nb.append_page(graph_image,Gtk::Label.new("Ganadas/Perdidas"))
   end
   
    def make_manybrains_wins_units_hits_comparison(info)
     g = Gruff::Bar.new('750x420')
     g.legend_font_size= 16
     g.theme = theme_virma

       #por cada estrategia me quedo con el total de hits final del ganador
     info.brains_in_tournament.each_with_index{|brain,index|
       g.data(brain,info.wins_units_hits_by_brain[brain]/info.initial_units_hits_by_brain[brain].to_f)
     }
          
     g.title = "Proporcion Vida final por Inteligencia"     
     g.minimum_value = 0
     graph_location = "#{ReportsLocation}/graficos/wins_unitshits_comparison_results_#{info.name}.png" 
     g.write(graph_location)
     graph_image = Gtk::Image.new(Gdk::Pixbuf.new(graph_location))

     @nb.append_page(graph_image,Gtk::Label.new("Vida final"))
   end
   
    def make_manybrains_rounds_to_win_comparison(info)
     g = Gruff::Bar.new('750x420')
     g.legend_font_size= 16
     g.theme = theme_virma

     info.brains_in_tournament.each_with_index{|brain,index|
         g.data(brain,info.rounds_to_win_by_brain[brain]/info.wins_by_brain[brain])
     }
          
     g.title = "Promedio de rondas jugadas hasta ganar"     
     g.minimum_value = 0
     graph_location = "#{ReportsLocation}/graficos/wins_unitshits_comparison_results_#{info.name}.png" 
     g.write(graph_location)
     graph_image = Gtk::Image.new(Gdk::Pixbuf.new(graph_location))

     @nb.append_page(graph_image,Gtk::Label.new("Promedio Rondas"))
   end

   def make_manybrains_result(info)
     box = Gtk::VBox.new
     formula_image = Gtk::Image.new(Gdk::Pixbuf.new(FormulaLocation))
     box.pack_start(formula_image)

     g = Gruff::Bar.new('750x375')
     g.legend_font_size= 16
     g.theme = theme_virma
 
     info.brains_in_tournament.each_with_index{|brain,index|
         g.data(brain,info.result_for(brain))
     }
     g.title = "Resultado de la Función Objetivo"     
     g.minimum_value = 0
     graph_location = "#{ReportsLocation}/graficos/comparison_results_#{info.name}.png"
     g.write(graph_location)
     graph_image = Gtk::Image.new(Gdk::Pixbuf.new(graph_location))
     box.pack_start(graph_image)

     @nb.append_page(box,Gtk::Label.new("Resultado"))
   end

   def reset
       @layout.remove(@nb)    
   end
end
