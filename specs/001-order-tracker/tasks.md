---
description: "Task list for Order Tracker feature implementation"
---

# Tasks: Order Tracker

**Input**: Design documents from `/specs/001-order-tracker/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Not requested in the feature specification — no automated test tasks in this list. Validate via quickstart.md smoke steps.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no incomplete dependencies)
- **[Story]**: `[US1]`…`[US4]` for story phases only
- Exact file paths included in descriptions

## Path Conventions

- App root: `ios/` per plan.md
- Providers: `ios/Providers/{Wildberries,AliExpress,CDEK}/`
- Features: `ios/Features/{Orders,Connections}/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the Xcode/SwiftUI project, display name, and delivery scaffolding

- [x] T001 Create `ios/` directory tree per plan.md (`App/`, `Features/Orders/`, `Features/Connections/`, `Providers/`, `Domain/`, `Persistence/`, `Security/`, `Tests/`)
- [x] T002 Initialize SwiftUI iOS 17+ Xcode project under `ios/` with bundle display name **Order Tracker** in `ios/App/Info.plist` (or target Display Name)
- [x] T003 [P] Set unique Bundle Identifier placeholder in `ios/` project signing settings suitable for Sideloadly re-sign
- [x] T004 [P] Add `codemagic.yaml` at repo root for native iOS IPA build artifact (Codemagic primary path from research.md)
- [x] T005 [P] Add stub `.github/workflows/ios-ipa.yml` as secondary GitHub Actions macOS IPA upload workflow
- [x] T006 Align `specs/001-order-tracker/quickstart.md` paths with the real Xcode scheme/target names after project creation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared domain, adapter contract, Keychain, SwiftData, shell UI — MUST complete before any user story

**⚠️ CRITICAL**: No user story work begins until this phase is complete

- [x] T007 Define `ProviderId`, `ConnectionStatus`, `OrderStatus` enums in `ios/Domain/Enums.swift`
- [x] T008 [P] Define domain structs `Order`, `OrderItem`, `StatusSnapshot`, `ProviderConnection` in `ios/Domain/Models.swift` per data-model.md
- [x] T009 [P] Define `ProviderAdapter` protocol and `Credentials` / `RefreshResult` types in `ios/Providers/ProviderAdapter.swift` per contracts/provider-adapter.md
- [x] T010 Implement Keychain session store in `ios/Security/KeychainSessionStore.swift` (no secrets in logs)
- [x] T011 Implement SwiftData models + container bootstrap in `ios/Persistence/SwiftDataModels.swift` and `ios/Persistence/PersistenceController.swift`
- [x] T012 Implement `ConnectionRepository` in `ios/Persistence/ConnectionRepository.swift` (metadata only; sessions via Keychain)
- [x] T013 Implement `OrderRepository` in `ios/Persistence/OrderRepository.swift` (upsert by provider+providerOrderId, ~30-day horizon helper)
- [x] T014 Implement shared `HTTPClient` with timeouts in `ios/Providers/HTTPClient.swift`
- [x] T015 Implement `RefreshOrchestrator` skeleton in `ios/Providers/RefreshOrchestrator.swift` that invokes adapters independently and merges successes
- [x] T016 Create app shell navigation (list home ↔ connections) in `ios/App/OrderTrackerApp.swift` and `ios/App/RootView.swift` with Russian copy, no Order Tracker login
- [x] T017 Add redacting logger helper in `ios/Security/RedactingLog.swift` for connection/refresh diagnostics

**Checkpoint**: Foundation ready — user stories can proceed

---

## Phase 3: User Story 1 — Связать существующие аккаунты провайдеров (Priority: P1) 🎯 MVP

**Goal**: Connect existing Wildberries, AliExpress, and CDEK accounts; persist sessions; no Order Tracker account

**Independent Test**: Connect at least one provider with real credentials; kill app; relaunch — still connected; never prompted for an Order Tracker login

### Implementation for User Story 1

