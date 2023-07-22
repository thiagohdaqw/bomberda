from typing import List
import sys

FLOOR = " "
FRAGILE_FLOOR = "x"
COLAPSED_FLOOR = "X"
BOX = "$"
WALL = "#"
PLAYER = "@"
TREASURE = "."
MONSTER = "E"
POSITION = "position"

problem_path = "/tmp/mapa.pddl"

SOLVER = "downward/fast-downward.py --alias lama-first"

def generate_eqs(len_lines, len_columns):
    predicates = []
    for i in range(1, len_columns):
        predicates.append(f"(eq x{i} x{i})")
    for i in range(1, len_lines):
        predicates.append(f"(eq y{i} y{i})")    
    return " ".join(predicates)

def generate_incs(len_lines, len_columns):
    predicates_x = []
    predicates_y = []
    for i in range(1, len_columns):
        predicates_x.append(f"(inc x{i} x{i+1})")
    for i in range(1, len_lines):
        predicates_y.append(f"(inc y{i} y{i+1})")    
    return " ".join(predicates_x), " ".join(predicates_y)

def generate_decs(len_lines, len_columns):
    predicates_x = []
    predicates_y = []
    for i in range(len_columns, 1, -1):
        predicates_x.append(f"(dec x{i} x{i-1})")
    for i in range(len_lines, 1, -1):
        predicates_y.append(f"(dec y{i} y{i-1})")
    return " ".join(predicates_x), " ".join(predicates_y)

def generate_problem(map_path):
    positions = []

    with open(map_path) as map_file:
        lines = map_file.read().splitlines()
        width = max(len(line) for line in lines)
        height = len(lines)

        for i in range(width):
            positions.append(f"x{i+1}")
        
        for j in range(height):
            positions.append(f"y{j+1}")

        inc_x, inc_y = generate_incs(height, width)
        dec_x, dec_y = generate_decs(height, width)
        walls = []
        player = ""
        goal = ""
        treasure = ""
        enemy = ""

        for row, line in enumerate(lines):
            for column, char in enumerate(line):
                if char == WALL:
                    walls.append(f"(wall x{column+1} y{row+1})")
                elif char == PLAYER:
                    player = f"(player-at x{column+1} y{row+1})"
                elif char == TREASURE:
                    treasure = "(has-treasure)"
                    goal = f"(player-at x{column+1} y{row+1})"
                elif char == MONSTER:
                    enemy = f"(enemy-at x{column+1} y{row+1}) (is-enemy enemy) (has-enemy)"

        if not goal:
            goal = "(win)"

    output_data = f"""(define (problem bomberdaproblem)
        (:domain bomberda)
        (:objects {" ".join(positions)} - position
                    t0 t1 t2 t3 - timer)
        (:init 
            {" ".join(walls)}
            {inc_x}
            {inc_y}
            {dec_x}
            {dec_y}
            {player}
            {enemy}
            {treasure}
            (is-zero-timer t0) (is-max-timer t3)
            (dec-timer t3 t2) (dec-timer t2 t1) (dec-timer t1 t0)
        )
        (:goal
            (and
                (not (is-dead))
                (not (has-action))
                {goal}
            )
        )
    )
    """

    with open(problem_path, 'w') as problem_file:
        problem_file.write(output_data)

