class WaitAndLetStrongestAttackBrain < Brain
  set_nice_name("Esperar-Mas-Fuerte-Primero")
  set_description("No hace nada hasta que alguien se pone a tiro. En caso de ser varios los atacantes posibles, ataca el más fuerte")
  include IABrain
  include AntiStatusQuoBrain

  def initialize(player)
    super
    self.status_quo_breaker = RandomBrain.new(player)
  end

  def choose_group
    options = []
    @combat_groups.each{|group|
      @active_group = group
      find_possible_attacks.each{|attack| #victim, att type
        options << [group, attack[0], attack[1]]
      }
    }
    best_option = options.sort{|option1, option2|
      option1[0].max_strength_for_attack_type(option1[2]) <=> option2[0].max_strength_for_attack_type(option2[2])
    }.last
    if best_option
      @active_group, @victim, @attack_type = best_option
      return @active_group
    else
      return nil
    end
  end

  def build_action
    return DoAttack.new(@active_group, @victim, @attack_type) unless @active_group.nil?
    return NilAction.new(self)
  end
end
