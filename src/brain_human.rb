require 'brain'

class HumanBrain < Brain
  set_nice_name("Humano")
  set_description("El Hombre... único animal con poder de raciocinio")

  def choose_action
    action = NilAction.new(self)
    if @selected and @victim
      action = DoAttack.new(@selected, @victim, @attack_type)
    elsif @selected and @destination_col and @destination_row
      action = Move.new(@selected, @destination_col, @destination_row)
    end
    @selected = @victim = @destination_row = @destination_col = nil
    return action
  end

  # Notifies that something was clicked on the view. The action represents some extra decision that the controller needs to take from the view
  def notify(selected, row, col, &action)
    if @combat_groups.include?(selected) #Selected is mine
      @selected = selected
      @destination_row = @destination_col = @victim = nil #Everything goes back to 0
      action.call(nil,nil)
    elsif @selected and selected.is_a?(CombatGroup) #Selected is not mine, but i had selected an owned one before
      if (not @selected.possible_attacks_to(selected.x, selected.y).empty?)
        @victim = selected
        action.call(@player, @selected)
      end

        @destination_row = @destination_col = nil #I'm attacking, not moving
    elsif @selected and selected.nil? and @matrix.has_way_out?(@selected.y, @selected.x) and @selected.can_move_to?(col, row)# I'm selecting an empty space
      @destination_row, @destination_col = row, col
      @victim = nil #I'm moving, not attacking
    end
  end

  def notify_selection(attack_type)
    @attack_type = attack_type
  end

  def automatic?
    false
  end

  def self.automatic?
    false
  end
end

