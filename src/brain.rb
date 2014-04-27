class Brain
  attr_accessor :matrix
  # Cada vez que una clase se declara heredera de esta, la agregamos a un array. Ademas, le hacemos incluir el modulo NicelyNamed
  def self.inherited(subclass)
    @subclasses ||= []
    @subclasses << subclass
    subclass.send :include, NicelyNamed
  end

  def self.subclasses
    @subclasses
  end

  def initialize(player)
    @player = player
    @combat_groups = @player.combat_groups
  end

  def enemy_groups
    @matrix.elements.reject{|group| @combat_groups.include?(group)}
  end

  def notify_enemy_action(action)
    nil #Most Brains won't care
  end

  def self.automatic?
    true
  end
end

module IABrain

  def choose_action
    @active_group = choose_group
    build_action
  end

  def notify(selected, row, col, &action)
    # I'm an IA, I don't care what happens on the  view
  end

  def automatic?
    true
  end

  def find_possible_attacks
    options = []
    @active_group.available_attacks.each{|attack_type|
      @active_group.target_positions_for(attack_type).each{|target|
        row, col = target[1], target[0]
        victim = matrix.is_in_range?(row, col) ? matrix.element_at(row, col) : matrix.default
        options << [victim, attack_type] unless (victim == matrix.default or @combat_groups.include?(victim))
      }
    }
    return options
  end

  def find_possible_locations
    max_to_move = @active_group.max_cells_to_move
    options = []
    if @matrix.has_way_out?(@active_group.y, @active_group.x)
      @active_group.positions_to_move.each{|position|
        if (
             @matrix.is_in_range?(position[1],position[0]) and
             (@matrix.element_at(position[1], position[0]) == @matrix.default) and # It's an empty place
             (position[0] != @active_group.x or position[1] != @active_group.y) # It's actually moving
           )
             options << position
        end
      }
    end
    return options
  end
end

module IterativeBrain
  def choose_group
    @combat_groups[group_in_turn]
  end

  def group_in_turn
    @last_size ||= @combat_groups.size
    if (@group_in_turn.nil? or @group_in_turn >= @combat_groups.size or @last_size != @combat_groups.size)
      @group_in_turn = 0
      @last_size = @combat_groups.size
    end
    @group_in_turn += 1
    return @group_in_turn-1
  end
end

module VictimBasedBrain
  def build_action
    @victim = find_victim
    attacks = find_possible_attacks
    attacks.reject!{|attack| attack[0] != @victim}
    return DoAttack.new(@active_group, @victim, attacks.first[1]) unless attacks.empty?
    new_x, new_y = find_new_location
    return Move.new(@active_group, new_x, new_y) unless new_x.nil?
    return NilAction.new(self)
  end

  def find_new_location
    options = find_possible_locations
    return nil, nil if options.empty?
    best_x = best_y = nil
    best_distance = (@matrix.n_rows + @matrix.n_cols)
    options.each{|location|
      distance = (@victim.x-location[0]).abs + (@victim.y-location[1]).abs 
      if distance <= best_distance
        best_x, best_y = location
        best_distance = distance
      end
    }
    return best_x, best_y
  end
end

module AntiStatusQuoBrain
  attr_accessor :status_quo_breaker

  def choose_action
    return break_status_quo if in_status_quo?
    action = super
    add_round_without_move if action.is_a?(NilAction)
    return action
  end

  def in_status_quo? 
    (@rounds_without_move and @rounds_without_move >= 5) 
  end

  def add_round_without_move
    @rounds_without_move = @rounds_without_move ? @rounds_without_move+1 : 1
  end

  def break_status_quo
    @rounds_without_move = 0
    return status_quo_breaker.choose_action
  end

  def matrix=(matrix)
    @matrix = matrix
    status_quo_breaker.matrix = matrix
  end
end
