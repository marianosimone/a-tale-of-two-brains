class Action
  attr_reader :description
  def self.inherited(subclass)
      subclass.send :include, NicelyNamed
  end
end

class Move < Action
  attr_reader :combat_group, :x, :y, :previous_x, :previous_y
  set_nice_name("Move")
  def initialize(combat_group, x, y)
    @combat_group = combat_group
    @x, @y = x, y
  end

  def execute
    @previous_x = @combat_group.x
    @previous_y = @combat_group.y
    @combat_group.move!(@x,@y)
    @description = "#{@combat_group.nice_name} se mueve de (#{@previous_x},#{@previous_y}) hacia (#{@combat_group.x},#{@combat_group.y})"
  end
end

class DoAttack < Action
  attr_reader :attacker, :defender, :damage_done, :attack_type
  set_nice_name("Attack")
  def initialize(attacker, defender, attack_type)
    @attacker, @defender = attacker, defender
    @attack_type = attack_type
  end

  def execute
    attack = @attacker.generate_attack(@attack_type)
    previous_hp = @defender.hit_points
    @defender.receive_attack!(attack)
    @description="#{@attacker.nice_name} ataca a #{@defender.nice_name} con #{@attack_type}. Daño: #{(@defender.hit_points - previous_hp).abs}"
  end
end

class NilAction < Action
  attr_reader :controller_name
  set_nice_name("Do Nothing")
  def initialize(controller)
    @controller_name = controller.class.name
  end

  def execute
    @description = "Decidio no hacer nada"
  end
end
