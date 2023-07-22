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
    problem_path = map_path + ".pddl" # "/tmp/mapa.pddl"
    
    positions = []
    player_name = "bomberman"

    with open(map_path) as map_file:
        _map = map_file.read()
        lines = _map.splitlines()
        y_len = len(lines)
        x_len = len(lines[0])

        for i in range(1, x_len+1):
            positions.append(f"x{i}")
        
        for j in range(1, y_len+1):
            positions.append(f"y{j}")

        inc_x, inc_y = generate_incs(y_len, x_len)
        dec_x, dec_y = generate_decs(y_len, x_len)
        walls = []
        player = ""
        goal = ""
        has_enemy = False
        enemy = ""

        for line in range(0, y_len):
            for column in range(0, x_len):
                if lines[line][column] == WALL:
                    walls.append(f"(wall x{column+1} y{line+1})")
                elif lines[line][column] == PLAYER:
                    player = f"(at {player_name} x{column+1} y{line+1})"
                elif lines[line][column] == TREASURE:
                    goal = f"(at {player_name} x{column+1} y{line+1})"
                elif lines[line][column] == MONSTER:
                    enemy = f"(at enemy x{column+1} y{line+1})"
                    has_enemy = True
        if has_enemy:
            enemy = f"{enemy} (is-enemy enemy) (has-enemy)"

    output_data = f"""(define (problem bomberdaproblem)
        (:domain bomberda)
        (:objects {" ".join(positions)} - position
                    {player_name} enemy - agent
                    t0 t1 t2 t3 - timer)
        (:init 
            {" ".join(walls)}
            {inc_x}
            {inc_y}
            {dec_x}
            {dec_y}
            {player}
            {enemy}
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

def main():
    generate_problem(sys.argv[1])


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <map_filepath>")
        print("Error: map path must be specified")
        exit(1)
    main()
