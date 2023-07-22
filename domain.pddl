(define (domain bomberda)
    (:requirements :strips)
    (:types
        agent position timer
    )
    (:predicates
        (inc ?a ?b - position)
        (dec ?a ?b - position)
        (at ?a - agent ?x ?y - position)
        (wall ?x ?y)
        (is-enemy ?a)
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
    )

    (:action SOLTARBOMBA
        :parameters (?px ?py - position ?player - agent ?t - timer)
        :precondition (and (not (has-bomb)) (not (is-enemy ?player)) (at ?player ?px ?py) (is-max-timer ?t))
        :effect (and (bomb-at ?px ?py) (current-bomb-timer ?t) (has-bomb))
    )

    (:action PASSAR_TURNO_BOMBA
        :parameters ()
        :precondition (and (check-bomb) (not (has-bomb)))
        :effect (and (not (check-bomb)) (not (has-action)))
    )
    

    (:action DECREMENTAR_TIMER_BOMBA
        :parameters (?t ?n - timer)
        :precondition (and (check-bomb) (has-bomb) (current-bomb-timer ?t) (dec-timer ?t ?n) (not (is-zero-timer ?n)))
        :effect (and
                    (not (check-bomb))
                    (not (current-bomb-timer ?t))
                    (not (has-action))
                    (current-bomb-timer ?n)
                )
    )

    (:action EXPLODIR_BOMBA
        :parameters (?t ?n - timer ?player ?enemy - agent)
        :precondition (and (check-bomb) (has-bomb) (current-bomb-timer ?t) (dec-timer ?t ?n) (is-zero-timer ?n) (is-enemy ?enemy) (not (is-enemy ?player)))
        :effect (and 
                    (not (bomb-at ?bx ?by))
                    (not (check-bomb))
                    (not (has-bomb))
                    (not (has-action))
                    (not (current-bomb-timer ?t))
                    (forall (?x ?y ?w - position) 
                        (when
                            (and
                                (bomb-at ?x ?y)
                                (or 
                                    (at ?enemy ?x ?w)
                                    (at ?enemy ?w ?y)
                                    (at ?enemy ?x ?y)
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
                                    (at ?player ?x ?w)
                                    (at ?player ?w ?y)
                                    (at ?player ?x ?y)
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
        :parameters (?px ?py ?ex ?ey - position ?player ?enemy - agent)
        :precondition (and (has-enemy) (check-is-dead) (is-enemy ?enemy) (not (is-enemy ?player)) (at ?player ?px ?py) (at ?enemy ?ex ?ey))
        :effect (and
            (when
                (and (at ?player ?px ?py) (at ?enemy ?px ?py))
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
        :parameters (?player - agent)
        :precondition (and (not (has-action)) (not (is-enemy ?player)))
        :effect (forall
                    (?x ?y ?yn - position)
                    (when
                        (and (at ?player ?x ?y)
                            (dec ?y ?yn)
                            (not (wall ?x ?yn)))
                        (and (not (at ?player ?x ?y))
                            (at ?player ?x ?yn)
                            (enemy-down)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )

    (:action BAIXO
        :parameters (?player - agent)
        :precondition (and (not (has-action)) (not (is-enemy ?player)))
        :effect (forall
                    (?x ?y ?yn - position)
                    (when
                        (and (at ?player ?x ?y)
                            (inc ?y ?yn)
                            (not (wall ?x ?yn)))
                        (and (not (at ?player ?x ?y))
                            (at ?player ?x ?yn)
                            (enemy-up)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )

    (:action DIREITA
        :parameters (?player - agent)
        :precondition (and (not (has-action)) (not (is-enemy ?player)))
        :effect (forall
                    (?x ?y ?xn - position)
                    (when
                        (and (at ?player ?x ?y)
                            (inc ?x ?xn)
                            (not (wall ?xn ?y)))
                        (and (not (at ?player ?x ?y))
                            (at ?player ?xn ?y)
                            (enemy-left)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )

    (:action ESQUERDA
        :parameters (?player - agent)
        :precondition (and (not (has-action)) (not (is-enemy ?player)))
        :effect (forall
                    (?x ?y ?xn - position)
                    (when
                        (and (at ?player ?x ?y)
                            (dec ?x ?xn)
                            (not (wall ?xn ?y)))
                        (and (not (at ?player ?x ?y))
                            (at ?player ?xn ?y)
                            (enemy-right)
                            (has-action)
                            (check-is-dead))
                    )
                )
    )
    

    (:action INIMIGO_DIREITA
        :parameters (?enemy - agent)
        :precondition (and (enemy-move) (enemy-right) (is-enemy ?enemy))
        :effect (and
            (forall
                (?x ?y ?xn - position)
                (when
                    (and (at ?enemy ?x ?y)
                        (inc ?x ?xn)
                        (not (wall ?xn ?y)))
                    (and (not (at ?enemy ?x ?y))
                        (at ?enemy ?xn ?y))
                )
            )
            (not (enemy-move))
            (not (enemy-right))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_ESQUERDA
        :parameters (?enemy - agent)
        :precondition (and (enemy-move) (enemy-left) (is-enemy ?enemy))
        :effect (and
            (forall
                (?x ?y ?xn - position)
                (when
                    (and (at ?enemy ?x ?y)
                        (dec ?x ?xn)
                        (not (wall ?xn ?y)))
                    (and (not (at ?enemy ?x ?y))
                         (at ?enemy ?xn ?y))
                )
            )
            (not (enemy-move))
            (not (enemy-left))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_CIMA
        :parameters (?enemy - agent)
        :precondition (and (enemy-move) (enemy-up) (is-enemy ?enemy))
        :effect (and
            (forall
                (?x ?y ?yn - position)
                (when
                    (and (at ?enemy ?x ?y)
                        (dec ?y ?yn)
                        (not (wall ?x ?yn)))
                    (and (not (at ?enemy ?x ?y))
                        (at ?enemy ?x ?yn))
                )
            )
            (not (enemy-move))
            (not (enemy-up))
            (check-is-dead)
            (check-from-enemy)
        )
    )

    (:action INIMIGO_BAIXO
        :parameters (?enemy - agent)
        :precondition (and (enemy-move) (enemy-down) (is-enemy ?enemy))
        :effect (and
            (forall
                (?x ?y ?yn - position)
                (when
                    (and (at ?enemy ?x ?y)
                        (inc ?y ?yn)
                        (not (wall ?x ?yn)))
                    (and (not (at ?enemy ?x ?y))
                        (at ?enemy ?x ?yn))
                )
            )
            (not (enemy-move))
            (not (enemy-down))
            (check-is-dead)
            (check-from-enemy)
        )
    )
)