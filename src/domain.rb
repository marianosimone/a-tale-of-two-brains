require 'util'
require 'game_constants'

class AttackType < Enum
  add_item :Fire, 1
  add_item :Water, 2
  add_item :Lightning, 3
  add_item :Piercing, 4
  add_item :Blade, 5
end

class Attack
  attr_reader :type, :strength
  def initialize(type, strength)
    @type = type
    @strength = strength
  end
end

class AttackCapability
  attr_reader :strengths, :range
  def initialize(strengths, range)
    @strengths = strengths
    @range = range
  end
end

class CombatGroup
  def self.inherited(subclass)
    @subclasses ||= []
    @subclasses << subclass
    subclass.send :include, NicelyNamed
  end

  def self.subclasses
    @subclasses
  end

  attr_reader :number_of_members, :hit_points, :max_cells_to_move, :x, :y
  def initialize(number_of_members, side, max_move)
    @number_of_members = number_of_members
    @side = side
    @max_cells_to_move = max_move
    @hp_per_member = 0
    @attacks = {}
    @attacks.default = (0..0)
    @defenses = {}
    @defenses.default = (0..0)
  end

  def file_image_name
    "#{SpritesLocation}/#{self.class.name.downcase}_#{@side}.png"
  end

  def generate_attack(attack_type)
    Attack.new(attack_type, @number_of_members*@attacks[attack_type].strengths.random)
  end

  def available_attacks
    @attacks.keys
  end

  def receive_attack!(attack)
    defense = @defenses[attack.type].random
    damage = attack.strength - defense*@number_of_members

    @hit_points -= damage unless damage < 0    
    @hit_points = 0 if @hit_points < 0
    @number_of_members = (Float(@hit_points)/Float(@hp_per_member)).ceil
  end

  def alive?
    @number_of_members > 0
  end

  def move!(x,y)
    raise "#{self} can't move from [#{@x},#{@y}] to [#{x},#{y}]" if (not can_move_to?(x,y))
    @x, @y = x, y
  end

  def can_move_to?(x,y)
    return true if @x.nil? or @y.nil? # If it wasn't located anywhere...
    return ( ((@x-x).abs <= @max_cells_to_move) and ((@y-y).abs <= @max_cells_to_move))
  end

  def positions_to_move
    positions = []
    (x-max_cells_to_move..x+max_cells_to_move).each{|target_x|
      (y-max_cells_to_move..y+max_cells_to_move).each{|target_y|
        positions << [target_x, target_y]
      }
    }
    return positions
  end

  # Possible places to attack, given an attack type
  def target_positions_for(attack_type)
    targets = []
    delta = @attacks[attack_type].range
    (x-delta..x+delta).each{|target_x|
      (y-delta..y+delta).each{|target_y|
        targets << [target_x, target_y] unless (target_x == x and target_y == y)
      }
    }
    return targets
  end

  # Possible attack types, given a position to attack
  def possible_attacks_to(x, y)
    possible_attacks = []
    @attacks.each{|attack, capability|
      distance = capability.range
      possible_attacks << attack unless ((@x - x).abs > distance or (@y - y).abs > distance)
    }
    return possible_attacks
  end

  def sorted_attack_types
    @attacks.sort{|attack1, attack2|
      attack1[1].strengths.max <=> attack2[1].strengths.max
    }
  end

  def max_attack_strength
    sorted_attack_types.last[1].strengths.max
  end

  def max_strength_for_attack_type(attack_type)
    @attacks[attack_type] ? @attacks[attack_type].strengths.max : 0
  end
protected
  def set_hp_per_member(hp)
    @hp_per_member = hp
    @hit_points = hp*number_of_members
  end
end

class Knights < CombatGroup
  set_nice_name "Caballeros"
  def initialize(number_of_members, side)
    super(number_of_members,side,5)
    set_hp_per_member(15)
    @attacks[AttackType::Blade] = AttackCapability.new((10..16),1)
    @defenses[AttackType::Blade] = (4..6)
    @defenses[AttackType::Piercing] = (0..2)
  end
end

class Archers < CombatGroup
  set_nice_name "Arqueros"
  def initialize(number_of_members, side)
    super(number_of_members, side,3)
    set_hp_per_member(10)
    @attacks[AttackType::Piercing] = AttackCapability.new((9..13),5)
    @attacks[AttackType::Blade] = AttackCapability.new((1..3),1)
    @defenses[AttackType::Piercing] = (2..5)
    @defenses[AttackType::Fire] = (0..2)
  end
end

class Mages < CombatGroup
  set_nice_name "Magos"
  def initialize(number_of_members, side)
    super(number_of_members, side,2)
    set_hp_per_member(5)
    @attacks[AttackType::Water] = AttackCapability.new((8..11),9)
    @attacks[AttackType::Fire] = AttackCapability.new((8..11),9)
    @attacks[AttackType::Lightning] = AttackCapability.new((8..11),9)
    @defenses[AttackType::Water] = (1..4)
    @defenses[AttackType::Fire] = (1..4)
    @defenses[AttackType::Lightning] = (1..4)
  end
end

class Assassins < CombatGroup
  set_nice_name "Asesinos"
  def initialize(number_of_members, side)
    super(number_of_members,side,4)
    set_hp_per_member(8)
    @attacks[AttackType::Blade] = AttackCapability.new((8..12),1)
    @attacks[AttackType::Piercing] = AttackCapability.new((6..10),3)
    @attacks[AttackType::Lightning] = AttackCapability.new((5..9),5)
    @defenses[AttackType::Blade] = (3..5)
    @defenses[AttackType::Piercing] = (0..2)
  end
end

