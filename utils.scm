(define-syntax print
  (syntax-rules ()
    ((print e)
      (display e))
    ((print e1 e2 ...)
      (begin (display e1)
             (print e2 ...)))))

(define-syntax println
  (syntax-rules ()
    ((println e)
      (begin (display e)
             (newline)))
    ((println e1 e2 ...)
      (begin (display e1)
             (println e2 ...)))))

(define-syntax test
  (syntax-rules ()
    ((test test-name expr expected)
      (begin
        (print "Running test: " (quote test-name) "... ")
        (let ((result expr))
          (cond
            ((equal? result expected)
              (println "passed."))
            (else
              (println "FAILED!")
              (println "Expected: " expected)
              (println "Actual:   " result))))))))
