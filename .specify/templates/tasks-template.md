---
description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Jules (default)**: `ios/` for the iPhone app; `ios/Providers/{Wildberries,AliExpress,CDEK}/` for adapters; optional `tools/` for home-computer install helpers
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- Paths shown below assume Jules iOS layout - adjust based on plan.md structure

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan (`ios/`, optional `tools/`)
- [ ] T002 Initialize iOS (Swift/SwiftUI) project with dependencies from plan.md
- [ ] T003 [P] Configure linting, formatting, and local-install documentation stubs

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Define unified Order / Status domain models shared by all providers
- [ ] T005 [P] Implement ProviderAdapter protocol and error isolation boundaries
- [ ] T006 [P] Setup secure credential storage (Keychain / home-computer secrets)
- [ ] T007 Create on-device persistence for last-known order statuses
- [ ] T008 Configure networking, timeouts, and structured error surfacing
- [ ] T009 Setup environment / feature flags for provider enablement
- [ ] T010 Document and smoke-test local iPhone install path from home computer

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T011 [P] [US1] Unit test for status normalization in ios/Tests/...
- [ ] T012 [P] [US1] Integration test for [user journey] in ios/Tests/...

### Implementation for User Story 1

- [ ] T013 [P] [US1] Create [Entity1] model in ios/Domain/...
- [ ] T014 [P] [US1] Create [Entity2] model in ios/Domain/...
- [ ] T015 [US1] Implement [Provider or Service] in ios/Providers/... or ios/Features/...
- [ ] T016 [US1] Implement UI / flow in ios/Features/...
- [ ] T017 [US1] Add validation and error handling (provider isolation)
- [ ] T018 [US1] Add logging for user story 1 operations (no secrets in logs)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T019 [P] [US2] Unit/integration tests in ios/Tests/...

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create [Entity] model in ios/Domain/...
- [ ] T021 [US2] Implement [Service/Adapter] in ios/Providers/... or ios/Features/...
- [ ] T022 [US2] Implement UI / flow in ios/Features/...
- [ ] T023 [US2] Integrate with User Story 1 components (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T024 [P] [US3] Unit/integration tests in ios/Tests/...

### Implementation for User Story 3

- [ ] T025 [P] [US3] Create [Entity] model in ios/Domain/...
- [ ] T026 [US3] Implement [Service/Adapter] in ios/Providers/... or ios/Features/...
- [ ] T027 [US3] Implement UI / flow in ios/Features/...

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates (local install quickstart, provider setup)
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across refresh / list flows
- [ ] TXXX [P] Additional unit tests (if requested) in ios/Tests/
- [ ] TXXX Security hardening (Keychain, log redaction, secret scrubbing)
- [ ] TXXX Validate local install path end-to-end on a physical iPhone
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services/adapters
- Adapters before UI that depends on them
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- Provider adapters for different sources can often proceed in parallel once the protocol exists
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch adapter/model work together:
Task: "Create Order model in ios/Domain/Order.swift"
Task: "Create Wildberries adapter stub in ios/Providers/Wildberries/..."
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently (including local install if in scope)
5. Demo on device if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Demo (MVP!)
3. Add User Story 2 → Test independently → Demo
4. Add User Story 3 → Test independently → Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Prefer one adapter per provider; do not merge Wildberries/AliExpress/CDEK scraping logic into shared UI code
