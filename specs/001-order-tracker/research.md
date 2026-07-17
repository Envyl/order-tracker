# Research: Order Tracker

**Feature**: `001-order-tracker` | **Date**: 2026-07-18

## 1. Local install method (amended for Windows home PC)

### Decision

**Split build vs install:**

| Step | Where | Tool |
|------|-------|------|
| **Install onto iPhone (primary, home PC)** | **Windows PC** | **Sideloadly** + free Apple ID + USB |
| **Build IPA (compile Swift)** | **Online macOS CI (primary)** or any Mac | Codemagic / GitHub Actions → download `.ipa` |

**Yes — you can install Order Tracker on an iPhone from a Windows PC.**  
**No — you cannot compile Swift/iOS using only Windows tools.** A **Mac somewhere** (cloud CI, rented Mac, or physical) must run Xcode; Windows then sideloads.

### How Windows install works (primary path)

1. On Windows: install **web** (non–Microsoft Store) **iTunes** + **iCloud**, then **Sideloadly**.
2. Obtain `OrderTracker.ipa` from **cloud build** (section 1b) or a Mac.
3. Connect iPhone by USB; enable **Developer Mode** (iOS 16+).
4. In Sideloadly: drop IPA, enter free **Apple ID**, start sideload (Sideloadly re-signs).
5. On iPhone: trust the developer certificate under VPN & Device Management.
6. Free Apple ID apps expire in ~**7 days** — re-sideload from Windows (often without a new cloud build if only the signature expired).

### Optional Mac-only shortcut

If a Mac is at hand, **Xcode → Run on Device (Personal Team)** remains valid for developers. It is **not** required for day-to-day home install once an IPA exists.

### Rationale

- Home computer is **Windows** — constitution “install from home computer” must work there.
- Sideloadly is the simplest widely used Windows→iPhone IPA installer.
- Online CI removes the need to own a Mac for *compiling*; Sideloadly removes the need for a Mac for *installing*.

### Alternatives considered

| Option | Why not primary |
|--------|-----------------|
| **Xcode-only on owned Mac** | Fine if available; not assumed for this user. |
| **AltStore / SideStore** | Fallback if Sideloadly fails. |
| **Pure Windows build (no Mac ever)** | Impossible for native SwiftUI — rejected. |
| **Paid Apple Developer** | Optional later for longer signing / easier CI signing; not required for Sideloadly+free ID baseline. |

---

## 1b. Build options when the PC is Windows (incl. online services)

Apple’s compiler (**Xcode**) only runs on **macOS**. On Windows you choose *which Mac builds for you*, not whether a Mac is involved.

### Decision (locked for Order Tracker)

| Role | Choice |
|------|--------|
| **Primary online build** | **Codemagic** (cloud Mac mini, native iOS YAML, download IPA artifact) |
| **Secondary online build** | **GitHub Actions** (`macos-*` runner + `xcodebuild`) |
| **Interactive remote Mac** | MacinCloud / MacStadium / AWS EC2 Mac — only if you need a full Xcode GUI |
| **Install after build** | Windows **Sideloadly** (unchanged) |

**Preferred flow:** push/repo → Codemagic builds IPA → download on Windows → Sideloadly → iPhone.

Codemagic (and similar) can emit an IPA that **Sideloadly re-signs** with a free Apple ID. Full App Store / automatic CI signing usually wants a **paid** Apple Developer Program; that is **optional** for our local Sideloadly path.

### Option catalog

| Option | What it is | Pros | Cons | Fit for Order Tracker |
|--------|------------|------|------|------------------------|
| **Codemagic** | Online CI with hosted Macs; native iOS docs | Simple mobile-first UX; IPA artifacts; no local Mac | Paid beyond free tier; needs git repo + config | **Primary** |
| **GitHub Actions macOS** | CI minutes on `macos-14`/`macos-15` | Already in GitHub ecosystem; flexible | macOS minutes costly/limited; more YAML DIY | **Secondary** |
| **Bitrise / similar mobile CI** | Same idea as Codemagic | Mature mobile pipelines | Another vendor; similar cost | Alternative to Codemagic |
| **MacinCloud / MacStadium / EC2 Mac** | Rent a real Mac (VNC/SSH) | Full Xcode GUI; debug like a laptop | $/mo or hourly; you manage Xcode | When GUI debugging needed |
| **Friend’s / library Mac** | Occasional Archive → IPA | Free / simple | Not always available | Occasional fallback |
| **Expo EAS / Flutter-only clouds** | Cloud build for *their* stacks | Easy if project were RN/Flutter | **N/A** — we are native SwiftUI | Rejected |
| **Hackintosh / illegal macOS VM on PC** | Unofficial macOS on PC | “Free” Mac-like | Unreliable, ToS/legal risk | **Rejected** |

