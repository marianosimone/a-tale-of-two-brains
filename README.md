# A Tale of Two Brains

Example turn-based-combat AIs and a framework to compare them from a game-theory perspective

## Definición del problema

Dos jugadores se enfrentan, cada uno con un personaje elegido previamente, en una lucha a muerte por turnos. 

Los personajes poseen diferentes habilidades y equipamiento (golpes o poderes especiales, armaduras, armas, etc.), configurables desde la aplicación. 

Cada jugador llevará a cabo su propia estrategia, eligiendo en cada turno, la forma en que desea atacar o defenderse (para disminuir el daño que pueda sufrir durante el ataque del contrincante). 

El juego podrá ser simulado completamente (máquina-máquina), o podrá optarse por jugar interactivamente (humano-máquina o humano-humano). En cualquier situación, el objetivo del sistema será intentar derrotar a su contrincante.

Las determinación de las estrategias podrá estar relacionada con varios factores como: resultados de jugadas anteriores, reacciones del oponente, características propias de los personajes, efecto de los movimientos previos, etc.. La selección de la misma será el factor más importante dentro de la aplicación, conformando como punto a optimizar a una estrategia con altas chances de derrotar a cualquier otra.[1] 

## Modelo

El problema será relacionado con Teoría de Juegos ("Players try to outguess their opponents by imagining how they themselves would act if they were in their opponents’ position"[2]) y, eventualmente, aprendizaje (mediante redes neuronales, por ejemplo). Utilizando herramientas de éstas dos áreas, se desarrollará una serie de estrategias que podrán ser elegidas al momento de comenzar el juego.

## Alcance

Se podrá optar por jugar contra la máquina y entre máquinas. En dichos casos observaremos cómo reacciona cada personaje ante cada acción del oponente y se podrá evaluar la elección de la estrategia en función del resultado obtenido. Se podrá, además, ver cómo reacciona cada tipo de estrategia ante cambios en el entorno (estrategia contra la que pelea, accesorios utilizados, etc)

## Referencias

- [1] Se pretende hacer comparaciones entre distintas estrategias, como podrían ser Tit For Tat (y sus variantes), Chicken, Deterrance, etc. hasta encontrar una Dominante
- [2] [Game Theory, Prisoner’s Dilemma, Nash Equilibrium, Stag Hunts, and Sherlock Holmes… and Counter-Terrorism? 1/2](http://russwbeck.wordpress.com/2009/01/18/sra211reviewgametheory/)
- [3] [Evolving New Strategies: The Evolution of Strategies in the Iterated Prisoner's Dilemma, Robert Axelrod](http://www-personal.umich.edu/~axe/research/Evolving.pdf)