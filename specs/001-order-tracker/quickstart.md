# Quickstart: Order Tracker

**Feature**: `001-order-tracker`  
**Home install:** Windows + **Sideloadly** + free Apple ID  
**Build IPA:** **Codemagic** (primary) or GitHub Actions macOS  

Project: `ios/OrderTracker.xcodeproj`  
Scheme / target: **OrderTracker**  
Bundle ID: `com.personal.ordertracker`  
Display name: **Order Tracker**

## One-liner

Build IPA in the cloud → install from Windows with Sideloadly.

---

## A. Build IPA online

### A1. Codemagic (primary)

1. Push repo to Git; connect to Codemagic.
2. App is under **`ios/`** (monorepo). Either:
   - Use **`codemagic.yaml`** at repo root (workflow `order-tracker-ipa`, `working_directory: ios`), or
   - In the UI scan wizard set **Project path = `ios`**, type **iOS**, project `OrderTracker.xcodeproj`, scheme `OrderTracker`.
3. Download artifact `OrderTracker.ipa`.
4. Continue to **B**.

### A2. GitHub Actions (secondary)

1. Run `.github/workflows/ios-ipa.yml` (workflow_dispatch or push under `ios/`).
2. Download artifact `OrderTracker-ipa` → `OrderTracker.ipa`.

### A3. Mac + Xcode (optional)

1. Open `ios/OrderTracker.xcodeproj`.
2. Set Team / unique bundle id if needed.
3. Archive → export IPA, or Run on device.

---

## B. Install from Windows (Sideloadly)

1. Web iTunes + iCloud (not Microsoft Store) + Sideloadly.
2. iPhone: Developer Mode on (iOS 16+).
3. USB → Sideloadly → drop `OrderTracker.ipa` → Apple ID → Start.
4. Trust developer certificate on the phone.
5. Launch **Order Tracker**.

Re-sideload ~every 7 days when free signature expires.

---

## C. Smoke validation

| Step | Action | Expected |
|------|--------|----------|
| A | Подключения | Три провайдера |
| B–C | Привязка WB / AE / СДЭК | «подключено»; без аккаунта Order Tracker |
| D | Обновить список | Провайдер + фото/название + статус (fixtures, если live API недоступен) |
| E | Детали | ID, статус, товар |
| F | Сбой одного | Остальные видны + баннер |
| G | Перезапуск | Привязки сохраняются |

## Note on provider APIs

Buyer endpoints are unofficial. Default settings allow offline link + fixtures when live refresh fails so UI/delivery can be validated. Replace fixture path with real session APIs inside each adapter when confirmed.
