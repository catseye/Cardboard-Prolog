(define (foldl fun acc list)
  (if (null? list) acc (foldl fun (fun (car list) acc) (cdr list))))

(define (ground? t)
  (or (null? t) (symbol? t)))

(define (variable? v)
  (vector? v))

(define (rename-variable v n)
  (vector (vector-ref v 0) n))

(define (rename-term term n)
  (cond
    ((ground? term)
      term)
    ((variable? term)
      (rename-variable term n))
    (else
      (map (lambda (t) (rename-term t n)) term))))

(define (collect-vars term acc)
  (cond
    ((ground? term)
      acc)
    ((variable? term)
      (cons term acc))
    (else
      (foldl (lambda (t inner-acc) (collect-vars t inner-acc)) acc term))))

(define (match-var var pattern env)
  (if (equal? var pattern)
    env
    (let* ( (binding (assoc var env)) )
      (cond
        (binding
          (unify (cadr binding) pattern env))
        (else
          (cons (list var pattern) env))))))

(define (unify p1 p2 env)
  (cond
    ((equal? env #f)
      #f)
    ((variable? p1)
      (match-var p1 p2 env))
    ((variable? p2)
      (match-var p2 p1 env))
    ((or (ground? p1) (ground? p2))
      (if (equal? p1 p2)
        env
        #f))
    (else
      (let* ( (head-env (unify (car p1) (car p2) env))
              (tail-env (unify (cdr p1) (cdr p2) head-env)) )
        tail-env))))

(define (expand term env)
  (if (null? env)
    term
    (let* ( (binding     (car env))
            (var         (car binding))
            (bound-to    (cadr binding)) )
      (expand (subst var bound-to term) (cdr env)))))

(define (subst var replacement term)
  (cond
    ((ground? term)
      term)
    ((variable? term)
      (if (equal? term var) replacement term))
    (else
      (map (lambda (t) (subst var replacement t)) term))))

(define (expand-binding binding env)
  (cons (car binding) (expand (cdr binding) env)))

(define (expand-env e env)
  (map (lambda (binding) (expand-binding binding env)) e))

(define (collapse-env env)
  (let* ( (new-env (expand-env env env)) )
    (if (equal? env new-env)
      new-env
      (collapse-env new-env))))

(define (restrict-to-vars env vars)
  (if (null? env)
    env
    (let* ( (binding (car env)) )
      (if (member (car binding) vars)
        (cons binding (restrict-to-vars (cdr env) vars))
        (restrict-to-vars (cdr env) vars)))))

(define (search database goals env depth)
  (if (null? goals)
    (list env)
    (foldl (lambda (clause acc)
             (let* ( (fresh-clause (rename-term clause depth))
                     (head (car fresh-clause))
                     (body (cdr fresh-clause))
                     (unifier (unify (car goals) head env)) )
               (if unifier
                 (let* ( (expanded-goals (map (lambda (g) (expand g unifier)) (cdr goals)))
                         (expanded-body (map (lambda (t) (expand t unifier)) body))
                         (new-goals (append expanded-body expanded-goals))
                         (new-acc (append acc (search database new-goals unifier (+ 1 depth)))) )
                   new-acc)
                 acc))) '() database)))

(define (match-all database goals)
  (let* ( (toplevel-vars (collect-vars goals '()))
          (unifiers      (search database goals '() 1))
          (results       (map (lambda (u) (collapse-env u)) unifiers)) )
    (map (lambda (u) (restrict-to-vars u toplevel-vars)) results)))
