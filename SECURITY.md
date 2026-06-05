# Security Policy — diffscope-fork

## Supported Versions

| Version | Supported |
|---------|-----------|
| main (latest) | Yes |

## Reporting a Vulnerability

To report a security vulnerability in diffscope-fork:

1. **Do not** open a public GitHub Issue.
2. Report via the gerivdb/GOVERNANCE-HUB repository security process.
3. Include: affected version, description, reproduction steps, severity assessment.

## Security Measures

- Supply-chain: Docker images pinned by sha256 digest
- Dependencies: `cargo audit` + `cargo deny` in CI
- BDCP: No outbound network calls by design (static Rust binary)
- No LLM calls, no telemetry, no external API dependencies at runtime

## IntentHash

`0xDIFFSCOPE_FORK_INTENT_20260605_V1`
