import sys
import time
from typing import List, Tuple

ACTION_DELAY_SECONDS = 0.5

SAVE_ANIMATION = True
ANIMATION_FILE = "simulation_animation"

SIMULATION_FILE = "simulation.out"

CONSOLE_START_X = 10
CONSOLE_START_Y = int(CONSOLE_START_X / 2)

PLAYER = "@"
ENEMY = "E"
BOMB = "B"
FLOORS = [FLOOR := " ", FRAGILE_FLOOR := "x", TREASURE := "."]
Position = Tuple[int, int]

ADJS = [(0,1),(0,-1),(1,0),(-1,0)]
get_adjs = lambda p: map(lambda x: (p[0] + x[0], p[1] + x[1]), ADJS)

ACTIONS = [
    A_UP := "CIMA",
    A_DOWN := "BAIXO",
    A_LEFT := "ESQUERDA",
    A_RIGHT := "DIREITA",
    A_SOLTAR_BOMBA := "SOLTARBOMBA",
    A_EXPLODIR_BOMBA := "EXPLODIR_BOMBA",
]


def print_char(x, y, char, offset_x=CONSOLE_START_X, offset_y=CONSOLE_START_Y):
    print("\033[" + str(y + offset_y) + ";" + str(x + offset_x) + "H" + char)


def init_console(width, height):
    print("\n"*50)
    for x in range(CONSOLE_START_X - 1, width + CONSOLE_START_X + 1):
        for y in range(CONSOLE_START_Y - 1, height + CONSOLE_START_Y + 1):
            print_char(x, y, '-', 0, 0)


class World:
    map_data: List[str]
    width: int
    height: int
    player: Position
    enemy: Position
    bomb: Position

    def __init__(self, map_filename) -> None:
        self.__init_map(map_filename)

    def index(self, x, y) -> int:
        return self.width * y + x

    def at(self, x, y) -> str:
        return self.map_data[self.index(x, y)]

    def draw(self):
        for x, y, obj in self:
            print_char(x, y, obj)

    def apply(self, action):
        player_x, player_y = self.player
        vel_x = vel_y = 0

        if action == A_UP:
            vel_y = -1
        elif action == A_DOWN:
            vel_y = 1
        elif action == A_LEFT:
            vel_x = -1
        elif action == A_RIGHT:
            vel_x = 1
        elif action == A_SOLTAR_BOMBA:
            self.bomb = self.player
        elif action == A_EXPLODIR_BOMBA:
            if self.enemy is not None and self.enemy in get_adjs(self.bomb):
                self.enemy = None
            self.bomb = None
        else:
            assert False, "Unreachable"

        if self.at(player_x + vel_x, player_y + vel_y) not in FLOORS:
            raise Exception(
                f"Invalid action: {action}. Excepted a {FLOORS} but found `{self.at(player_x, player_y)}` in position ({player_x}, {player_y})"
            )

        self.player = (player_x + vel_x, player_y + vel_y)

        if self.enemy is not None:
            enemy_x, enemy_y = self.enemy[0] - vel_x, self.enemy[1] - vel_y
            if 0 <= enemy_x < self.width and 0 <= enemy_y < self.height and self.at(enemy_x, enemy_y) in FLOORS:
                self.enemy = (enemy_x, enemy_y)


    def __iter__(self):
        for y in range(self.height):
            for x in range(self.width):
                if self.player == (x, y):
                    yield x, y, PLAYER
                elif self.enemy == (x, y):
                    yield x, y, ENEMY
                elif self.bomb == (x, y):
                    yield x, y, BOMB
                else:
                    yield x, y, self.at(x, y)

    def __init_map(self, filename):
        self.width = 0
        self.height = 0
        self.map_data = []
        self.enemy = None
        self.bomb = None
        with open(filename) as f:
            for line in f:
                if not self.width:
                    self.width = len(line) - 1
                index = 0
                for i, char in enumerate(line):
                    if char == "\n":
                        continue
                    if char == PLAYER:
                        self.player = (index, self.height)
                        self.map_data.append(" ")
                    elif char == ENEMY:
                        self.enemy = (index, self.height)
                        self.map_data.append(" ")
                    else:
                        self.map_data.append(char)
                    index += 1
                self.height += 1


def read_solution_actions(solution_path):
    is_action = lambda line: next(
        action for action in ACTIONS if line.startswith(action.lower())
    )
    with open(solution_path) as solution:
        for line in solution:
            try:
                if action := is_action(line):
                    yield action
            except StopIteration:
                continue


def save_world(file, world: World, index, action):
    print(index, "-", action, "=" * 40, file=file)
    current_line = 0

    for _, y, char in world:
        if y != current_line:
            current_line = y
            print(file=file)

        print(char, end="", file=file)
    print(file=file)

    save_animation(world)


def save_animation(world: World):
    current_line = 0
    with open(ANIMATION_FILE, "w") as file:
        for _, y, char in world:
            if y != current_line:
                current_line = y
                print(file=file)

            print(char, end="", file=file)
        print(file=file)


def main(map_path: str, solution_path):
    world = World(map_path)
    init_console(world.width, world.height)

    world.draw()

    with open(SIMULATION_FILE, "w") as simulation:
        save_world(simulation, world, 0, "Initial")
        for index, action in enumerate(read_solution_actions(solution_path)):
            time.sleep(ACTION_DELAY_SECONDS)
            world.apply(action)
            world.draw()
            save_world(simulation, world, index, action)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <map_path>")
        print("Error: the map filename must be specified")
        exit(1)
    main(sys.argv[1], sys.argv[1] + ".out")
