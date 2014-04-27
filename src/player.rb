require 'forwardable'

class Player
  extend Forwardable

  def self.next_side
    @@side ||= :right
    @@side = (@@side == :left) ? :right : :left 
    return @@side
  end

  def_delegators :controller, :choose_action, :notify_selection, :'automatic?', :'matrix=', :notify_enemy_action
  attr_reader :name, :color, :combat_groups, :controller
  def initialize(name, color, controller)
    @name = name
    @color = color
    @combat_groups = []
    side = Player.next_side
    CombatGroup.subclasses.each{|subclass| @combat_groups << subclass.new(10, side)}
    @controller = controller.new(self)
  end
  
  def player_fighter?(fighter)
     @combat_groups.include?(fighter)
  end

  def alive?
    @combat_groups.each { |group| return true if group.alive? }
    return false
  end

  def number_of_units
    number = 0
    @combat_groups.each{|combat_group| number += combat_group.number_of_members}
    return number
  end
end
