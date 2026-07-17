# Data Model: Order Tracker

**Feature**: `001-order-tracker` | **Date**: 2026-07-18

## Entities

### ProviderConnection

Metadata for a linked provider account (secrets live in Keychain, not here).

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| provider | ProviderId | `wildberries` \| `aliexpress` \| `cdek` |
| status | ConnectionStatus | `disconnected` \| `connected` \| `needsReauth` \| `error` |
| displayLoginHint | String? | Masked phone/email for UI only (e.g. `+7•••1234`) |
| lastSuccessAt | Date? | Last successful refresh for this provider |
| lastErrorMessage | String? | User-visible short error |
| keychainAccount | String | Key used to look up session blob in Keychain |

**Rules**

- At most one `ProviderConnection` per `provider`.
- `connected` only after successful credential exchange.
- No Order Tracker user entity.

### Order

Normalized order/shipment row for the unified list.

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Local primary key |
| provider | ProviderId | Source of truth for “which provider” |
| providerOrderId | String | Opaque id from provider (unique per provider) |
| status | OrderStatus | Normalized enum (see below) |
| statusRawLabel | String? | Optional secondary provider wording |
| lastUpdatedAt | Date | From provider or local receive time |
| fetchedAt | Date | When adapter last wrote this row |
| isStale | Bool | True if provider failed and row is cache-only |

**Uniqueness**: `(provider, providerOrderId)`

### OrderItem

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| orderId | UUID | FK → Order |
| title | String | Product name |
| imageURL | URL? | Remote preview; nil → UI “нет фото” |
| sortIndex | Int | 0 = primary preview item |
| quantity | Int | Default 1 |

**Rules**

- Every Order MUST have ≥0 items; list preview uses `sortIndex == 0` if present, else first by sortIndex.
- Extra items count = `items.count - 1` when count > 1 (“и ещё N”).

### StatusSnapshot

Point-in-time status capture (supports detail history later; v1 may keep latest only).

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| orderId | UUID | FK → Order |
| status | OrderStatus | Normalized |
| rawLabel | String? | Provider text |
| recordedAt | Date | |

## Enumerations

### ProviderId

`wildberries` | `aliexpress` | `cdek`

### ConnectionStatus

`disconnected` → `connected` ↔ `needsReauth` / `error` → `disconnected` (on unlink)

### OrderStatus (normalized)

| Value | Meaning (RU UI examples) |
|-------|--------------------------|
| `placed` | Оформлен |
| `paid` | Оплачен |
| `assembling` | Собирается |
| `inTransit` | В пути |
| `readyForPickup` | Готов к выдаче |
| `delivered` | Доставлен |
| `cancelled` | Отменён |
| `unknown` | Статус неизвестен (never invent a fake status) |

Adapters map provider-specific strings → `OrderStatus`; unmapped → `unknown` + `statusRawLabel`.

## Relationships

```text
ProviderConnection (1) ---- manages sessions for ----> ProviderId
Order (N) ---- belongs to ----> ProviderId
Order (1) ---- has many ----> OrderItem
Order (1) ---- has many ----> StatusSnapshot
```

## Session secret (Keychain only)

Not a SwiftData entity. Logical payload per provider:

| Field | Notes |
|-------|-------|
| provider | ProviderId |
| sessionBlob | Opaque encrypted/serialized tokens/cookies |
| obtainedAt | Date |
| expiresAt | Date? |

## Validation rules (from spec)

- Display name of app: Order Tracker (bundle display name).
- List shows only orders with `fetchedAt` within ~30 days OR still non-terminal status (`delivered`/`cancelled` may drop after horizon).
- Partial refresh: failed provider does not delete other providers’ orders; mark failed connection `error`/`needsReauth` and set `isStale` on that provider’s rows if needed.
- Image missing → `imageURL == nil` → placeholder, not blank crash.

## State transitions

### Connection

```text
disconnected --(valid credentials)--> connected
connected --(auth expired / 401)--> needsReauth
connected --(network/provider down)--> error (orders kept)
needsReauth --(re-link success)--> connected
* --(user disconnect)--> disconnected (delete keychain + optional purge orders)
```

### Order status

Provider-driven; local app does not advance status without refresh. Unknown stays `unknown` until a successful mapped refresh.
