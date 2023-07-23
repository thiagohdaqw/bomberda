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
        (box ?x ?y - position)
        (unstable-floor ?x ?y - position)
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

    ; (:action EXPLODIR_BOMBA
    ;     :parameters (?t ?n - timer)
    ;     :precondition (and (check-bomb) (has-bomb) (current-bomb-timer ?t) (dec-timer ?t ?n) (is-zero-timer ?n))
    ;     :effect (and 
    ;                 ; (not (bomb-at ?bx ?by))
    ;                 (not (check-bomb))
    ;                 (not (has-bomb))
    ;                 (check-end-turn)
    ;                 (not (current-bomb-timer ?t))
    ;                 (forall (?x ?y ?w - position) 
    ;                     (and
    ;                         (when
    ;                             (bomb-at ?x ?y)
    ;                             (not (bomb-at ?x ?y))
    ;                         )
    ;                         (when ; enemy
    ;                             (and
    ;                                 (bomb-at ?x ?y)
    ;                                 (or 
    ;                                     (enemy-at ?x ?w)
    ;                                     (enemy-at ?w ?y)
    ;                                     (enemy-at ?x ?y)
    ;                                 )
    ;                                 (or
    ;                                     (inc ?x ?w)
    ;                                     (inc ?y ?w)
    ;                                     (dec ?x ?w)
    ;                                     (dec ?y ?w)
    ;                                 )    
    ;                             ) 
    ;                             (not (has-enemy))
    ;                         )
    ;                         (when ; player
    ;                             (and
    ;                                 (bomb-at ?x ?y)
    ;                                 (or 
    ;                                     (player-at ?x ?w)
    ;                                     (player-at ?w ?y)
    ;                                     (player-at ?x ?y)
    ;                                 )
    ;                                 (or
    ;                                     (inc ?x ?w)
    ;                                     (inc ?y ?w)
    ;                                     (dec ?x ?w)
    ;                                     (dec ?y ?w)
    ;                                 )    
    ;                             ) 
    ;                             (is-dead)
    ;                         )
    ;                         (when ; box
    ;                             (and 
    ;                                 (bomb-at ?x ?y)
    ;                                 (or
    ;                                     (box ?x ?w)
    ;                                     (box ?w ?y)
    ;                                 )
    ;                                 (or
    ;                                     (inc ?x ?w)
    ;                                     (inc ?y ?w)
    ;                                     (dec ?x ?w)
    ;                                     (dec ?y ?w)
    ;                                 )
    ;                             )
    ;                             (and
    ;                                 (not (box ?x ?w))
    ;                                 (not (box ?w ?y))
    ;                             )
    ;                         )
    ;                         (when ; unstable floor
    ;                             (and
    ;                                 (bomb-at ?x ?y)
    ;                                 (unstable-floor ?x ?y)
    ;                             )
    ;                             (and
    ;                                 (not (unstable-floor ?x ?y))
    ;                                 (wall ?x ?y)
    ;                             )    
    ;                         )
    ;                         (when ; unstable floor
    ;                             (and
    ;                                 (bomb-at ?x ?y)
    ;                                 (unstable-floor ?x ?w)
    ;                                 (or
    ;                                     (inc ?x ?w)
    ;                                     (dec ?x ?w)
    ;                                 )
    ;                             )
    ;                             (and
    ;                                 (not (unstable-floor ?x ?w))
    ;                                 (wall ?x ?w)
    ;                             )
    ;                         )
    ;                         (when ;  unstable floor
    ;                             (and
    ;                                 (bomb-at ?x ?y)
    ;                                 (unstable-floor ?w ?y)
    ;                                 (or
    ;                                     (inc ?y ?w)
    ;                                     (dec ?y ?w)
    ;                                 )
    ;                             )
    ;                             (and
    ;                                 (not (unstable-floor ?w ?y))
    ;                                 (wall ?w ?y)
    ;                             )
    ;                         )
    ;                     )
    ;                 )
    ;             )
    ; )
    
    (:action EXPLODIR_BOMBA
        :parameters (?t ?n - timer ?x ?y - position)
        :precondition (and (bomb-at ?x ?y) (check-bomb) (has-bomb) (current-bomb-timer ?t) (dec-timer ?t ?n) (is-zero-timer ?n))
        :effect (and 
            (not (check-bomb))
            (not (has-bomb))
            (check-end-turn)
            (not (current-bomb-timer ?t))
            (not (bomb-at ?x ?y))
            (forall (?w - position) 
                (when
                    (or
                        (inc ?x ?w)
                        (inc ?y ?w)
                        (dec ?x ?w)
                        (dec ?y ?w)
                    )
                    (and
                        (when ; enemy
                            (or
                                (enemy-at ?x ?w)
                                (enemy-at ?w ?y)
                                (enemy-at ?x ?y)
                            )
                            (not (has-enemy))
                        )
                        (when ; player
                            (or
                                (player-at ?x ?w)
                                (player-at ?w ?y)
                                (player-at ?x ?y)
                            )
                            (is-dead)
                        )
                        (when ; box
                            (or
                                (box ?x ?w)
                                (box ?w ?y)
                            )
                            (and
                                (not (box ?x ?w))
                                (not (box ?w ?y))
                            )
                        )
                        (when ; unstable floor
                            (unstable-floor ?x ?y)
                            (and
                                (not (unstable-floor ?x ?y))
                                (wall ?x ?y)
                            )
                        )
                        (when ; unstable floor
                            (unstable-floor ?x ?w)
                            (and
                                (not (unstable-floor ?x ?w))
                                (wall ?x ?w)
                            )
                        )
                        (when ;  unstable floor
                            (unstable-floor ?w ?y)    
                            (and
                                (not (unstable-floor ?w ?y))
                                (wall ?w ?y)
                            )
                        )
                    )
                )
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
        :parameters (?x ?y ?yn - position)
        :precondition (and 
            (not (has-action))
            (player-at ?x ?y)
            (dec ?y ?yn)
        )
        :effect (and
            (when 
                (and
                    (not (wall ?x ?yn))
                    (not (box ?x ?yn))
                )
                (and
                    (not (player-at ?x ?y))
                    (player-at ?x ?yn)
                    (enemy-down)
                    (has-action)
                    (check-is-dead)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
        )
    )

    (:action BAIXO
        :parameters (?x ?y ?yn - position)
        :precondition (and 
            (not (has-action))
            (player-at ?x ?y)
            (inc ?y ?yn)
        )
        :effect (and
            (when 
                (and
                    (not (wall ?x ?yn))
                    (not (box ?x ?yn))
                )
                (and
                    (not (player-at ?x ?y))
                    (player-at ?x ?yn)
                    (enemy-up)
                    (has-action)
                    (check-is-dead)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
        )
    )

    (:action DIREITA
        :parameters (?x ?y ?xn - position)
        :precondition (and
            (not (has-action))
            (player-at ?x ?y)
            (inc ?x ?xn)
        )
        :effect (and
            (when
                (and
                    (not (wall ?xn ?y))
                    (not (box ?xn ?y))
                )
                (and
                    (not (player-at ?x ?y))
                    (player-at ?xn ?y)
                    (enemy-left)
                    (has-action)
                    (check-is-dead)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
        )
    )

    (:action ESQUERDA
        :parameters (?x ?y ?xn - position)
        :precondition (and
            (not (has-action))
            (player-at ?x ?y)
            (dec ?x ?xn)
        )
        :effect (and
            (when
                (and
                    (not (wall ?xn ?y))
                    (not (box ?xn ?y))
                )
                (and
                    (not (player-at ?x ?y))
                    (player-at ?xn ?y)
                    (enemy-right)
                    (has-action)
                    (check-is-dead)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
        )
    )
    
    (:action INIMIGO_DIREITA
        :parameters (?x ?y ?xn - position)
        :precondition (and 
            (enemy-at ?x ?y)
            (enemy-move)
            (enemy-right)
            (inc ?x ?xn)
        )
        :effect (and
            (when
                (and
                    (not (wall ?xn ?y))
                    (not (box ?xn ?y))
                )
                (and
                    (not (enemy-at ?x ?y))
                    (enemy-at ?xn ?y)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
            (not (enemy-move))
            (not (enemy-right))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_ESQUERDA
        :parameters (?x ?y ?xn - position)
        :precondition (and 
            (enemy-at ?x ?y)
            (enemy-move)
            (enemy-left)
            (dec ?x ?xn)
        )
        :effect (and
            (when
                (and
                    (not (wall ?xn ?y))
                    (not (box ?xn ?y))
                )
                (and
                    (not (enemy-at ?x ?y))
                    (enemy-at ?xn ?y)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
            (not (enemy-move))
            (not (enemy-left))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_CIMA
        :parameters (?x ?y ?yn - position)
        :precondition (and 
            (enemy-at ?x ?y)
            (enemy-move)
            (enemy-up)
            (dec ?y ?yn)
        )
        :effect (and
            (when
                (and
                    (not (wall ?x ?yn))
                    (not (box ?x ?yn))
                )
                (and
                    (not (enemy-at ?x ?y))
                    (enemy-at ?x ?yn)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
            (not (enemy-move))
            (not (enemy-up))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_BAIXO
        :parameters (?x ?y ?yn - position)
        :precondition (and 
            (enemy-at ?x ?y)
            (enemy-move)
            (enemy-down)
            (inc ?y ?yn)
        )
        :effect (and
            (when
                (and
                    (not (wall ?x ?yn))
                    (not (box ?x ?yn))
                )
                (and
                    (not (enemy-at ?x ?y))
                    (enemy-at ?x ?yn)
                )
            )
            (when
                (unstable-floor ?x ?y)
                (and
                    (not (unstable-floor ?x ?y))
                    (wall ?x ?y)
                )
            )
            (not (enemy-move))
            (not (enemy-down))
            (check-is-dead)
            (check-from-enemy)
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
)