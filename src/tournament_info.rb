class HashWithDefault < Hash
  def initialize(default)
    super()
    self.default = default
  end
end

class TournamentInfo
  attr_reader :name

  def initialize(directory_path)
    Dir.glob("#{directory_path}/*") {|filename|
      play_round_info = nil
      File.open(filename, 'r' ) do |file|
        play_round_info = Marshal.load(file)
      end
      winner = play_round_info[play_round_info.length - 2].brain
      looser = play_round_info.last.brain
      add_brain(winner); add_brain(looser)
      wins_by_brain[winner] += 1
      wins_units_hits_by_brain[winner]+= hit_points(play_round_info[play_round_info.length - 2].combat_group_members)
      initial_units_hits_by_brain[winner]+= hit_points(play_round_info[0].combat_group_members)
      rounds_to_win_by_brain[winner]+=play_round_info.length/2
      wins_by_brain_vs_brain[winner][looser] +=1
      defeats_by_brain[looser] += 1
      defeats_by_brain_vs_brain[looser][winner] +=1
    }
    @name = directory_path.split("/").last
  end

  def brains_in_tournament
    @brains_in_tournament ||= []
  end

  def add_brain(brain)
    brains_in_tournament << brain unless brains_in_tournament.include?(brain)
  end

  def wins_by_brain_vs_brain
    @wins_by_brain_vs_brain ||= Hash.new{|hash, key| hash[key] = HashWithDefault.new(0)}
  end

  def defeats_by_brain_vs_brain
    @defeats_by_brain_vs_brain ||= Hash.new{|hash, key| hash[key] = HashWithDefault.new(0)}
  end
  
  def wins_units_hits_by_brain 
    @wins_units_hits_by_brain ||= {}
    @wins_units_hits_by_brain.default = 0
    @wins_units_hits_by_brain
  
  end

  def initial_units_hits_by_brain 
    @initial_units_hits_by_brain ||= {}
    @initial_units_hits_by_brain.default = 0
    @initial_units_hits_by_brain
  
  end
  
  def rounds_to_win_by_brain 
    @rounds_to_win_by_brain ||= {}
    @rounds_to_win_by_brain.default = 0
    @rounds_to_win_by_brain
  
  end

  def wins_by_brain
    @wins_by_brain ||= {}
    @wins_by_brain.default = 0
    @wins_by_brain
  end

  def defeats_by_brain
    @defeats_by_brain ||= {}
    @defeats_by_brain.default = 0
    @defeats_by_brain
  end
  
  def hit_points(group)
    total_hit_points=0 
    group.each{|member|
        total_hit_points+=member.hit_points
    }
    return total_hit_points
  end

  def result_for(brain)
    wins = @wins_by_brain[brain].to_f
    defeats = @defeats_by_brain[brain].to_f
    total_played = (wins + defeats).to_f
    percentage_wins = 100*(wins/total_played)
    percentage_hp_when_winning = 100*(wins_units_hits_by_brain[brain]/initial_units_hits_by_brain[brain].to_f)
    rounds_to_win = rounds_to_win_by_brain[brain]/wins.to_f
    percentage_wins + percentage_hp_when_winning/5.0 - rounds_to_win/6.0
  end

  def self.objective_function
    'PorcPartidasGanadas + \frac{PorcVidaAlGanar}{5} - \frac{PromRondasParaGanar}{6}'
  end
  
end
