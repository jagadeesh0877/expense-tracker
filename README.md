# ExpenseTracker (iOS 16+, SwiftUI)

- Base currency: AED end-to-end
- Local-first: Core Data + offline FX cache
- Daily free FX refresh from ECB → AED-base, with fallback
- SwiftUI + Swift Charts, WCAG AA, reduce motion respected

## Features
- Dashboard with KPIs, animated charts (Swift Charts), budgets with threshold colors
- Transactions: add/edit/delete with live AED conversion, search/sort/filter, swipe actions, undo toast
- Categories: defaults seeded, CRUD, monthly budgets (AED)
- Budgets & alerts: threshold coloring; ready for local notifications at 80%/100%
- Daily tracking: Today/MTD summaries; streak counter scaffold
- Settings: base AED (view-only), week start, privacy mode, density, font scale, data export/import/clear, FX rates screen (fetch now, paste JSON, edit pair)
- Background refresh: BGAppRefreshTask daily, once-per-day attempt with fallback
- CI: unsigned IPA via GitHub Actions

## Architecture
- SwiftUI + MVVM + Services
  - FxService: AED-base rates load/save, fetch (ECB), convert, once-per-day policy
  - PersistenceService: Core Data stack
  - BudgetService: rollups (MTD and per-category)
  - ToastManager: non-blocking banners
- Storage
  - Core Data: Transaction, Category
  - UserDefaults: Settings, FxService last attempt
  - Application Support: `fxRates.json`

## AED-base FX derivation (ECB EUR → AED cross)
ECB publishes EUR-base rates. To store AED-base:
- If EUR→AED = r_EUR_AED and EUR→X = r_EUR_X, then AED→X = (1 / r_EUR_AED) * r_EUR_X.
- Persist JSON schema:
```json
{
  "base": "AED",
  "asOf": "2025-01-05T00:00:00Z",
  "rates": { "USD": 0.2723, "EUR": 0.2490, "INR": 22.50, "GBP": 0.2150, "SAR": 1.0200, "KWD": 0.0830, "QAR": 0.9930, "OMR": 0.1040, "BHD": 0.1030, "PKR": 75.0, "LKR": 82.0, "EGP": 13.0 },
  "lastUpdated": "2025-01-05T05:30:00Z"
}
```

## Daily refresh logic (launch/day-change + BG task) and fallback
- On launch/foreground and at local day change, if `lastUpdated` < today → attempt refresh.
- BackgroundTasks: `com.expensetracker.fxrefresh` scheduled daily with `earliestBeginDate ≈ +18h`.
- On fetch failure: keep cached `fxRates.json`; surface a non-blocking toast “Using last known FX rates”.

## GitHub Actions: build an unsigned IPA
Workflow file: `.github/workflows/ios_unsigned_ipa.yml`
- Xcode 15 on `macos-latest`
- Device destination build + archive with signing disabled
- Packages `.app` into an unsigned `.ipa` and uploads as artifact

Run it:
- Push a tag like `build-2025-01-05` or trigger manually via Actions → “iOS Unsigned IPA”.
- Download artifact `ExpenseTracker-unsigned.ipa`.

## Build & Sideload without a Mac (Windows + AltServer/AltStore)

### Overview (what you’ll do)
1. Build an unsigned IPA on GitHub Actions.
2. Download the IPA to your Windows PC.
3. Install AltServer on Windows → install AltStore on your iPhone.
4. Use AltServer to sideload your IPA (re-signs with your free Apple ID).
5. The app runs for 7 days → repeat sideload weekly.

### 0) One-time prerequisites
- A GitHub repo for this iOS project.
- Unique Bundle ID (e.g., `com.yourname.expensetracker`).
- No restricted entitlements (Push, App Groups, etc.).
- On Windows:
  - Install iTunes (from Apple, not Microsoft Store).
  - Install iCloud for Windows (Apple).
  - Install AltServer for Windows: `https://altstore.io`
- On iPhone (iOS 16+): Settings → Privacy & Security → Developer Mode → On (restart & enable).

### 1) Get the unsigned IPA
- In GitHub → Actions → run “iOS Unsigned IPA” (or push a `build-*` tag).
- Download the artifact `ExpenseTracker-unsigned.ipa` to Windows.

### 2) Install AltStore
- Open AltServer (tray icon) → connect iPhone via USB (or Wi‑Fi after trust).
- Install AltStore to your device (enter Apple ID; enable Mail plugin if prompted).
- On iPhone: Settings → General → VPN & Device Management → Trust your Apple ID profile.

### 3) Sideload the IPA
- In AltServer (Windows): “Install .ipa…” → select `ExpenseTracker-unsigned.ipa`.
- AltServer re-signs with your Apple ID dev certificate and installs it.

### 4) Re-sign weekly
- Free Apple ID installs expire in 7 days. Reinstall from AltServer/AltStore.

### Troubleshooting
- Ensure Apple versions of iTunes & iCloud are installed, and the device is trusted.
- Make sure the project disables code signing in Release CI build.
- If AltStore says “Unable to verify app,” open the profile trust screen again.

## JSON formats
- Export/import payload:
```json
{
  "categories": [
    { "id": "UUID", "name": "Food", "icon": "fork.knife", "colorHex": "#e00800", "monthlyBudgetBase": 500.0 }
  ],
  "transactions": [
    { "id": "UUID", "date": "2025-01-05T12:00:00Z", "categoryId": "UUID", "amountOriginal": 12.34, "currencyCode": "USD", "amountInBase": 45.31, "note": "Lunch", "createdAt": "...", "updatedAt": "..." }
  ]
}
```
- FX cache file: `fxRates.json` stored in Application Support directory.
