# Run log: Deploy

Procedure: `ops/runbooks/lane2-deploy.md`

## Metadata

- Date:
- Network:
- RPC:
- Deployer account:
- Accounts file:
- Multisig label:
- Quorum:
- Signers:
- Counter initial value:

## Pre-deploy checks

- [ ] Chain id matches target network.
- [ ] Signers list is correct and funded.
- [ ] Quorum <= signers count.
- [ ] Class hashes match expected Cairo/Scarb version.

## Declare classes

- Multisig class hash:
- Multisig declare tx:
- Counter class hash:
- Counter declare tx:

## Deploy instances

Multisig instance:
- Label:
- Address:
- Deploy tx:
- Quorum:
- Signers:

Optional additional multisig instance:
- Label:
- Address:
- Deploy tx:
- Quorum:
- Signers:

Example Counter:
- Address:
- Deploy tx:
- Initial value:

## Post-deploy verification

- [ ] On-chain multisig signers list matches expected.
- [ ] On-chain quorum matches expected.
- [ ] Example Counter `get()` returns the initial value.

## Artifacts

- [ ] `artifacts/<network>/multisig.class.json` updated
- [ ] `artifacts/<network>/multisig.<label>.json` updated
- [ ] (if applicable) additional `artifacts/<network>/multisig.<label>.json` updated
- [ ] `artifacts/<network>/counter.class.json` updated
- [ ] `artifacts/<network>/counter.json` updated
