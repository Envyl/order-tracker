# Contract: ProviderAdapter

**Feature**: `001-order-tracker`  
**Consumers**: Order refresh service, Connections UI  
**Implementors**: `WildberriesAdapter`, `AliExpressAdapter`, `CDEKAdapter`

## Purpose

Isolate each marketplace/courier behind one contract so UI and domain depend only on normalized models.

## Types (logical)

```text
ProviderId = wildberries | aliexpress | cdek

Credentials =
  | Wildberries { phone: String, smsCode: String?, password: String? }
  | AliExpress  { login: String, password: String, challengeCode: String? }
  | CDEK        { login: String, codeOrPassword: String }

ConnectionResult = Success | Failure(message: String)
RefreshResult =
  | Success(orders: [NormalizedOrderDraft])
  | Failure(kind: authExpired | unavailable | parseError, message: String)

NormalizedOrderDraft {
  providerOrderId: String
  status: OrderStatus
  statusRawLabel: String?
  lastUpdatedAt: Date
  items: [{ title: String, imageURL: URL?, quantity: Int }]
}
```

## Operations

### `connect(credentials) -> ConnectionResult`

- MUST verify credentials against the provider (live call).
- On success MUST persist session in Keychain and return Success.
- MUST NOT create provider accounts.
- MUST NOT store passwords in SwiftData; prefer session tokens/cookies after login. If password must be retained for re-auth, it MUST remain Keychain-only.

### `disconnect()`

- MUST delete Keychain session for this provider.
- MAY leave cached orders until next purge policy.

### `refreshRecentOrders(horizonDays: Int = 30) -> RefreshResult`

- MUST return normalized drafts only.
- MUST map statuses to `OrderStatus`; unknown → `unknown` + raw label.
- On `authExpired`, caller marks connection `needsReauth`.
- MUST use timeouts; MUST NOT hang the shared refresh loop.

### `providerId` / `displayName`

- Stable id + Russian display label for UI chips (“Wildberries”, “AliExpress”, “СДЭК”).

## Concurrency & isolation

- Refresh orchestrator MUST call adapters independently (e.g. concurrent tasks).
- Failure of one adapter MUST NOT cancel others’ successful results.
- No shared mutable HTTP client state across adapters without isolation.

## Non-goals

- Official long-term SLA for unofficial buyer endpoints.
- Cross-provider order merging (same physical parcel from WB delivered by CDEK may appear as separate rows in v1 unless a later feature defines linking).