- [x] T018 [P] [US1] Implement `WildberriesAdapter` connect/disconnect/session in `ios/Providers/Wildberries/WildberriesAdapter.swift` (phone + SMS/password)
- [x] T019 [P] [US1] Implement `AliExpressAdapter` connect/disconnect/session in `ios/Providers/AliExpress/AliExpressAdapter.swift` (login + password + optional challenge)
- [x] T020 [P] [US1] Implement `CDEKAdapter` connect/disconnect/session in `ios/Providers/CDEK/CDEKAdapter.swift` (login + code/password)
- [x] T021 [US1] Implement `ConnectionsViewModel` in `ios/Features/Connections/ConnectionsViewModel.swift` (load statuses, connect, disconnect, map errors)
- [x] T022 [US1] Build Connections list UI (three providers, status chips) in `ios/Features/Connections/ConnectionsView.swift` per contracts/ui-screens.md
- [x] T023 [P] [US1] Build Wildberries connect form in `ios/Features/Connections/WildberriesConnectView.swift`
- [x] T024 [P] [US1] Build AliExpress connect form in `ios/Features/Connections/AliExpressConnectView.swift`
- [x] T025 [P] [US1] Build CDEK connect form in `ios/Features/Connections/CDEKConnectView.swift`
- [x] T026 [US1] Wire connect success to Keychain + `ConnectionRepository` and show masked `displayLoginHint` in `ios/Features/Connections/ConnectionsViewModel.swift`
- [x] T027 [US1] Ensure failed connect shows Russian error, leaves status `disconnected`, allows retry in Connections UI files above
- [x] T028 [US1] Register adapter instances in `ios/Providers/ProviderRegistry.swift` and inject into Connections flow from `ios/App/RootView.swift`

**Checkpoint**: US1 independently testable — MVP connect/persist works

---

## Phase 4: User Story 2 — Единый список статусов заказов (Priority: P1)

**Goal**: One simple home list with provider, product image/title, status, pull-to-refresh

**Independent Test**: With ≥1 connected provider (or fixture data), home list shows provider + product preview + status without opening marketplace apps

### Implementation for User Story 2

- [x] T029 [P] [US2] Extend `WildberriesAdapter.refreshRecentOrders` to return `NormalizedOrderDraft` with items/images in `ios/Providers/Wildberries/WildberriesAdapter.swift`
- [x] T030 [P] [US2] Extend `AliExpressAdapter.refreshRecentOrders` similarly in `ios/Providers/AliExpress/AliExpressAdapter.swift`
- [x] T031 [P] [US2] Extend `CDEKAdapter.refreshRecentOrders` similarly in `ios/Providers/CDEK/CDEKAdapter.swift`
- [x] T032 [P] [US2] Add per-provider status mappers to `OrderStatus` in `ios/Providers/Wildberries/WildberriesStatusMapper.swift`, `ios/Providers/AliExpress/AliExpressStatusMapper.swift`, `ios/Providers/CDEK/CDEKStatusMapper.swift`
- [x] T033 [US2] Complete `RefreshOrchestrator.refreshAll` to persist drafts via `OrderRepository` in `ios/Providers/RefreshOrchestrator.swift`
- [x] T034 [US2] Implement `OrdersListViewModel` (load cache, refresh, lastSuccessAt) in `ios/Features/Orders/OrdersListViewModel.swift`
- [x] T035 [US2] Build order row UI (provider label, image or «нет фото», title + «и ещё N», status) in `ios/Features/Orders/OrderRowView.swift`
- [x] T036 [US2] Build home list + empty state + pull-to-refresh in `ios/Features/Orders/OrdersListView.swift` per contracts/ui-screens.md
- [x] T037 [US2] Show last successful refresh time on home in `ios/Features/Orders/OrdersListView.swift`
- [x] T038 [US2] Set `OrdersListView` as default root content in `ios/App/RootView.swift` with navigation to Connections

**Checkpoint**: US1 + US2 deliver core product value (MVP+list)

---

## Phase 5: User Story 3 — Простой просмотр деталей заказа (Priority: P2)

**Goal**: Tap a row to see provider, product, status, id, updated time, stale/unknown clarity

**Independent Test**: Open any list row → detail shows required fields without leaving Order Tracker

### Implementation for User Story 3

- [x] T039 [US3] Implement `OrderDetailViewModel` in `ios/Features/Orders/OrderDetailViewModel.swift`
- [x] T040 [US3] Build `OrderDetailView.swift` in `ios/Features/Orders/OrderDetailView.swift` (provider, image/title, status, providerOrderId, lastUpdatedAt, stale/unknown messaging)
- [x] T041 [US3] Add navigation from `OrdersListView.swift` to `OrderDetailView.swift`
- [x] T042 [US3] Persist/read latest `StatusSnapshot` when refreshing in `ios/Persistence/OrderRepository.swift` for detail display

**Checkpoint**: US3 detail flow works independently on top of list data

---

## Phase 6: User Story 4 — Устойчивость при сбое одного провайдера (Priority: P2)

**Goal**: One provider failure/auth expiry does not hide others; clear banners; re-auth path

**Independent Test**: Force one adapter to fail refresh — other providers’ orders remain; failed provider shows warning; needsReauth opens connect form only for that provider

### Implementation for User Story 4

