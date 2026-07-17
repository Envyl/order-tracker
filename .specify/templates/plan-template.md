# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

**Language/Version**: [e.g., Swift 5.9 / SwiftUI or NEEDS CLARIFICATION]

**Primary Dependencies**: [e.g., SwiftUI, URLSession, Keychain or NEEDS CLARIFICATION]

**Storage**: [e.g., SwiftData/Core Data, Keychain, files or N/A]

**Testing**: [e.g., XCTest, XCUITest or NEEDS CLARIFICATION]

**Target Platform**: [e.g., iOS 17+ iPhone; local install from home computer or NEEDS CLARIFICATION]

**Project Type**: [e.g., mobile-app (iOS) + optional home-computer sync helper or NEEDS CLARIFICATION]

**Performance Goals**: [e.g., status list interactive <1s after refresh or NEEDS CLARIFICATION]

**Constraints**: [e.g., local-first credentials; no App Store as primary distribution; provider rate limits or NEEDS CLARIFICATION]

**Scale/Scope**: [e.g., personal use; 3 providers (Wildberries, AliExpress, CDEK); dozens of active orders or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Evaluate every plan against `.specify/memory/constitution.md` (Jules v1.0.0):

- **I. iPhone Local-First Delivery**: Feature ships on iPhone and remains installable from a home computer without requiring App Store distribution as the primary path.
- **II. Unified Order Status Aggregation**: User-visible status is normalized into one model/list; raw provider jargon is not leaked as the primary UX.
- **III. Provider Adapter Isolation**: Wildberries / AliExpress / CDEK changes stay behind adapters; one provider outage MUST NOT block others.
- **IV. Credential & Privacy Safety**: Secrets stay on device or home computer; no third-party telemetry of credentials or order payloads by default.
- **V. Lean Personal Scope**: No multi-user cloud SaaS, social features, or extra marketplaces unless explicitly specified.
- **Local Install & Home-Computer Workflow**: Any companion tooling remains optional and documented for local install/refresh.
- **Integration Boundaries**: Only approved providers; scraping vs official API choice is explicit and reversible per adapter.

Violations MUST be resolved in the plan or justified in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
# Default for Jules: iPhone app + optional home-computer helper
ios/
├── App/
├── Features/
│   ├── Orders/
│   └── Settings/
├── Providers/
│   ├── Wildberries/
│   ├── AliExpress/
│   └── CDEK/
├── Domain/
└── Tests/

# Optional: home-computer install / sync helper (only if plan requires it)
tools/
└── [local install, pairing, or refresh scripts]

# [REMOVE IF UNUSED] Single-project fallback
src/
├── models/
├── services/
└── lib/

tests/
├── unit/
└── integration/
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th provider] | [current need] | [why three providers insufficient] |
| [e.g., always-on cloud sync] | [specific problem] | [why on-device cache insufficient] |
