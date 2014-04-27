class AttackAlmostDeadBrain < Brain
  set_nice_name("Matar-Al-Más-Muerto")
  set_description("En cada turno juega un tipo distinto. Siempre se intenta atacar al mas cercano de morir de los enemigos")
  include IABrain
  include IterativeBrain
  include VictimBasedBrain

  def find_victim
    enemy_groups.sort{ |group1, group2|
      group1.hit_points <=> group2.hit_points
    }.first
  end
end
