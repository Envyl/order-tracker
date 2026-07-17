# Contract: Order Tracker UI (screens)

**Feature**: `001-order-tracker`  
**Style**: Simple, Russian copy, no marketing chrome

## Screen: Order List (home)

**Entry**: App launch (default).

**Must show**

- App title **Order Tracker**
- Pull-to-refresh / explicit refresh control
- Last successful refresh time (global or per visible summary)
- Rows for each cached/fetched order:
  - Provider label (always visible)
  - Product image or “нет фото”
  - Product title (+ “и ещё N” if more items)
  - Normalized status text
- Empty state when no orders
- Banner/chip when any provider is in `error` / `needsReauth` without hiding other orders
- Navigation to Connections

**Must not show**

- Order Tracker login/register
- Ads, stats dashboards, multi-tab clutter

## Screen: Order Detail

**Must show**

- Provider label
- Primary product image + title (and remaining item count)
- Status (+ raw label if `unknown` or helpful)
- Provider order id
- Last updated time
- Stale indicator if `isStale`

## Screen: Connections

**Must show**

- Three rows: Wildberries, AliExpress, СДЭК
- Status: не подключено / подключено / нужно войти снова / ошибка
- Masked login hint when connected
- Actions: Подключить / Отключить / Обновить вход

**Connect flows (per provider)**

| Provider | Fields |
|----------|--------|
| Wildberries | Телефон; код из SMS (и пароль, если ещё используется) |
| AliExpress | Email или телефон; пароль; код подтверждения при запросе |
| CDEK | Телефон/логин; код или пароль |

**Must not** offer “создать аккаунт” у провайдера.

## Accessibility / clarity acceptance

A tester glancing at a row can answer: (1) which provider, (2) what the item looks like / is called, (3) what the status is.
