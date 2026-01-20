# Consensus Layer Contract

A coordination contract that verifies consensus conditions before allowing
critical actions to be executed on-chain.

## Key Functions
- `submit-decision` — Register a decision requiring consensus
- `approve-decision` — Signal approval from authorized participants
- `finalize-decision` — Confirm consensus and unlock execution
- `get-decision` — Retrieve decision status and approval count
- `is-approved` — Check if consensus threshold is met

Designed to sit between governance voting and execution layers for added
safety and coordination.
