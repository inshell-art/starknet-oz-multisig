# Run log: Rehearsal — Counter flow

Procedure: `ops/runbooks/lane1-rehearsal-counter.md`

## Metadata

- Date:
- Network:
- RPC:
- Multisig label:
- Signer A:
- Signer B:

## Submit -> confirm -> execute

- Submit tx hash:
- Transaction ID (hash):
- Confirm tx (Signer A):
- Confirm tx (Signer B):
- Execute tx hash:
- Final Counter value:

## Expected

- State transitions: Pending -> Confirmed -> Executed
- `submit_transaction` does not auto-confirm in OZ v2.0.0

## Negative tests

- [ ] Non-signer cannot submit (expect revert: "Multisig: not a signer")
- [ ] Non-signer cannot confirm (expect revert: "Multisig: not a signer")
- [ ] Non-signer cannot execute (expect revert: "Multisig: not a signer")