def generate_domain():
    with open("/tmp/domain.pddl", "w") as domain:
        domain.write("""
(define (domain bomberda)
    (:requirements :strips)
    (:types
        position timer
    )
    (:predicates
        (inc ?a ?b - position)
        (dec ?a ?b - position)
        (enemy-at ?x ?y - position)
        (player-at ?x ?y - position)
        (wall ?x ?y)
        (has-enemy)
        (has-action)
        (check-is-dead)
        (is-dead)
        (enemy-move)
        (enemy-up)
        (enemy-down)
        (enemy-left)
        (enemy-right)
        (check-from-enemy)
        (has-bomb)
        (bomb-at ?x ?y)
        (current-bomb-timer ?t - timer)
        (is-max-timer ?t - timer)
        (is-zero-timer ?t - timer)
        (dec-timer ?a ?b - timer)
        (check-bomb)
        (has-treasure)
        (win)
        (check-end-turn)
    )

    (:action FINALIZAR_TURNO
        :parameters ()
        :precondition (check-end-turn)
        :effect (and
            (not (check-end-turn))
            (not (has-action))
            (forall (?x ?y - position)
                (when (and (not (has-treasure)) (not (has-enemy)) (player-at ?x ?y) (enemy-at ?x ?y)) (win))
            )
        )
    )
    

    (:action SOLTARBOMBA
        :parameters (?px ?py - position ?t - timer)
        :precondition (and (not (has-action)) (not (has-bomb)) (player-at ?px ?py) (is-max-timer ?t))
        :effect (and (bomb-at ?px ?py) (current-bomb-timer ?t) (has-bomb))
    )

    (:action PASSAR_TURNO_BOMBA
        :parameters ()
        :precondition (and (check-bomb) (not (has-bomb)))
        :effect (and (not (check-bomb)) (check-end-turn))
    )
    

    (:action DECREMENTAR_TIMER_BOMBA
        :parameters (?t ?n - timer)
        :precondition (and (check-bomb) (has-bomb) (current-bomb-timer ?t) (dec-timer ?t ?n) (not (is-zero-timer ?n)))
        :effect (and
                    (not (check-bomb))
                    (not (current-bomb-timer ?t))
                    (check-end-turn)
                    (current-bomb-timer ?n)
                )
    )

    (:action EXPLODIR_BOMBA
        :parameters (?t ?n - timer)
        :precondition (and (check-bomb) (has-bomb) (current-bomb-timer ?t) (dec-timer ?t ?n) (is-zero-timer ?n))
        :effect (and 
                    (not (bomb-at ?bx ?by))
                    (not (check-bomb))
                    (not (has-bomb))
                    (check-end-turn)
                    (not (current-bomb-timer ?t))
                    (forall (?x ?y ?w - position) 
                        (when
                            (and
                                (bomb-at ?x ?y)
                                (or 
                                    (enemy-at ?x ?w)
                                    (enemy-at ?w ?y)
                                    (enemy-at ?x ?y)
                                )
                                (or
                                    (inc ?x ?w)
                                    (inc ?y ?w)
                                    (dec ?x ?w)
                                    (dec ?y ?w)
                                )    
                            ) 
                            (not (has-enemy)))
                    )
                    (forall (?x ?y ?w - position) 
                        (when
                            (and
                                (bomb-at ?x ?y)
                                (or 
                                    (player-at ?x ?w)
                                    (player-at ?w ?y)
                                    (player-at ?x ?y)
                                )
                                (or
                                    (inc ?x ?w)
                                    (inc ?y ?w)
                                    (dec ?x ?w)
                                    (dec ?y ?w)
                                )    
                            ) 
                            (is-dead))
                    )
                )
    )
    
    

    (:action CHECK_DEAD
        :parameters (?px ?py ?ex ?ey - position)
        :precondition (and (has-enemy) (check-is-dead) (player-at ?px ?py) (enemy-at ?ex ?ey))
        :effect (and
            (when
                (and (player-at ?px ?py) (enemy-at ?px ?py))
                (is-dead))
            (not (check-is-dead))
            (when (not (check-from-enemy)) (enemy-move))
            (when (check-from-enemy) (and (not (check-from-enemy)) (check-bomb)))
        )
    )

    (:action CHECK_DEAD_WITHOUT_ENEMY
        :parameters ()
        :precondition (and (not (has-enemy)) (check-is-dead))
        :effect (and (check-bomb) (not (check-is-dead)))
    )

    (:action CIMA
        :parameters ()
        :precondition (not (has-action))
        :effect (forall
                    (?x ?y ?yn - position)
                    (when
                        (and (player-at ?x ?y)
                            (dec ?y ?yn)
                            (not (wall ?x ?yn)))
                        (and (not (player-at ?x ?y))
                            (player-at ?x ?yn)
                            (enemy-down)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )

    (:action BAIXO
        :parameters ()
        :precondition (not (has-action))
        :effect (forall
                    (?x ?y ?yn - position)
                    (when
                        (and (player-at ?x ?y)
                            (inc ?y ?yn)
                            (not (wall ?x ?yn)))
                        (and (not (player-at ?x ?y))
                            (player-at ?x ?yn)
                            (enemy-up)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )

    (:action DIREITA
        :parameters ()
        :precondition (not (has-action))
        :effect (forall
                    (?x ?y ?xn - position)
                    (when
                        (and (player-at ?x ?y)
                            (inc ?x ?xn)
                            (not (wall ?xn ?y)))
                        (and (not (player-at ?x ?y))
                            (player-at ?xn ?y)
                            (enemy-left)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )

    (:action ESQUERDA
        :parameters ()
        :precondition (not (has-action))
        :effect (forall
                    (?x ?y ?xn - position)
                    (when
                        (and (player-at ?x ?y)
                            (dec ?x ?xn)
                            (not (wall ?xn ?y)))
                        (and (not (player-at ?x ?y))
                            (player-at ?xn ?y)
                            (enemy-right)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )
    

    (:action INIMIGO_DIREITA
        :parameters ()
        :precondition (and (enemy-move) (enemy-right))
        :effect (and
            (forall
                (?x ?y ?xn - position)
                (when
                    (and (enemy-at ?x ?y)
                        (inc ?x ?xn)
                        (not (wall ?xn ?y)))
                    (and (not (enemy-at ?x ?y))
                        (enemy-at ?xn ?y))
                )
            )
            (not (enemy-move))
            (not (enemy-right))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_ESQUERDA
        :parameters ()
        :precondition (and (enemy-move) (enemy-left))
        :effect (and
            (forall
                (?x ?y ?xn - position)
                (when
                    (and (enemy-at ?x ?y)
                        (dec ?x ?xn)
                        (not (wall ?xn ?y)))
                    (and (not (enemy-at ?x ?y))
                         (enemy-at ?xn ?y))
                )
            )
            (not (enemy-move))
            (not (enemy-left))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_CIMA
        :parameters ()
        :precondition (and (enemy-move) (enemy-up))
        :effect (and
            (forall
                (?x ?y ?yn - position)
                (when
                    (and (enemy-at ?x ?y)
                        (dec ?y ?yn)
                        (not (wall ?x ?yn)))
                    (and (not (enemy-at ?x ?y))
                        (enemy-at ?x ?yn))
                )
            )
            (not (enemy-move))
            (not (enemy-up))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_BAIXO
        :parameters ()
        :precondition (and (enemy-move) (enemy-down))
        :effect (and
            (forall
                (?x ?y ?yn - position)
                (when
                    (and (enemy-at ?x ?y)
                        (inc ?y ?yn)
                        (not (wall ?x ?yn)))
                    (and (not (enemy-at ?x ?y))
                        (enemy-at ?x ?yn))
                )
            )
            (not (enemy-move))
            (not (enemy-down))
            (check-is-dead)
            (check-from-enemy)
        )
    )
)
        """)

def main():
    generate_domain()
    generate_problem(sys.argv[1])
    print(SOLVER)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <map_filepath>")
        print("Error: map path must be specified")
        exit(1)
    main()
