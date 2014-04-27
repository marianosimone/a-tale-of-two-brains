require 'play_round_info'
require 'matrix_data_structure'

class CombatGame
  attr_reader :active_player, :pasive_player, :players, :rounds, :matrix
  def initialize(players)
    raise "CombatGame only supports 2 teams right now" unless players.size == 2
    @matrix = MatrixDataStructure.new(9,16)
    @active_player = players[0]
    @active_player.matrix = @matrix
    @pasive_player = players[1]
    @pasive_player.matrix = @matrix
    @players = players   
    @rounds = 0
    arrange_groups
    @actions_to_save = []
    #guardo estado inicial de ambos jugadores
    @actions_to_save << PlayRoundInfo.new(@active_player,nil)
    @actions_to_save << PlayRoundInfo.new(@pasive_player,nil)
  end

  def arrange_groups
    [@active_player, @pasive_player].each_with_index {|player, i|
      player.matrix = @matrix
      player.combat_groups.each_with_index { |group, j|
        col = i == 0 ? 0 : @matrix.n_cols-1
        row = (@matrix.n_rows/player.combat_groups.size).floor*j
        group.move!(col, row)
        @matrix.set_at(row, col, group)  
      }
    }
  end

  def play_round
    @rounds += 1
    action = @active_player.choose_action
    action.execute
    @actions_to_save << PlayRoundInfo.new(@active_player,action)
    pasive_player.notify_enemy_action(action)
    @active_player, @pasive_player = @pasive_player, @active_player
    update_from_action(action)
    return action
  end

  def update_from_action(action)
    if action.class == Move
      group = action.combat_group
      @matrix.move(group, action.y, action.x)
    elsif action.class == DoAttack
      if not action.defender.alive?
        @active_player.combat_groups.delete(action.defender) #It's the active one, because the round is over, so they're swapped
        @matrix.set_at(action.defender.y, action.defender.x, nil)
      end
    end
  end

  def can_continue?
    status = (@active_player.alive? and @pasive_player.alive?)
    if ! status
      #guardo estado del que pierde
      @actions_to_save << PlayRoundInfo.new(@active_player,nil)
      actions_filename = "#{ReportsLocation}/actions.#{Time.now.to_i}.#{self.object_id}"
      File.open(actions_filename, 'w' ) do |out|
        Marshal.dump(@actions_to_save, out)
      end
    end 
    return status
  end
end
