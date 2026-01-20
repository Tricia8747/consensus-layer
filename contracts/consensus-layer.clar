;; ------------------------------------------------------------
;; consensus-layer.clar
;; Governance consensus validation module
;; ------------------------------------------------------------

;; ------------------------------------------------------------
;; Error codes
;; ------------------------------------------------------------

(define-constant ERR-NOT-GOVERNANCE u100)
(define-constant ERR-ALREADY-INITIALIZED u101)
(define-constant ERR-INVALID u102)

;; ------------------------------------------------------------
;; Governance authority
;; ------------------------------------------------------------

(define-data-var governance (optional principal) none)

;; ------------------------------------------------------------
;; Consensus parameters
;;
;; approval-percent:
;;   minimum percentage of YES votes required (0-100)
;; ------------------------------------------------------------

(define-data-var approval-percent uint u0)

;; ------------------------------------------------------------
;; Initialization (one-time)
;; ------------------------------------------------------------

(define-public (initialize
  (gov-contract principal)
  (initial-approval uint)
)
  (let ((gc (if (is-eq gov-contract gov-contract) gov-contract gov-contract)))
    (begin
      (asserts! (is-none (var-get governance)) (err ERR-ALREADY-INITIALIZED))
      (asserts! (<= initial-approval u100) (err ERR-INVALID))
      (var-set governance (some gc))
      (var-set approval-percent initial-approval)
      (ok true)
    )
  )
)

;; ------------------------------------------------------------
;; Internal governance check
;; ------------------------------------------------------------

(define-private (is-governance)
  (match (var-get governance)
    g (is-eq g tx-sender)
    false
  )
)

;; ------------------------------------------------------------
;; Update approval threshold
;; ------------------------------------------------------------

(define-public (set-approval-percent (new-percent uint))
  (if (not (is-governance))
      (err ERR-NOT-GOVERNANCE)
      (if (> new-percent u100)
          (err ERR-INVALID)
          (begin
            (var-set approval-percent new-percent)
            (ok new-percent)
          )
      )
  )
)

;; ------------------------------------------------------------
;; Consensus validation
;;
;; quorum-passed: result from quorum-checker
;; yes-votes: number of YES votes
;; total-votes: total votes cast
;; ------------------------------------------------------------

(define-read-only (has-consensus
  (quorum-passed bool)
  (yes-votes uint)
  (total-votes uint)
)
  (if (not quorum-passed)
      (ok false)
      (let
        (
          (required (/ (* total-votes (var-get approval-percent)) u100))
        )
        (ok (>= yes-votes required))
      )
  )
)

;; ------------------------------------------------------------
;; Read-only helpers
;; ------------------------------------------------------------

(define-read-only (get-approval-percent)
  (ok (var-get approval-percent))
)

(define-read-only (get-governance)
  (var-get governance)
)
