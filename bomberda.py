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

SOLVER = ""
PROBLEM_PATH = ""
DOMAIN_PATH = ""

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
    if not PROBLEM_PATH:
        problem_path = map_path + ".pddl"
    else:
        problem_path = PROBLEM_PATH

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
        box = []
        fragile_floors = []

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
                elif char == BOX:
                    box.append(f"(box x{column+1} y{row+1})")
                elif char == FRAGILE_FLOOR:
                    fragile_floors.append(f"(unstable-floor x{column+1} y{row+1})")

    with open(problem_path, 'w') as problem_file:
        problem_file.write(f"""
            (define (problem bomberdaproblem)
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
                    {" ".join(box)}
                    {" ".join(fragile_floors)}
                    {"(has-box)" if box else ""}
                    (is-zero-timer t0) (is-max-timer t3)
                    (dec-timer t3 t2) (dec-timer t2 t1) (dec-timer t1 t0)
                )
                (:goal
                    (and
                        (not (is-dead))
                        (not (has-action))
                        {"(win)" if not goal else goal}
                    )
                )
            )
            """)

def generate_domain():
    if not DOMAIN_PATH:
        return
    
    with open(DOMAIN_PATH, "w") as domain:
        domain.write("""
; <include_domain>
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
