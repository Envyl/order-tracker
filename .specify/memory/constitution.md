<!--
Sync Impact Report
- Version change: (none) → 1.0.0
- Modified principles: N/A (initial ratification from constitution-template.md)
- Added sections:
  - Core Principles I–V (iPhone Local-First Delivery; Unified Order Status
    Aggregation; Provider Adapter Isolation; Credential & Privacy Safety;
    Lean Personal Scope)
  - Local Install & Home-Computer Workflow
  - Integration Boundaries
  - Governance
- Removed sections: N/A (first constitution)
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md — Constitution Check gates + iOS/
    Providers structure aligned to principles
  - ✅ .specify/templates/spec-template.md — edge cases, entities, success
    criteria, and assumptions aligned to local install + three providers
  - ✅ .specify/templates/tasks-template.md — iOS path conventions, provider
    foundational tasks, local-install polish
  - ✅ .specify/templates/constitution-template.md — bootstrapped (was missing)
  - ⚠ .specify/templates/commands/*.md — not present in repo; Spec Kit skills
    live under .cursor/skills/speckit-* (agent-agnostic; no CLAUDE-only refs)
  - ⚠ README.md / docs/quickstart.md — not present yet; create when project
    scaffolding starts
- Follow-up TODOs:
  - Confirm product display name if "Jules" should differ from folder name
  - Choose concrete local-install method (Xcode device run, Developer Mode,
    AltStore/SideStore, etc.) during /speckit-specify or /speckit-plan
  - Confirm auth approach per provider (official API vs session/cookie vs
    tracking-number-only) during research
-->

# Jules Constitution

Jules is a personal iPhone app that aggregates order and shipment statuses from
Wildberries, AliExpress, and CDEK. Primary distribution is local install from a
home computer—not App Store-first. These principles bind specification, planning,
and implementation.

## Core Principles

### I. iPhone Local-First Delivery

The product MUST target iPhone as the primary client. Users MUST be able to
install and update the app from a home computer without depending on the App
Store as the primary distribution path.

- Ship an iOS app that runs on a physical iPhone (simulator alone is not
  sufficient for release validation).
- Document a reproducible local install path from a home computer (build,
  sideload, or developer deploy).
- App Store, TestFlight, or other public distribution MAY be added later but
  MUST NOT block the local-install workflow.
- Any home-computer companion (scripts, helper, sync tool) MUST remain optional
  and MUST NOT become a mandatory always-on cloud service.

**Rationale:** The stated product goal is a personally owned iPhone tool
installed from home hardware. Local install is a product requirement, not a
temporary development convenience.

### II. Unified Order Status Aggregation

The app MUST present a single, coherent view of order/shipment status across
Wildberries, AliExpress, and CDEK.

- Persist and display a normalized status model (identity, provider, title or
  tracking id, status, last update, deep-link or raw reference when useful).
- Refresh MUST update the unified list; users MUST NOT be forced to open each
  marketplace app for the primary status-check task.
- Provider-specific labels MAY appear as secondary detail, but the primary UX
  MUST use the unified model.
- When a provider returns partial or unknown data, the UI MUST show an explicit
  degraded state rather than inventing a false status.

**Rationale:** Aggregation value is lost if each source remains a siloed screen
or raw API dump.

### III. Provider Adapter Isolation

Each external source MUST be integrated behind an isolated adapter boundary.

- Wildberries, AliExpress, and CDEK MUST each have a dedicated adapter module
  implementing a shared provider contract.
- Failure, rate limiting, auth expiry, or schema change in one provider MUST
  NOT block refresh or display of the others.
- Parsing, HTTP, and auth details MUST stay inside the adapter; UI and domain
  layers MUST depend on the normalized model only.
- Adding or removing a provider MUST be possible without rewriting unrelated
  adapters.

**Rationale:** Marketplace and courier APIs change independently. Isolation
keeps the app usable when one source breaks.

### IV. Credential & Privacy Safety

Credentials and order data are personal. The system MUST minimize exposure.

- Store secrets in platform-appropriate secure storage (e.g., iOS Keychain);
  MUST NOT commit secrets to git or ship them in plaintext logs.
- Prefer on-device (and optional home-computer) storage for credentials and
  cached statuses; MUST NOT require a third-party backend to hold user
  marketplace passwords or session tokens by default.
- Logs and diagnostics MUST redact tokens, cookies, passwords, and full
  account identifiers.
- Network calls to providers MUST use timeouts and explicit user-triggered or
  scheduled refresh—not unbounded background scraping.

**Rationale:** The app handles shopping and delivery accounts. Local-first
secrets reduce blast radius for a personal tool.

### V. Lean Personal Scope

Jules is a personal aggregator. Scope MUST stay minimal unless a feature
explicitly expands it.

- In-scope providers for the product baseline are Wildberries, AliExpress, and
  CDEK only.
- MUST NOT add multi-user accounts, social feeds, public sharing, ads, or
  unrelated commerce features without an explicit constitution amendment or
  feature mandate.
- Prefer the simplest approach that delivers readable aggregated statuses;
  reject speculative architecture (microservices, multi-tenant cloud) for v1.
- Complexity that violates a principle MUST be justified in the plan's
  Complexity Tracking table.

**Rationale:** A focused personal app ships faster and stays maintainable.
Extra platforms and cloud surfaces increase auth and compliance cost without
clear user value.

## Local Install & Home-Computer Workflow

Local install is part of the product contract.

- Specs and plans that touch distribution MUST describe how a user installs
  from a home computer onto an iPhone.
- Quickstart docs MUST include prerequisites (OS, Apple ID/developer
  constraints, cables/Wi-Fi pairing, signing) at a level sufficient to
  reproduce install.
- CI or agent workflows MAY build for simulator; release acceptance MUST
  include at least one successful on-device local install check when
  distribution changes.
- If a home-computer helper is introduced, it MUST be documented under
  `tools/` (or equivalent) and MUST fail with actionable errors when pairing
  or signing is misconfigured.

## Integration Boundaries

External systems are limited and intentional.

- Approved providers: Wildberries, AliExpress, CDEK.
- Each adapter MUST document whether it uses official API, tracking-number
  public endpoints, or user-session automation—and the risks of that choice.
- Scraping or unofficial session reuse MUST be treated as fragile: isolate it,
  cover with fixture-based tests, and avoid spreading selectors or private
  headers across the codebase.
- Out-of-scope providers require a feature spec plus a constitution amendment
  (or an explicit temporary exception in Complexity Tracking with removal
  criteria).

## Governance

This constitution supersedes ad-hoc convention where they conflict.

- **Authority.** Principles I–V and the Local Install / Integration sections
  are binding gates. The plan template `## Constitution Check` MUST be
  evaluated against them. `/speckit-analyze` treats conflicts with a MUST as
  CRITICAL. Resolve conflicts by changing the spec, plan, or tasks—not by
  diluting a principle.
- **Amendments.** Changes require an explicit update to this file, a SemVer
  bump per the policy below, propagation to dependent templates in the same
  change, and a Sync Impact Report HTML comment at the top of this file.
- **Versioning policy.** MAJOR = backward-incompatible governance or
  principle removal/redefinition; MINOR = new principle/section or materially
  expanded guidance; PATCH = clarifications and non-semantic refinements.
- **Compliance review.** Every feature plan MUST pass Constitution Check
  before Phase 0 research completes. Unjustified violations block
  implementation. RATIFICATION_DATE remains the original adoption date;
  LAST_AMENDED_DATE updates on each amendment.

**Version**: 1.0.0 | **Ratified**: 2026-07-18 | **Last Amended**: 2026-07-18
