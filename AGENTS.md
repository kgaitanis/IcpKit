# AGENTS.md

## Scope
- These instructions apply to the entire repository unless a nested `AGENTS.md` says otherwise.
- Before editing within any folder, check for and read applicable nested `AGENTS.md` files.
- This project is also a learning exercise in agent-assisted Xcode development. Explain significant decisions briefly and keep changes small enough for review.

## Repository Map
- `Package.swift`: Swift package manifest. Verified products include `IcpKit`, `Candid`, `DAB`, and executable `CodeGenerator`.
- `Sources/IcpKit`: ICP request/client logic, certificate parsing, cryptography helpers, models, and ledger canister code.
- `Sources/Candid`: Candid types, values, parser, encoder/decoder, and binary serialisation.
- `Sources/DAB`: DAB token/NFT services and generated canister bindings.
- `Sources/CodeGenerator`: command-line generator for Swift code from `.did` files.
- `Sources/bls12381`, `include/Bls12381.h`, `include/module.modulemap`: existing Rust BLS12-381 verifier source and C module headers. The SwiftPM target/linking entries are currently commented in `Package.swift`.
- `Tests/IcpKitTests`, `Tests/CandidTests`, `Tests/CodeGeneratorTests`, `Tests/DABTests`: package test targets.
- `Examples`: Xcode example apps.

## BLS Migration Goal
- Replace the Rust BLS12-381 signature verifier with an entirely Swift implementation.
- Remove Rust build and linking infrastructure only after Swift verification is validated.
- Preserve the existing verification API: `ICPCryptography.verifyBlsSignature(message:publicKey:signature:)`.
- Preserve required cryptographic behavior: compressed encodings, certificate domain separation, hash-to-curve behavior, subgroup checks, pairing verification, and invalid-signature errors.
- Keep certificate delegation and unrelated refactoring outside this migration unless explicitly requested.

## Working Agreements
- Inspect existing code and uncommitted changes before editing. Preserve the user's work.
- Follow the repository's existing Swift conventions: SwiftUI/Swift package style, 4-space indentation, strong types, `let` for constants, `@State private var` for SwiftUI state, and async/await over Combine.
- Keep edits narrowly scoped to the requested task. Do not change production code, tests, dependencies, project settings, or examples unless the request calls for it.
- Use meaningful tests for migration work, including valid signatures, altered messages, malformed inputs, and preserved reference fixture bytes.
- Never disable tests or weaken assertions merely to obtain passing results.
- Report what changed, what was actually tested, failures, skips, and remaining limitations.
- Distinguish expected failures during test-first development from regressions.
- Leave changes uncommitted for review. Do not stage, commit, amend commits, or push unless explicitly asked for that specific Git action. Permission to implement changes or run tests does not authorize Git actions.

## Verified Build And Test Guidance
- Verified via Xcode tools on 2026-09-19: active scheme/test plan is `IcpKit-Package`.
- Verified via Xcode tools: `BuildProject` builds the package successfully.
- Verified via Xcode tools: `RunAllTests` ran 59 tests with 58 passing, 0 failing, and 1 skipped.
- Verified skipped test: `IcpKitTests/ICPCryptographyTests/testBlsSignatureVerification()` is skipped with `XCTSkip("This test is temporarily disabled")`.
- Assumption, not re-verified in this file change: standard SwiftPM commands such as `swift test` may also work from the repository root, but prefer Xcode tools when working inside Xcode.
