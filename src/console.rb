require 'game'
require 'player'

class Console
  def initialize()
      @player_creation_inputs = []
      puts "A tale of two brains Game"
      init_brains
      NumberOfPlayers.times do |@i|
        @player_creation_inputs[@i] = []
        puts "Nombre de jugadores"
        get_name
        puts "Elija uno de los siguientes cerebros: "
        get_brain
        
      end
      init_game
      
  end
  
  def get_name
      puts "Nombre jugador #{(@i + 1)}: " 
      STDOUT.flush
      @player_creation_inputs[@i][0] = gets.chomp
  
  end
  def init_brains
      @hash_brains = {}
      Brain.subclasses.each_with_index {|brain,index|  
          if index != 0 #para omitir el humano    
            @hash_brains[index]= "#{brain.nice_name}"
          end
      } 
  
 end
  
  def get_brain
      puts "Cerebros disponibles: "
      @hash_brains.each{|key,value|
         puts "#{key}. #{value}" 
      } 
      index= 0
      while ( (index > @hash_brains.values.size) || (index <= 0))
        puts "Cerebro a utilizar: " 
        STDOUT.flush
        index=gets.to_i
      end
        @player_creation_inputs[@i][1] = @hash_brains[index]
  
  end
  
  def init_game
    players = []
    NumberOfPlayers.times do |i|
            controller = @player_creation_inputs[i][1]
            name = "#{@player_creation_inputs[i][0]}"
            player = Player.new(name, nil,NicelyNamed::get_class_from_name(controller))
            players << player
          end
          @game =CombatGame.new(players)
  end     
  
  def play
     taken_action = @game.play_round   
     if @game.can_continue?
        play
     else
        puts "Fin del juego"
        puts "Ha ganado el jugador: #{@game.pasive_player.name}"

     end
  
  end
  
end

console= Console.new
console.play