### Rationale

- Online services **do exist** and are the practical answer for a Windows-only home setup.
- Codemagic is aimed at mobile IPA production with less DIY than raw GitHub Actions.
- Sideloadly keeps install + free-ID signing on the Windows PC, so CI need not solve App Store distribution.

### Alternatives considered (build)

| Option | Why not primary |
|--------|-----------------|
| GitHub Actions only | Works; more setup for a personal native app → secondary |
| Always-on rented Mac | Overkill if we only need periodic IPA builds |
| Change stack to Expo/RN for EAS | Violates lean native plan already chosen |
---

## 2. App stack

### Decision

**SwiftUI + Swift 5.10+, iOS 17+, SwiftData cache, Keychain sessions, URLSession.**

### Rationale

Native iPhone stack; smallest surface for a personal app; aligns with constitution lean scope.

### Alternatives considered

- React Native / Flutter — extra runtime and sideload complexity; rejected for v1.
- UIKit-only — workable but SwiftUI is faster for a two-screen simple UI.

---

## 3. Provider authentication (buyer accounts)

Official public “buyer order APIs” with stable OAuth for all three are not available for this personal use case. Seller/partner APIs (e.g. Wildberries seller tokens) do **not** cover buyer orders.

### Decision

**Per-provider buyer-session adapters** behind `ProviderAdapter`:

| Provider | User-facing credentials (from spec) | Adapter approach |
|----------|-------------------------------------|------------------|
| **Wildberries** | Phone + SMS code (or password if account still uses it) | Exchange credentials for buyer session/cookies/tokens via WB buyer auth endpoints; store session in Keychain; fetch recent orders + product preview |
| **AliExpress** | Email/phone + password (+ challenge if required) | Same pattern: login → session → orders/items |
| **CDEK** | Phone/login + code/password for personal cabinet | Same pattern: login → session → shipments/orders |

Adapters MUST:

- Keep HTTP/parsing private to the provider module.
- Treat endpoints as **unstable**; prefer fixture-based tests over live network in CI.
- On auth failure, surface “reconnect provider” without affecting other adapters.
- Never log SMS codes, passwords, or raw cookies.

### Rationale

Matches the product requirement: link *existing* accounts, no Order Tracker registration, no seller API misuse.

### Alternatives considered

| Option | Why not chosen |
|--------|----------------|
| Tracking-number-only (esp. CDEK) | Spec excludes it; user has cabinet accounts. |
| Manual paste of API tokens | WB seller tokens ≠ buyer orders; poor UX vs phone+SMS. |
| Hosted backend that stores passwords | Violates Credential & Privacy Safety. |
| In-app WKWebView-only for all providers | Heavier UX; keep as **fallback inside an adapter** if form-login breaks, not as the default architecture. |

---

## 4. Product image & provider visibility in UI

### Decision

List row and detail show: **provider chip/name**, **primary item title**, **primary item image URL (cached) or “нет фото”**, **normalized status**, **last updated**.

Multi-item orders: first item as preview + “и ещё N”.

### Rationale

Directly implements FR-009/010/017 and SC-003 without complex galleries.

---

## 5. Persistence

### Decision

- **Keychain**: provider connection id → encrypted session blob (tokens/cookies).
- **SwiftData**: Order, OrderItem, StatusSnapshot, ProviderConnection metadata (non-secret).

### Rationale

Secrets stay out of the general DB; cached list works offline/degraded when one provider fails.

---

## 6. Resolved clarifications

| Topic | Resolution |
|-------|------------|
| Local install | **Windows + Sideloadly** (primary); Mac Xcode Run optional |
| IPA build | **Codemagic** (primary online); GitHub Actions secondary; rented Mac for GUI |
| Online services? | **Yes** — cloud Mac CI (Codemagic, GHA, Bitrise) or rented Mac desktops |
| Language/UI | SwiftUI; Russian copy |
| OT account | None |
| Provider auth tech | Buyer-session adapters; unofficial; isolated |
| Min iOS | 17+ (Developer Mode era; SwiftData ergonomics) |

No remaining NEEDS CLARIFICATION items for planning.
