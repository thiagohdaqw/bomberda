(define (problem bomberdaproblem)
        (:domain bomberda)
        (:objects x1 x2 x3 x4 y1 y2 y3 y4 - position
                    bomberman - agent)
        (:init 
            (wall x3 y1)
            (inc x1 x2) (inc x2 x3) (inc x3 x4)
            (inc y1 y2) (inc y2 y3) (inc y3 y4)
            (dec x4 x3) (dec x3 x2) (dec x2 x1)
            (dec y4 y3) (dec y3 y2) (dec y2 y1)
            (at bomberman x1 y1)
        )
        (:goal
            (at bomberman x4 y1)
        )
    )
    