- [x] T043 [US4] Ensure `RefreshOrchestrator` isolates failures (`authExpired` / `unavailable`) without rolling back other providers’ saves in `ios/Providers/RefreshOrchestrator.swift`
- [x] T044 [US4] Mark failed provider connection `error`/`needsReauth` and set `isStale` on that provider’s orders in `ios/Persistence/ConnectionRepository.swift` and `ios/Persistence/OrderRepository.swift`
- [x] T045 [US4] Add home banner/chips for provider errors in `ios/Features/Orders/ProviderStatusBanner.swift` and integrate in `ios/Features/Orders/OrdersListView.swift`
- [x] T046 [US4] Route `needsReauth` from banner/Connections to the correct connect form without any Order Tracker login in `ios/Features/Connections/ConnectionsView.swift`
- [x] T047 [US4] Keep showing cached orders for healthy providers when one fails (verify in `OrdersListViewModel.swift`)

**Checkpoint**: Partial outages behave per FR-013/FR-014

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Delivery path, copy, security hardening, quickstart validation

- [x] T048 [P] Verify Russian UI strings across `ios/Features/**/*.swift` (no English leftover on user-facing screens)
- [x] T049 [P] Audit logs to ensure passwords/SMS/cookies never written via `ios/Security/RedactingLog.swift` usage sites
- [x] T050 Confirm Codemagic workflow produces downloadable IPA using `codemagic.yaml`
- [x] T051 Document exact Sideloadly steps with real scheme/IPA name in `specs/001-order-tracker/quickstart.md`
- [x] T052 Run quickstart.md smoke table (Connections → refresh → detail → kill/relaunch) on a physical iPhone installed from Windows
- [x] T053 [P] Add brief README section at repo `README.md` pointing to quickstart (Codemagic → Sideloadly → iPhone)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)** → no deps
- **Phase 2 (Foundational)** → after Setup; **blocks all stories**
- **US1 (Phase 3)** → after Foundational — MVP
- **US2 (Phase 4)** → after Foundational; practically after US1 adapters exist (can stub refresh earlier, but real data needs US1 sessions)
- **US3 (Phase 5)** → after US2 list data exists
- **US4 (Phase 6)** → after US2 refresh path exists; strengthens orchestrator/UI
- **Polish (Phase 7)** → after desired stories complete

### User Story Dependencies

- **US1**: Independent after Foundational
- **US2**: Uses adapters from US1; independently testable with one connected provider
- **US3**: Uses orders from US2; independently testable by opening any row
- **US4**: Cross-cutting on refresh/UI; independently testable by simulating one adapter failure

### Parallel Opportunities

- T003–T005 (signing + CI stubs) in Setup
- T008–T009 (models + protocol) in Foundational
- T018–T020 (three adapters connect) in US1
- T023–T025 (three connect forms) in US1
- T029–T032 (refresh + mappers) in US2
- T048–T049, T053 in Polish

---

## Parallel Example: User Story 1

```text
Task: "Implement WildberriesAdapter connect in ios/Providers/Wildberries/WildberriesAdapter.swift"
Task: "Implement AliExpressAdapter connect in ios/Providers/AliExpress/AliExpressAdapter.swift"
Task: "Implement CDEKAdapter connect in ios/Providers/CDEK/CDEKAdapter.swift"
```

```text
Task: "Build WildberriesConnectView in ios/Features/Connections/WildberriesConnectView.swift"
Task: "Build AliExpressConnectView in ios/Features/Connections/AliExpressConnectView.swift"
Task: "Build CDEKConnectView in ios/Features/Connections/CDEKConnectView.swift"
```

---

## Parallel Example: User Story 2

```text
Task: "Wildberries refresh + status mapper"
Task: "AliExpress refresh + status mapper"
Task: "CDEK refresh + status mapper"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1 Setup
2. Phase 2 Foundational
3. Phase 3 US1 (connect + persist)
4. **STOP** — validate Independent Test for US1 (optionally via simulator + later Sideloadly)

### Incremental Delivery

1. Setup + Foundational
2. US1 → demo connections
3. US2 → demo unified list (core value)
4. US3 → detail
5. US4 → resilience banners/reauth
6. Polish → Codemagic IPA + Windows Sideloadly on device

### Suggested MVP Scope

**US1 only** for first shippable increment; **US1+US2** for first useful daily driver.

---

## Notes

- No Order Tracker account/registration anywhere
- Adapter HTTP details stay inside `ios/Providers/*`
- Display name must remain **Order Tracker**
- Format validation: all tasks use `- [ ]`, `Txxx`, story labels only on US phases, and include file paths
