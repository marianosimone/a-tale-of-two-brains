class AttackLessMembersBrain < Brain
  set_nice_name("Matar-A la minoria")
  set_description("En cada turno juega un tipo distinto. Siempre se intenta atacar al que posee menor cantidad de miembros de los enemigos")
  include IABrain
  include IterativeBrain
  include VictimBasedBrain

  def find_victim
    enemy_groups.sort{ |group1, group2|
      group1.number_of_members <=> group2.number_of_members
    }.first
  end
end
