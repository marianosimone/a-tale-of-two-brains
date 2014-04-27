class CopyEnemyActionAndMembersBrain < Brain
  include IABrain
  include AntiStatusQuoBrain
  
  set_nice_name("Copia Accion y miembros")
  set_description("Intenta copiar la accion realizada por su contrincante como asi tambien los miembros que intervinieron en dicha accion")

  def initialize(player)
    super
    @continue_moving= 0
    @alternate_brain = RandomBrain.new(player)
    self.status_quo_breaker = @alternate_brain
    @last_enemy_action = nil
  end

  def notify_enemy_action(action)
    @last_enemy_action = action
  end
  
  def matrix=(matrix)
    @matrix = matrix
    @alternate_brain.matrix = matrix
  end
  
  def find_similar_enemy_group(enemy_group_name)
    @combat_groups.each_with_index{ |group,index|
         if group.alive?
            if group.nice_name == enemy_group_name
               return @combat_groups[index]
            end
         end
    }
    return nil
  end
   
  
  def choose_group  
    @alternate_brain.choose_group
    #el grupo a elegir depende de la accion del oponente
    if @last_enemy_action.class.name == "Move"
       enemy_group=@last_enemy_action.combat_group
       my_group= find_similar_enemy_group(enemy_group.nice_name)       
       @active_group = my_group unless my_group.nil?
       
    elsif @last_enemy_action.class.name == "DoAttack"
       enemy_group=@last_enemy_action.attacker
       my_group= find_similar_enemy_group(enemy_group.nice_name)       
       @active_group = my_group unless my_group.nil?
    end
    
  end

  def build_action
    if @continue_moving > 10
       selected_action = "DoAttack"
       #obligo a atacar con uno random
       @active_group = @combat_groups.random
    else
      selected_action = @last_enemy_action.class.name
    end
    if selected_action == "Move"
      x, y = find_new_location unless @active_group.nil?
      @continue_moving+=1 unless x.nil?
      return Move.new(@active_group,x,y) unless x.nil?
    elsif selected_action == "DoAttack"
      attack = find_possible_attacks.random unless @active_group.nil?
      @continue_moving= 0 unless attack.nil? #dejo de moverse
      return DoAttack.new(@active_group, attack[0], attack[1]) unless attack.nil?
    end
    return NilAction.new(self)
  end

  def find_new_location
    location = find_possible_locations.random
    return location[0], location[1] unless location.nil?
    nil

  end
  
 
  
  
end
