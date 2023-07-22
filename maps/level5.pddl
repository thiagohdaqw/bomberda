(define (problem bomberdaproblem)
        (:domain bomberda)
        (:objects x1 x2 x3 x4 x5 y1 y2 y3 y4 y5 y6 y7 - position
                    t0 t1 t2 t3 - timer)
        (:init 
            (wall x1 y1) (wall x2 y1) (wall x3 y1) (wall x1 y2) (wall x3 y2) (wall x1 y3) (wall x3 y3) (wall x4 y3) (wall x5 y3) (wall x1 y4) (wall x3 y4) (wall x5 y4) (wall x1 y5) (wall x5 y5) (wall x1 y6) (wall x3 y6) (wall x4 y6) (wall x5 y6) (wall x1 y7) (wall x2 y7) (wall x3 y7)
            (inc x1 x2) (inc x2 x3) (inc x3 x4) (inc x4 x5)
            (inc y1 y2) (inc y2 y3) (inc y3 y4) (inc y4 y5) (inc y5 y6) (inc y6 y7)
            (dec x5 x4) (dec x4 x3) (dec x3 x2) (dec x2 x1)
            (dec y7 y6) (dec y6 y5) (dec y5 y4) (dec y4 y3) (dec y3 y2) (dec y2 y1)
            (player-at x2 y6)
            (enemy-at x2 y3) (is-enemy enemy) (has-enemy)
            (has-treasure)
            (is-zero-timer t0) (is-max-timer t3)
            (dec-timer t3 t2) (dec-timer t2 t1) (dec-timer t1 t0)
        )
        (:goal
            (and
                (not (is-dead))
                (not (has-action))
                (player-at x2 y2)
            )
        )
    )
    