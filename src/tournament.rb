require 'game'
require 'player'
require 'util'

number_of_plays = (ARGV[0] || 1).to_i
competitors = Brain.subclasses
competitors.reject!{|brain| !brain.automatic?}
brains_pairs = cartprod(competitors, competitors)

number_of_plays.times do
  brains_pairs.each_with_index{|pair,index|
    game = CombatGame.new([Player.new(pair[0].nice_name, nil,pair[0]),Player.new(pair[1].nice_name, nil,pair[1])])
    while (game.can_continue?)
      game.play_round
    end
    puts "#{index+1}. #{pair[0].nice_name} vs #{pair[1].nice_name}. Ganador: #{game.pasive_player.name} (en #{game.rounds} rondas)"
  }
end
