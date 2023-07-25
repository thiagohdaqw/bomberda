
            (define (problem bomberdaproblem)
                (:domain bomberda)
                (:objects x1 x2 x3 x4 x5 x6 x7 x8 x9 y1 y2 y3 y4 y5 - position
                            t0 t1 t2 t3 - timer)
                (:init 
                    (wall x1 y1) (wall x2 y1) (wall x3 y1) (wall x1 y2) (wall x3 y2) (wall x1 y3) (wall x3 y3) (wall x4 y3) (wall x5 y3) (wall x6 y3) (wall x7 y3) (wall x8 y3) (wall x9 y3) (wall x1 y4) (wall x9 y4) (wall x1 y5) (wall x2 y5) (wall x3 y5) (wall x4 y5) (wall x5 y5) (wall x6 y5) (wall x7 y5) (wall x8 y5) (wall x9 y5)
                    (inc x1 x2) (inc x2 x3) (inc x3 x4) (inc x4 x5) (inc x5 x6) (inc x6 x7) (inc x7 x8) (inc x8 x9)
                    (inc y1 y2) (inc y2 y3) (inc y3 y4) (inc y4 y5)
                    (dec x9 x8) (dec x8 x7) (dec x7 x6) (dec x6 x5) (dec x5 x4) (dec x4 x3) (dec x3 x2) (dec x2 x1)
                    (dec y5 y4) (dec y4 y3) (dec y3 y2) (dec y2 y1)
                    (player-at x2 y4)
                    
                    (has-treasure)
                    (box x4 y4) (box x5 y4) (box x6 y4) (box x7 y4)
                    
                    (has-box)
                    (is-zero-timer t0) (is-max-timer t3)
                    (dec-timer t3 t2) (dec-timer t2 t1) (dec-timer t1 t0)
                )
                (:goal
                    (and
                        (not (is-dead))
                        (not (has-action))
                        (player-at x8 y4)
                    )
                )
            )
            