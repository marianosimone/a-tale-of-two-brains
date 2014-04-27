class AttackRevengeBrain < Brain
  include IABrain
  include AntiStatusQuoBrain

  set_nice_name("Ataque con Venganza")
  set_description("Intenta contraatacar con el m+as fuerte de los grupos, si no puede se mueve.")

  def initialize(player)
    super
    @last_enemy_action = nil
    self.status_quo_breaker = RandomBrain.new(player)
  end

  def notify_enemy_action(action)
    @last_enemy_action = action
  end

  def choose_group
    if @last_enemy_action.class == DoAttack
       enemy_attacker=@last_enemy_action.attacker 
        options = []
        @combat_groups.each{|group|
          group.available_attacks.each{|attack_type|
            group.target_positions_for(attack_type).each{|target|
              row, col = target[1], target[0]
              victim = matrix.is_in_range?(row, col) ? matrix.element_at(row, col) : matrix.default
              if victim == enemy_attacker
                options << [group, attack_type] unless (victim == matrix.default or @combat_groups.include?(victim))
              end
            }
          }
        }
        
        best_option = options.sort{|option1,option2|
          option1[0].max_strength_for_attack_type(option1[1]) <=> option2[0].max_strength_for_attack_type(option2[1])
        }.last
        if best_option
           @active_group, @attack_type = best_option
        return @active_group
        else
            return nil
        end
    end
  end


  def find_victim             
    if @last_enemy_action.class == DoAttack
       enemy_attacker=@last_enemy_action.attacker
       #busco un atacante q pueda contraatacar con mayor fuerza
       if enemy_attacker.alive?
          return enemy_attacker       
       end       
    end
      return nil
  end
  
  def build_action
    @victim = find_victim
    return DoAttack.new(@active_group, @victim, @attack_type) unless @active_group.nil?
    x, y = find_new_location
    add_round_without_move unless x.nil? #We're avoiding infinite loops when dealing with a similar IA
    return Move.new(@active_group,x,y) unless x.nil?
    return NilAction.new(self)
  end
  
  def find_new_location
    @active_group = @combat_groups.random
    location = find_possible_locations.random
    return location[0], location[1] unless location.nil?
    nil
  end
end
