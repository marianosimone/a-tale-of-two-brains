require 'control'
require 'domain'

class PlayRoundInfo
   attr_reader :combat_group_members, :player_name, :brain, :action
   def initialize(player,action)
      @player_name = player.name
      @brain = player.controller.nice_name
      @combat_group_members = []

      player.combat_groups.each{|member|
          @combat_group_members << GroupInfo.new(member)
      }
      @action = action
   end
end

class GroupInfo
   attr_reader :hit_points, :members, :file_image_name
   def initialize(member)
      @hit_points = member.hit_points
      @members = member.number_of_members   
      @file_image_name = member.file_image_name
   end
end
