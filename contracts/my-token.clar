;; super-token.clar
;; An advanced fungible token with admin control, approvals, and staking.

;; -------------------------
;; Constants & error codes
;; -------------------------
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_INSUFFICIENT_BALANCE u101)
(define-constant ERR_INVALID_AMOUNT u102)
(define-constant ERR_NOT_APPROVED u103)
(define-constant ERR_ALREADY_STAKED u104)
(define-constant ERR_NOT_STAKED u105)

;; -------------------------
;; State variables
;; -------------------------
(define-data-var owner (optional principal) none)
(define-data-var total-supply uint u0)
(define-map balances {user: principal} uint)
(define-map allowances {owner: principal, spender: principal} uint)
(define-map staked-balances {user: principal} uint)
(define-data-var total-staked uint u0)

;; Note: events are not available in this Clarity/clarinet configuration.
;; Emitting events has been removed to keep the contract compatible.

;; -------------------------
;; Internal helpers
;; -------------------------
(define-private (only-owner)
  (match (var-get owner) o
    (if (is-eq tx-sender o) (ok true) (err ERR_UNAUTHORIZED))
    (err ERR_UNAUTHORIZED)))

;; -------------------------
;; Token core functions
;; -------------------------

;; Mint new tokens (owner only)
 (define-public (mint (to principal) (amount uint))
  (match (only-owner) v
    (if (> amount u0)
      (begin
        (map-set balances {user: to} (+ (default-to u0 (map-get? balances {user: to})) amount))
        (var-set total-supply (+ (var-get total-supply) amount))
        (ok amount))
      (err ERR_INVALID_AMOUNT))
    e (err e)))

;; Burn tokens (any user)
(define-public (burn (amount uint))
  (let ((bal (default-to u0 (map-get? balances {user: tx-sender}))))
    (if (and (> amount u0) (>= bal amount))
        (begin
          (map-set balances {user: tx-sender} (- bal amount))
          (var-set total-supply (- (var-get total-supply) amount))
          (ok amount))
        (err ERR_INSUFFICIENT_BALANCE)))
)

;; Transfer tokens directly
(define-public (transfer (recipient principal) (amount uint))
    (let ((sender-bal (default-to u0 (map-get? balances {user: tx-sender}))))
    (if (and (> amount u0) (>= sender-bal amount))
        (begin
          (map-set balances {user: tx-sender} (- sender-bal amount))
          (map-set balances {user: recipient} (+ (default-to u0 (map-get? balances {user: recipient})) amount))
          (ok true))
        (err ERR_INSUFFICIENT_BALANCE)))
)

;; -------------------------
;; Approvals (like ERC-20)
;; -------------------------

;; Approve another address to spend tokens
(define-public (approve (spender principal) (amount uint))
  (begin
    (map-set allowances {owner: tx-sender, spender: spender} amount)
    (ok amount)))

;; Transfer from another account (requires approval)
(define-public (transfer-from (from principal) (to principal) (amount uint))
        (let (
        (allowance (default-to u0 (map-get? allowances {owner: from, spender: tx-sender})))
        (from-bal (default-to u0 (map-get? balances {user: from})))
       )
    (if (and (>= allowance amount) (>= from-bal amount))
        (begin
          (map-set balances {user: from} (- from-bal amount))
          (map-set balances {user: to} (+ (default-to u0 (map-get? balances {user: to})) amount))
          (map-set allowances {owner: from, spender: tx-sender} (- allowance amount))
          (ok true))
        (err ERR_NOT_APPROVED)))
)

;; -------------------------
;; Staking system
;; -------------------------

;; Stake your tokens (locks them)
(define-public (stake (amount uint))
  (let ((bal (default-to u0 (map-get? balances {user: tx-sender})))
        (staked (default-to u0 (map-get? staked-balances {user: tx-sender}))))
    (if (and (> amount u0) (>= bal amount))
        (begin
          (map-set balances {user: tx-sender} (- bal amount))
          (map-set staked-balances {user: tx-sender} (+ staked amount))
          (var-set total-staked (+ (var-get total-staked) amount))
          (ok amount))
        (err ERR_INSUFFICIENT_BALANCE)))
)

;; Unstake your tokens
(define-public (unstake (amount uint))
  (let ((staked (default-to u0 (map-get? staked-balances {user: tx-sender}))))
    (if (and (> amount u0) (>= staked amount))
        (begin
          (map-set staked-balances {user: tx-sender} (- staked amount))
          (map-set balances {user: tx-sender} (+ (default-to u0 (map-get? balances {user: tx-sender})) amount))
          (var-set total-staked (- (var-get total-staked) amount))
          (ok amount))
        (err ERR_NOT_STAKED)))
)

;; -------------------------
;; Read-only functions
;; -------------------------
(define-read-only (get-balance (user principal))
  (default-to u0 (map-get? balances {user: user}))
)

(define-read-only (get-allowance (owner-addr principal) (spender-addr principal))
  (default-to u0 (map-get? allowances {owner: owner-addr, spender: spender-addr}))
)

(define-read-only (get-staked-balance (user principal))
  (default-to u0 (map-get? staked-balances {user: user}))
)

(define-read-only (get-total-staked)
  (var-get total-staked)
)

(define-read-only (get-total-supply)
  (var-get total-supply)
)

(define-read-only (get-owner)
  (var-get owner)
)
