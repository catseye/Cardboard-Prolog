(load "cardboard-prolog.scm")
(load "utils.scm")

(define database
  '(
      ((female alice))
      ((male bob))
      ((male dan))
      ((female emily))
      ((female fran))
      ((child alice bob))
      ((child dan bob))
      ((child emily dan))
      ((son #(X) #(Y)) (male #(X)) (child #(X) #(Y)))
      ((daughter #(X) #(Y)) (female #(X)) (child #(X) #(Y)))
      ((descendant #(X) #(Y)) (child #(X) #(Y)))
      ((descendant #(X) #(Y)) (child #(X) #(Z)) (descendant #(Z) #(Y)))
   )
)

;-----------

(test rename-term-1
  (rename-term '(descendant #(X) #(Y)) 1)
  '(descendant #(X 1) #(Y 1))
)

(test rename-term-2
  (rename-term '(descendant #(X 1) #(Y 1)) 2)
  '(descendant #(X 2) #(Y 2))
)

(test collect-vars-1
  (collect-vars '(descendant (son #(X)) #(Y)) '())
  '(#(Y) #(X))
)

;------------

(test unify-1
  (unify '(child bob #(Y)) '(child #(X) alice) '())
  '( (#(Y) alice) (#(X) bob) )
)

(test unify-2
  (unify '(son #(X) zeke) '(son #(X) #(Y)) '())
  '( (#(Y) zeke) )
)

(test unify-3
  (unify '(son #(P) zeke) '(son #(X) #(Y)) '())
  '( (#(Y) zeke) (#(P) #(X)) )
)

;------------

(test expand-1
  (expand '(child #(X) #(Y)) '( (#(Y) alice) (#(X) bob) ))
  '(child bob alice)
)

;------------

(test match-all-1
  (match-all database '( (female alice) ))
  '(())    ; list containing empty env ==> true
)

(test match-all-2
  (match-all database '( (female foobar) ))
  '()      ; list containing no envs ==> false
)

(test match-all-3
  (match-all database '( (female #(A)) ))
  '(((#(A) alice)) ((#(A) emily)) ((#(A) fran)))
)

(test match-all-4
  (match-all database '( (child dan bob) ))
  '(())
)

(test match-all-5
  (match-all database '( (child #(A) bob) ))
  '(((#(A) alice)) ((#(A) dan)))
)

(test match-all-6
  (match-all database '( (female #(A)) (child #(A) bob) ))
  '(((#(A) alice)))
)

(test match-all-7
  (match-all database '( (female #(A)) (child #(A) #(B)) ))
  '(((#(B) bob) (#(A) alice)) ((#(B) dan) (#(A) emily)))
)

(test match-all-son-1
  (match-all database '( (son dan bob) ))
  '(())
)

(test match-all-son-2
  (match-all database '( (son dan emily) ))
  '()
)

(test match-all-son-3
  (match-all database '( (son alice bob) ))
  '()
)

(test match-all-son-3a
  (match-all database '( (son #(X) bob) ))
  '(((#(X) dan)))
)

(test match-all-son-3b
  (match-all database '( (son #(P) bob) ))
  '(((#(P) dan)))
)

(test match-all-son-4
  (match-all database '( (son dan #(X)) ))
  '(((#(X) bob)))
)

(test match-all-son-4a
  (match-all database '( (son dan #(P)) ))
  '(((#(P) bob)))
)

(test match-all-son-5
  (match-all database '( (son #(X) #(Y)) ))
  '(((#(Y) bob) (#(X) dan)))
)

(test match-all-son-5a
  (match-all database '( (son #(P) #(Q)) ))
  '(((#(Q) bob) (#(P) dan)))
)

(test match-all-descendant-1
  (match-all database '( (descendant alice bob) ))
  '(())
)

(test match-all-descendant-2
  (match-all database '( (descendant alice emily) ))
  '()
)

(test match-all-descendant-3
  (match-all database '( (descendant emily bob) ))
  '(())
)

(test match-all-descendant-4
  (match-all database '( (descendant #(X) bob) ))
  '(((#(X) alice)) ((#(X) dan)) ((#(X) emily)))
)

(test match-all-descendant-5
  (match-all database '( (descendant emily #(X)) ))
  '(((#(X) dan)) ((#(X) bob)))
)
