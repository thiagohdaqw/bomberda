(define (problem bomberdaproblem)
        (:domain bomberda)
        (:objects x1 x2 x3 x4 x5 x6 y1 y2 y3 - position
                    bomberman - agent)
        (:init 
            (wall x1 y1) (wall x2 y1) (wall x3 y1) (wall x4 y1) (wall x5 y1) (wall x6 y1) (wall x1 y2) (wall x6 y2) (wall x1 y3) (wall x4 y3) (wall x5 y3) (wall x6 y3)
            (inc x1 x2) (inc x2 x3) (inc x3 x4) (inc x4 x5) (inc x5 x6)
            (inc y1 y2) (inc y2 y3)
            (dec x6 x5) (dec x5 x4) (dec x4 x3) (dec x3 x2) (dec x2 x1)
            (dec y3 y2) (dec y2 y1)
            (at bomberman x2 y3)
        )
        (:goal
            (at bomberman x5 y2)
        )
    )
    