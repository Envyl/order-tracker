# Order Tracker

Personal iPhone app that aggregates order statuses from **Wildberries**, **AliExpress**, and **СДЭК**.

Display name: **Order Tracker**. No app account — only provider account linking.

## Stack

- SwiftUI / iOS 17+
- SwiftData + Keychain
- Isolated provider adapters under `ios/Providers/`

## Build & install (Windows home PC)

1. **Build IPA** with [Codemagic](https://codemagic.io) — see below (or GitHub Actions).
2. **Install** on iPhone from Windows with **Sideloadly** + free Apple ID.

Details: [`specs/001-order-tracker/quickstart.md`](specs/001-order-tracker/quickstart.md)

Open project: `ios/OrderTracker.xcodeproj` (scheme **OrderTracker**, bundle id `com.personal.ordertracker`).

### Codemagic setup (monorepo)

The iOS app is **not** at the repo root — it lives under `ios/`.

**Option A — YAML (recommended):** after connecting GitHub, configure builds from **`codemagic.yaml`** (repo root). Workflow **Order Tracker IPA** already sets `working_directory: ios`.

**Option B — UI scan wizard:** if you see “repository doesn't contain a mobile application”:
- Project type: **iOS** (native)
- Project path / monorepo folder: **`ios`**
- Xcode project: `OrderTracker.xcodeproj`
- Scheme: `OrderTracker`

## Notes

Buyer APIs are unofficial. Adapters may offline-link and show fixture orders when live fetch is unavailable (`AppSettings.allowOfflineProviderLink` / `useFixturesWhenLiveFails`). Harden live auth per provider as endpoints are confirmed.
