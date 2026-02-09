# Lane 1 — Rehearsal: Counter flow

Treat rehearsal as a controlled **write** (Operate lane) on Sepolia/Mainnet. Record outcomes in `workbook/20-rehearsal-counter.md` or `workbook/runs/`.

## Preparation

- [ ] Multisig + Counter deployed on the target network.
- [ ] Signer A and Signer B accounts funded.
- [ ] Fresh salt available (scripts/salt.sh).

## Step-by-step (devnet example)

1) Load env + set real values:

```bash
source scripts/env.example.sh
# Update: ACCOUNT, ACCOUNTS_FILE, SIGNERS, SIGNER_A, SIGNER_B, RPC
```

2) Deploy the example counter (writes `artifacts/<network>/counter.json`):

```bash
./scripts/deploy_example_counter.sh
```

3) Deploy the multisig (writes `artifacts/<network>/multisig.<label>.json`):

```bash
./scripts/deploy_multisig.sh --label primary
```

4) Run the rehearsal flow (writes `artifacts/<network>/rehearsal.counter.json`):

```bash
./scripts/rehearse_counter_flow.sh --label primary
```

5) Copy the tx hashes + final counter value into the run log.

## Submit -> confirm -> execute

- Submit
- Confirm (Signer A)
- Confirm (Signer B)
- Execute
- Final Counter value

Expected:
- State transitions: Pending -> Confirmed -> Executed
- `submit_transaction` does not auto-confirm in OZ v2.0.0

## Negative tests

- Non-signer cannot submit (expect revert: "Multisig: not a signer")
- Non-signer cannot confirm (expect revert: "Multisig: not a signer")
- Non-signer cannot execute (expect revert: "Multisig: not a signer")
