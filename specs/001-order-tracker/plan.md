# Implementation Plan: Order Tracker

**Branch**: `001-order-tracker` | **Date**: 2026-07-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-order-tracker/spec.md`

**Note**: `.specify/scripts/powershell/setup-plan.ps1` is not present in this repo; plan artifacts were created directly from the plan template and feature.json (`specs/001-order-tracker`).

## Summary

Order Tracker is a personal iPhone app that links existing Wildberries, AliExpress, and CDEK accounts (no Order Tracker account) and shows one simple order list with provider label, product name/image, and status.

**Technical approach:** native SwiftUI iOS app with isolated provider adapters, Keychain for sessions, on-device cache for last-known orders.

**Local install:** **Windows + Sideloadly** (free Apple ID, ~7-day resign).  
**Build IPA:** **Codemagic** cloud Mac (primary); GitHub Actions macOS as secondary; optional rented Mac GUI. No local Mac required for the baseline Windows workflow.

## Technical Context

**Language/Version**: Swift 5.10+ / SwiftUI (iOS 17+)

**Primary Dependencies**: SwiftUI, Foundation URLSession, Security (Keychain), SwiftData (order cache)

**Storage**: Keychain for provider session secrets; SwiftData for cached orders/items/status snapshots

**Testing**: XCTest (domain + adapter fixtures); manual on-device validation via quickstart

**Target Platform**: iPhone, iOS 17+; install via Windows Sideloadly; IPA via **Codemagic** (or GHA macOS)

**Project Type**: mobile-app (iOS); CI config for Codemagic/GHA when repo is ready; no always-on Windows server

**Performance Goals**: Cached list interactive on open (<1s); full multi-provider refresh usable within ~15s on normal networks

**Constraints**: Local-first credentials; no App Store-first distribution; Windows sideload; cloud Mac for compile; free Apple ID re-sign ~7 days; unofficial buyer-session adapters; Russian UI

**Scale/Scope**: Personal single-user; 3 providers; dozens of recent orders (~30 days)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Pre-research | Post-design |
|------|--------------|-------------|
| **I. iPhone Local-First Delivery** | PASS — Windows Sideloadly + cloud IPA | PASS — Codemagic/GHA documented |
| **II. Unified Order Status Aggregation** | PASS — normalized Order + StatusSnapshot | PASS — data-model + UI contracts |
| **III. Provider Adapter Isolation** | PASS — `ios/Providers/{Wildberries,AliExpress,CDEK}` | PASS — ProviderAdapter contract |
| **IV. Credential & Privacy Safety** | PASS — Keychain; no third-party auth backend | PASS — secrets not in SwiftData plaintext |
| **V. Lean Personal Scope** | PASS — three providers only; no OT account | PASS — no extra platforms |
| **Local Install & Home-Computer Workflow** | PASS — Windows install; online Mac for build | PASS — quickstart A=Codemagic, B=Sideloadly |
| **Integration Boundaries** | PASS — buyer-session adapters, documented risk | PASS — research decisions per provider |

No unjustified violations. Complexity Tracking left empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-order-tracker/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1
└── tasks.md             # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
ios/
├── App/                         # Order Tracker entry, app display name
├── Features/
│   ├── Orders/                  # List + detail (simple UI)
│   └── Connections/             # Provider link / disconnect flows
├── Providers/
│   ├── ProviderAdapter.swift    # Shared contract
│   ├── Wildberries/
│   ├── AliExpress/
│   └── CDEK/
├── Domain/                      # Order, OrderItem, StatusSnapshot, enums
├── Persistence/                 # SwiftData models + repositories
├── Security/                    # Keychain wrapper
└── Tests/
    ├── DomainTests/
    └── ProviderFixtureTests/
```

**Structure Decision:** Single iOS app under `ios/`. IPA via Codemagic (or GHA); home install Windows + Sideloadly. Optional rented Mac only for interactive debugging.

## Complexity Tracking

> No constitution violations requiring justification.
