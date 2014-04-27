class RandomBrain < Brain
  include IABrain
  set_nice_name("Random")
  set_description("Un controlador simple. Sólo usa aleatoriedad uniforme para tomar decisiones")

  def choose_group
    @active_group = @combat_groups.random
  end

  def build_action
    selected_action = [Move, DoAttack, NilAction].random
    if selected_action == Move
      x, y = find_new_location
      return Move.new(@active_group,x,y) unless x.nil?
    elsif selected_action == DoAttack
      attack = find_possible_attacks.random
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
