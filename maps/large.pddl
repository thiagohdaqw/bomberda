(define (problem bomberdaproblem)
        (:domain bomberda)
        (:objects x1 x2 x3 x4 x5 y1 y2 y3 y4 y5 y6 y7 y8 y9 - position
                    bomberman enemy - agent)
        (:init 
            (wall x1 y1) (wall x5 y1) (wall x1 y2) (wall x5 y2) (wall x1 y3) (wall x5 y3) (wall x1 y4) (wall x2 y4) (wall x3 y4) (wall x5 y4) (wall x1 y5) (wall x5 y5) (wall x1 y6) (wall x3 y6) (wall x5 y6) (wall x1 y7) (wall x5 y7) (wall x1 y8) (wall x5 y8) (wall x1 y9) (wall x5 y9)
            (inc x1 x2) (inc x2 x3) (inc x3 x4) (inc x4 x5)
            (inc y1 y2) (inc y2 y3) (inc y3 y4) (inc y4 y5) (inc y5 y6) (inc y6 y7) (inc y7 y8) (inc y8 y9)
            (dec x5 x4) (dec x4 x3) (dec x3 x2) (dec x2 x1)
            (dec y9 y8) (dec y8 y7) (dec y7 y6) (dec y6 y5) (dec y5 y4) (dec y4 y3) (dec y3 y2) (dec y2 y1)
            (at bomberman x3 y9)
            (at enemy x3 y1) (is-enemy enemy) (has-enemy)
        )
        (:goal
            (and
                (not (is-dead))
                (not (has-action))
                (at bomberman x3 y3)
            )
        )
    )
    