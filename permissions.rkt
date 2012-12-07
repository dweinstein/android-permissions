#lang racket

(define-struct platform (version api-level version-code) #:transparent)

(define platforms
  ;; simple-name               platform-version       api-level version-code
  '((jellybean_mr1             "Android 4.2"                 17 "JELLY_BEAN_MR1")
    (jellybean                 "Android 4.1, 4.1.1"          16 "JELLY_BEAN")
    (jb                        "Android 4.1, 4.1.1"          16 "JELLY_BEAN")
    (icecreamsandwhich_mr1     "Android 4.0.3, 4.0.4"        15 "ICE_CREAM_SANDWHICH_MR1")
    (icecreamsandwhich         "Android 4.0, 4.0.1, 4.0.2"   14 "ICE_CREAM_SANDWHICH")
    (ics                       "Android 4.0, 4.0.1, 4.0.2"   14 "ICE_CREAM_SANDWHICH")
    (honeycomb_mr2             "Android 3.2"                 13 "HONEYCOMB_MR2")
    (honeycomb_mr1             "Android 3.1.X"               12 "HONEYCOMB_MR1")
    (honeycomb                 "Android 3.0.X"               11 "HONEYCOMB")
    (gingerbread_mr1           "Android 2.3.4, 2.3.3"        10 "GINGERBREAD_MR1")
    (gingerbread               "Android 2.3.2, 2.3.1, 2.3"    9 "GINGERBREAD")
    (froyo                     "Android 2.2.X"                8 "FROYO")
    (eclair_mr1                "Android 2.1.X"                7 "ECLAIR_MR1")
    (eclair_0_1                "Android 2.0.1"                6 "ECLAIR_0_1")
    (eclair                    "Android 2.0"                  5 "ECLAIR")
    (donut                     "Android 1.6"                  4 "DONUT")
    (cupcake                   "Android 1.5"                  3 "CUPCAKE")    
    (base_1_1                  "Android 1.1"                  2 "BASE_1_1")
    (base                      "Android 1.0"                  1 "BASE")    
     ))

(define (platform-for-version str)
  (apply make-platform (cdr (assoc (string->symbol str) platforms))))

    
(define mappings
  '((froyo        "froyo_allmappings")
    (gingerbread  "gingerbread_allmappings")
    (honeycomb    "honeycomb_allmappings")
    (ics          "ics_allmappings")
    (jellybean    "jellybean_allmappings")))


(define (get-path-for-version version)
  (let ([version (cond [(string? version)
                        (string->symbol version)]
                       [else version])])
    (build-path (current-directory) "PScout" "results" (cadr (assoc version mappings)))))

(define (platform->permission-map version)
  (let-values ([(permissions perm->api api->perm)
                (read-mappings/slurp (get-path-for-version version))])
    (make-permission-map permissions perm->api api->perm #f)))

                
; (or/c path? string?) -> (values list? hash? hash?)
(define (read-mappings/slurp file)
    (for/fold ([perms empty]
               [map/perm->api (hash)]  ; for looking up apis associated with a permission
               [map/api->perm (hash)]) ; for looking up permissions associated with api
      
      ; for each line in the file
      [(line (file->lines file))]
      
      (let-values ([(type thing) (handle-line line)])
        (match type
          ['permission-heading (let ([the-permission thing])
                                 ;; (printf "~a:~n" the-permission)
                                 (values (cons the-permission perms)
                                         map/perm->api
                                         map/api->perm))]
          
          ['method (let ([current-permission (car perms)]
                         [the-method thing])
                     ;; (printf "\t~a~n" the-method)
                     (values perms
                             (update-hash-map map/perm->api
                                              current-permission
                                              the-method)
                             (update-hash-map map/api->perm
                                              the-method
                                              current-permission)))]
          
          [else (values perms
                        map/perm->api
                        map/api->perm)]))))

(define (handle-line line)
  (match line
    [(regexp #rx"Permission:(.*)" (list _ permission))
     (values 'permission-heading permission)]
    
    [(regexp #rx"<(.*): (.*) (.*)>.*" (list _ pkg/base ret-val methd-name))
     (values 'method (string->symbol (format "~a ~a.~a" ret-val pkg/base methd-name)))]
    
    [_ (values #f #f)]))

(define (update-hash-map hash k v)
  (hash-update hash
               k
               (curry cons v)
               empty))

(define (read-mappings file)
  (read-mappings/slurp file))

(define-struct permission-exp (name))
(define-struct method-exp (return-type class name parameter-list body))
(define-struct permission-map (permissions hash-map/perm->api hash-map/api->perm methods))

(define (lookup/perm->apis permission-map
                           permission-string)
  (let ([results (hash-ref (permission-map-hash-map/perm->api permission-map)
                           permission-string
                           empty)])
    (and (not (empty? results))
         (map symbol->string results))))


;; finish me! case-insensitive-regexp ~> #rx"(?i:abc)d" <-> ("aBcd", "abcd", ...)
;;
(define (lookup-permission/re permission-map
                              astring
                              #:case-insensitive (case-insensitive-p #t))
  (let* ([permissions (permission-map-permissions permission-map)]
         [re-str (format "(?~a:.*~a.*)" (if case-insensitive-p
                                            "i"
                                            "")
                         astring)]
         [re (regexp re-str)])
    
    (for/fold ([matches-accum empty]) ([perm permissions])
      (let ([matches (regexp-match re perm)])
        (if matches
            (values (cons perm matches-accum))
            (values matches-accum))))))

;; Definition: Two of the components of a method declaration comprise the method signature:
;;             the method's name and the parameter types.
;; http://docs.oracle.com/javase/tutorial/java/javaOO/methods.html
(define normalize-method-signature
  (lambda (method-string)
    #f))

(define pmap
  (let-values ([(permissions hash-map/perm->api hash-map/api->perm) 
                (read-mappings/slurp "./PScout/results/froyo_allmappings")])
  (make-permission-map 
                permissions 
                hash-map/perm->api 
                hash-map/api->perm
                #f)))
