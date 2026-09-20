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
- `Tests/IcpKitTests`, `Tests/CandidTests`, `Tests/CodeGeneratorTests`, `Tests/DABTests`: package test targets.
- `Examples`: Xcode example apps.

## Working Agreements
- Inspect existing code and uncommitted changes before editing. Preserve the user's work.
- Follow the repository's existing Swift conventions: SwiftUI/Swift package style, 4-space indentation, strong types.
- Prefer proving Sendable safety through value types, Sendable constraints, actors, or modern synchronization primitives before using `@unchecked Sendable`; if `@unchecked Sendable` is unavoidable, document why the type is safe.
- Keep edits narrowly scoped to the requested task. Do not change production code, tests, dependencies, project settings, or examples unless the request calls for it.
- Never disable tests or weaken assertions merely to obtain passing results.
- Report what changed, what was actually tested, failures, skips, and remaining limitations.
- Distinguish expected failures during test-first development from regressions.
- Leave changes uncommitted for review. Do not stage, commit, amend commits, or push unless explicitly asked for that specific Git action. Permission to implement changes or run tests does not authorize Git actions.
