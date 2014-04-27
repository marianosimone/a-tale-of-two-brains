class AttackStrongerBrain < Brain
  set_nice_name("Mas-Fuerte-Primero")
  set_description("En cada turno juega un tipo distinto. Siempre se intenta atacar al m+as fuerte de los contrarios")
  include IABrain
  include IterativeBrain
  include VictimBasedBrain

  def find_victim
    enemy_groups.sort{ |group1, group2|
      group1.max_attack_strength <=> group2.max_attack_strength
    }.last
  end
end
