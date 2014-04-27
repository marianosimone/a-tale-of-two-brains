class CopyEnemyActionBrain < Brain
  include IABrain
  include AntiStatusQuoBrain
  
  set_nice_name("Copia Accion")
  set_description("Intenta copiar la accion realizada por su contrincante")

  def initialize(player)
    super
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
  
  def choose_group
    @active_group = @alternate_brain.choose_group
  end

  def build_action
    selected_action = @last_enemy_action.class
    if selected_action == DoAttack
      attack = find_possible_attacks.random
      return DoAttack.new(@active_group, attack[0], attack[1]) unless attack.nil?
    elsif selected_action == Move
      x, y = find_new_location
      add_round_without_move unless x.nil? #We're avoiding infinite loops when dealing with a similar IA
      return Move.new(@active_group,x,y) unless x.nil?
    end
    return NilAction.new(self)
  end

  def find_new_location
    @alternate_brain.find_new_location
  end
  
end
