;; Title: StacksQuest: LootSurge Protocol
;; 
;; Summary: A Clarity smart contract powering Bitcoin-secured dungeon adventures with tokenized loot,
;; cooldown mechanics, and provably fair rewards on Stacks L2.
;;
;; Description: Revolutionizing blockchain gaming through Bitcoin-aligned design. This contract enables:
;; - Token-gated dungeon expeditions with STX-based entry fees
;; - BRC-20 compatible reward distributions
;; - Configurable cooldown periods enforced at the protocol level
;; - Immutable player progression tracking
;; - Secure ownership controls with two-step transfer verification
;; Built for enterprise-grade security and seamless interoperability with Bitcoin DeFi ecosystems.

;; TRAIT DEFINITION
(define-trait token-trait 
    (
        (get-balance (principal) (response uint uint))
        (transfer (principal principal uint) (response bool uint))
    )
)

;; CONSTANTS
(define-constant ERR-INSUFFICIENT-BALANCE (err u1))
(define-constant ERR-UNAUTHORIZED (err u2))
(define-constant ERR-INVALID-TOKEN (err u3))
(define-constant ERR-NOT-CONTRACT-OWNER (err u4))
(define-constant ERR-INVALID-PRINCIPAL (err u5))
(define-constant ERR-PENDING-OWNER-ONLY (err u6))
(define-constant ERR-DUNGEON-COOLDOWN (err u7))
(define-constant ENTRY-COST u100)
(define-constant REWARD_AMOUNT u200)
(define-constant DUNGEON_COOLDOWN_BLOCKS u100)

;; STATE VARIABLES
;; Contract ownership management
(define-data-var contract-owner principal tx-sender)
(define-data-var pending-owner (optional principal) none)
(define-data-var allowed-token principal 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.my-token)
(define-data-var ENTRY_COST uint u0)

;; Player dungeon tracking
(define-map player-dungeon-stats 
    { player: principal }
    {
        last-dungeon-block: uint,
        total-dungeons-completed: uint,
        total-rewards-earned: uint
    }
)

;; PRIVATE HELPER FUNCTIONS
(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner))
)

(define-private (is-valid-token (token <token-trait>))
    (is-eq (contract-of token) (var-get allowed-token))
)

(define-private (is-valid-principal (address principal))
    (and 
        (not (is-eq address (var-get contract-owner)))
        (not (is-eq address tx-sender))
        (not (is-eq address (as-contract tx-sender)))
    )
)