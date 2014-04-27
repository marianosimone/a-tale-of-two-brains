class SameClassBrain < Brain
  set_nice_name("Mismo-Tipo")
  set_description("En cada turno juega un tipo distinto. Busca a un contrario de su mismo tipo, si no lo hay, elige al ultimo. Una vez elegido, si puede lo ataca o se mueve a la ubicación más cercana")
  include IABrain
  include IterativeBrain
  include VictimBasedBrain

  def find_victim
    victim = nil
    enemy_groups.each {|group|
      victim = group
      break if victim.class == @active_group.class 
    }
    return victim
  end
end
