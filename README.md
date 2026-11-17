# PehlaPaisa 🪙

**Pehle bachao, phir kharcho**: save first, then spend.

PehlaPaisa is an offline-first Flutter app (Android + iOS) that helps people on small incomes (₹5,000–₹30,000/month) build the *pay-yourself-first* habit. Money appears as glowing glasses of liquid on a softly lit shelf. On salary day you fill the **Savings** glass first, then Rent, Food, Travel and Fun. Spending drains the glasses. The app never drains Savings to cover other spending.

- No login, no backend, no analytics. Budgeting is fully offline; the internet is used only to load Google AdMob ads (see **Ads** below).
- Payments are handed to the phone's own UPI app. PehlaPaisa never touches bank accounts or PINs, and needs no payment licence.
- No bank, SMS or UPI access. Your data never leaves the phone.
- English and simple everyday Hindi, with an instant language switch.

---

## Setup

Requirements: Flutter **3.44 or later** (built and tested on 3.47.2 / Dart 3.13). For Android you also need the **Android SDK platform 37**. `flutter_local_notifications` 23 requires it.

```bash
flutter pub get
flutter gen-l10n            # also runs automatically on build (generate: true)
flutter run                 # on a connected Android/iOS device or emulator
```

Build:

```bash
flutter build apk --release --split-per-abi   # Android (~3× smaller per-device APKs)
flutter build appbundle            # Android, for the Play Store
flutter build ipa                  # iOS (on macOS with Xcode)
```

> **Build tip:** if a release build fails with `package dev.flutter.plugins.integration_test does not exist`, run `flutter clean` and build again. The test-only `integration_test` plugin sometimes leaks into the generated plugin list after packages change.

### On-device tests

`flutter test integration_test -d <device-id>` runs on a connected, unlocked phone. Debug/test builds use the app ID `com.pehlapaisa.app.debug`, so they install **next to** the real app and never touch or erase real user data.

### Release signing (Android)

Release builds are signed with the upload key in `android/app/upload-keystore.jks`. Its passwords are in `android/key.properties`. Both files are git-ignored.

> **Back up both files somewhere safe**, for example a password manager or a private drive. Every future Play Store update must be signed with the same key. If a file is missing, release builds fall back to the debug key, which is fine for local testing but will be rejected by the Play Store.

The app ID is `com.pehlapaisa.app` on both Android and iOS. Upload `build/app/outputs/bundle/release/app-release.aab` to the Play Console.

See [TEST_REPORT.md](TEST_REPORT.md) for the latest test results.

### Publishing

- **[STORE_LISTING.md](STORE_LISTING.md)**: store texts (English and Hindi), Play *Data safety* and App Store *App Privacy* answers, review notes, screenshot sizes and step-by-step release checklists for both stores.
- **[PRIVACY_POLICY.md](PRIVACY_POLICY.md)** / **[website/](website/)**: the published policy is `website/privacy.html` (with `index.html` and `app-ads.txt`), ready for GitHub Pages. Paste its link in both stores and in the AdMob consent message.
- **CI:** `.github/workflows/ci.yml` runs analyze, all tests, the Android bundle build and the **iOS build on a macOS runner** on every push to GitHub.
- **iOS:** bundle ID `com.pehlapaisa.app`, iOS 15+, iPhone and iPad (portrait, full screen), Hindi declared, privacy manifest `ios/Runner/PrivacyInfo.xcprivacy`. Pay with UPI on iOS opens Google Pay / PhonePe / Paytm through their own URL schemes.

### Quality checks

```bash
flutter analyze      # 0 issues
flutter test         # unit + widget tests
```

---

## Features

| Area | What you get |
|---|---|
| **Fast start** | Opens in about 1s on a mid-range phone (release build). The native splash and the in-app loading screen both use the dark night-shelf theme with the glass icon, and the loading screen shows a short money tip (tap to skip). |
| **Onboarding** | Intro with the glass visual, then 4 steps: name → income, salary day and income type → "Do you live with family?" → suggested split with sliders. The English/हिंदी switch is on the first screen. |
| **Salary Day ritual** | Tap **Fill Savings First** and watch money pour into the Savings glass. Rent → Food → Travel → Fun fill next, with confetti and haptics at the end. Irregular earners use the same screen for each income entry. |
| **Salary dates** | Shows the real date of every salary: *Next salary: 10 Dec 2026* on the shelf, in onboarding as soon as you pick the day, on the salary-day screen and in Settings. Day 31 falls on the last day of shorter months. |
| **Pay with UPI** | On any everyday glass (not Savings), tap **Pay with UPI**, enter the amount and optionally who you're paying. PehlaPaisa warns if the glass is short (borrowing from Fun first, never Savings). Tap **Open UPI app** to see the UPI apps installed on the phone; the chosen app opens on its home screen (native `getLaunchIntentForPackage` in `MainActivity.kt`, URL scheme on iOS) and the user scans the QR and pays there. When they come back it asks *Did the payment go through?*: **Yes, paid** records the expense, **Open another app** reopens the list, **No / failed** records nothing. Why not a pre-filled `upi://pay` link: UPI apps (Google Pay, PhonePe) decline payments handed over by apps that are not registered payment partners (tested on a real phone: "amount not debited" / "declined for security reasons"). Starting the payment inside the UPI app always works. No camera is used. |
| **Coin drop** | On the welcome screen, ₹ coins fall one by one into the Savings glass and fill it (tap the glass to replay). A quicker 4-coin version plays on the loading screen. |
| **Weekly limits** | Every everyday glass (Food, Travel, Fun, custom) gets a weekly budget: monthly amount ÷ weeks in the month. A *This week's limits* card on the shelf shows spent vs limit per glass. Each glass's detail page shows it too. |
| **Home shelf** | Animated liquid glasses with gentle waves. Savings glows amber, Fun glows pink/purple, the rest glow blue. The top shows the month, money left to spend and a 🔥 streak chip. Tap a glass for details, long-press to add an expense quickly. Low-glass and weekly-food alerts appear as cards, and each can be hidden with ✕. A hidden weekly warning comes back only if you overspend again in a new week. |
| **Add expense** | Large ₹ keypad, glass picker, optional note and date. Saving takes 3 taps or fewer, and the chosen glass visibly drains. |
| **Overflow rule** | If a glass runs short, a dialog offers to borrow from Fun first, then from other glasses, or to log the expense as overspent. Savings is never touched unless you confirm **Break my savings**, which ends that month's streak. |
| **Jar detail** | Big glass, poured in / spent / left, weekly food budget, this month's history grouped by day (swipe to delete), and a **Move money** button. |
| **Goals** | Each goal is its own glass. Move free savings into a goal and see an estimate: "At ₹X/month you'll reach this in N months". If no goal exists yet, the app suggests an Emergency Fund of 3 × monthly expenses. |
| **Monthly report** | Pie chart of spending by glass, savings for the last 6 months, % of income saved, best and worst glass, comparison with last month, and educational tips with a disclaimer. |
| **Badges & levels** | 10 badges: Pehla Kadam, Pehla Paisa, Streak 3/6/12, Gullak Master, Goal Getter, Fun Under Control, Logger, Bachat Champion. Five levels: Beginner → Saver → Smart Saver → Gullak Master → PehlaPaisa Legend, with a progress bar. |
| **Celebrations** | A full-screen modal with confetti, haptics and a Share button when a goal completes, a badge unlocks, a new streak month starts, or Savings is filled. |
| **Share cards** | 1080×1920 story and 1080×1080 post images for your streak, total saved, a completed goal or an unlocked badge. Amounts stay hidden unless you turn on **Show amounts**. Cards are shared through the system sheet (WhatsApp, Instagram, …). |
| **Notifications** | On every app start the app checks for notification permission and asks if it isn't granted yet. After setup a "Reminders are on" notification confirms it works, and *Settings → Send a test notification* shows one on demand. |
| **Reminders** | Salary-day reminder, Sunday-evening check-in with the week's spending, an optional daily "log today's spending" reminder at a time you choose, and low-glass alerts sent at most once per glass per month. All times use Asia/Kolkata. |
| **Settings** | Language, theme (night shelf / morning shelf / system), notification toggles and times, profile edit (income, salary day, income type, family), split editor with custom glasses, JSON export, reset with double confirmation, and an About screen. |

### Core money rules (domain layer)

- **Suggested split** by income band:

  | Income | Savings | Rent | Food | Travel | Fun |
  |---|---|---|---|---|---|
  | ≤ ₹7,000 | 10% | 40% | 30% | 12% | 8% |
  | up to ₹15,000 | 20% | 35% | 25% | 10% | 10% |
  | more | 25% | 30% | 20% | 10% | 15% |

  If you live with family, Rent becomes "Home contribution" at half its share, and the freed half goes to Savings. Each glass is rounded to ₹10, and Fun absorbs the rounding so the total always equals income. Setting Savings below 5% asks for confirmation.
- **Month cycle**: a month starts on your salary day. Day 31 falls on the last day of shorter months. A changed salary day applies from the next cycle.
- **Streak month**: Savings was filled first and was not broken that month. Skipped months break the streak.
- **Irregular income**: each income entry is split with the same percentages, Savings first.
- **Total saved** is the sum of what stayed in Savings each month. Goals are earmarks inside that total, so moving money into a goal never reduces your savings.

---

## Architecture

The code is organised by feature. Each feature separates **data** (models, repositories), **domain** (pure Dart business rules, fully unit-tested) and **presentation** (screens, widgets, providers).

```
lib/
  main.dart                 # opens Hive, notifications, ProviderScope
  app/                      # app widget, router (go_router), theme, l10n helper
    state/                  # BudgetController (single entry point for changes),
                            # BudgetState (derived values), repository providers
  core/                     # money formatting (₹1,00,000), dates, constants,
    storage/                # KeyValueStore abstraction: HiveStore / MemoryStore
    widgets/                # keypad, dialogs, shelf background, emoji picker
  features/
    onboarding/  data: UserProfile + repo     presentation: splash, onboarding
    salary/      data: MonthCycle + repo      domain: SplitCalculator, CycleRange,
                                                 MonthRollover, Funding
                 presentation: salary-day ritual, split sliders
    jars/        data: Jar + repo             domain: JarFactory
                 presentation: home shelf, jar detail, LiquidGlassPainter, GlassJar
    transactions/ data: Transaction + repo    domain: OverflowPlanner
                 presentation: add-expense sheet
    goals/       data: Goal + repo            domain: GoalLogic
    streaks/     domain: StreakCalculator
    reports/     domain: ReportCalculator     presentation: charts (fl_chart)
    alerts/      data: NotificationGateway    domain: AlertEngine
                 presentation: NotificationSync
    badges/      data: BadgeRecord + repo     domain: BadgeEngine, Levels
                 presentation: badges screen, celebration queue + host
    share/       domain: ShareCardData        presentation: ShareCard, share screen
    settings/    data: AppSettings + repo
                 presentation: settings, split editor, about
  l10n/          app_en.arb, app_hi.arb (+ generated AppLocalizations)
test/
  domain/        split, overflow, streaks, goals, rollover, irregular income,
                 badges, levels, alerts, reports
  data/          repository CRUD against both Hive and in-memory stores
  widget/        onboarding flow, add expense (incl. overflow & break savings),
                 home shelf (a11y labels, Hindi, family mode, font scaling, tablet)
  devices/       every screen on 10 phone/tablet sizes × English/Hindi
  helpers/       fixtures + a demo-data generator used only by tests
  screenshots/   optional screen capture (see below)
```

**State flow.** Every change goes through `BudgetController` (a Riverpod `Notifier`). It runs the pure domain rule, persists the result through the repositories, then re-reads state from storage, so the UI always matches what is saved. Derived values such as streak, total saved, level and alerts are computed from `BudgetState`.

**Storage.** Hive (`hive_ce`) stores one box per collection as plain JSON-like maps, which makes export trivial. Repositories sit behind a small `KeyValueStore` interface, so tests run in memory.

Where the data lives on the phone: Hive files (`profile.hive`, `jars.hive`, `transactions.hive`, `cycles.hive`, `goals.hive`, `badges.hive`, `settings.hive`) in the app's private documents folder:
- Android: `/data/data/com.pehlapaisa.app/app_flutter/`
- iOS: the app's `Documents` directory

Other apps cannot read these files. Nothing is synced or backed up (`allowBackup=false`), and uninstalling the app deletes everything. **Settings → Export data** saves a JSON copy.

**Liquid glass.** `LiquidGlassPainter` (a `CustomPainter`) draws a tapered tumbler with:
- a two-layer sine-wave surface and a vertical gradient
- an inner radial glow, a meniscus highlight and an outer halo
- an optional pour stream for salary day

`GlassJar` drives the wave with an `AnimationController` and animates level changes over 800 ms with easeOutCubic. It respects the system *reduce motion* setting: waves and confetti stop.

**Fonts.** Poppins (headings), Inter (body) and Noto Sans Devanagari (Hindi fallback) are bundled in `assets/fonts`, so the app needs no network access.

**Accessibility.** Every glass has a screen-reader label, for example "Food glass, ₹1,200 left of ₹2,500". Tap targets are at least 48 dp, and layouts are tested at 360 dp width with 1.4× system font scaling.

---

## Screenshots

There is no emulator step. A test-based harness renders the real screens with the bundled fonts and the demo data:

```bash
# macOS/Linux
PP_SCREENSHOTS=build/screenshots flutter test test/screenshots
# Windows (Git Bash)
FLUTTER_ROOT="$(dirname $(dirname $(which flutter)))" PP_SCREENSHOTS=build/screenshots flutter test test/screenshots
```

This writes PNGs (360×740 @3x, dark and light, Hindi, tablet, onboarding, salary day, add expense, share) to `build/screenshots/`. Emoji show as placeholder boxes because the test engine has no emoji font. On a device they render normally.

For store screenshots, use the PNGs above or take them on a phone after using the app for a few days.

---

## Platform notes

- **Android:** compileSdk 37, core library desugaring enabled (required by notifications). Permissions: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` (to restore reminders after a reboot), `VIBRATE`, and `INTERNET` / `ACCESS_NETWORK_STATE` / `AD_ID` for Google AdMob ads only. minSdk is 24 (required by the Google Mobile Ads SDK). `android/app/proguard-rules.pro` keeps WorkManager's Room database (used by the Ads SDK); without it the minified release crashes on start. A `<queries>` entry for the `upi` scheme lets the app find installed UPI apps on Android 11+. Reminders use inexact alarms, so no exact-alarm permission is needed. `allowBackup` is off, so data stays on the device.
- **iOS:** the notification delegate is set in `AppDelegate.swift`. Permission is requested when onboarding finishes.

## Disclaimer

PehlaPaisa shares general, educational money tips only. It does not give investment or financial advice.

## Ads (Google AdMob)

- **Where:** a banner at the bottom of the Shelf and the Share screen; one native ad card at the end of Goals and of the Monthly report. Never on onboarding, salary day, Add expense, Pay with UPI, alerts or celebrations.
- **Code:** `lib/features/ads/` — `ad_ids.dart` holds the App/ad-unit IDs and the developer's test devices; `ads.dart` asks for consent (Google UMP; the form is set up in AdMob → Privacy & messaging and only shows in the EEA/UK), starts the SDK after the first frame, and renders `AdSpot` slots. A slot takes no space until an ad has loaded, and stays empty offline.
- **Test ads:** debug builds always use Google's test IDs. Phones listed in `AdIds.testDevices` get test ads even in the release build, so the developer can never click their own live ads.
- **Live IDs:** Android App ID `ca-app-pub-1571944076824107~7964997688` (AndroidManifest). iOS is still on Google's test App ID — create the iOS app and ad units in AdMob before an App Store release.
- **Tests:** widget and device tests replace every ad with a same-sized placeholder (`test/helpers/sample_ad.dart`), so layouts are checked with ads in place.
- **app-ads.txt:** publish `google.com, pub-1571944076824107, DIRECT, f08c47fec0942fa0` at the root of the developer website listed on the store page.

## Growth features

- **Rate prompt** (`lib/features/growth/review_prompt.dart`): after a celebration closes (savings filled, badge, goal), the app may request Google's / Apple's in-app review popup. Rules (`ReviewPolicy`): not in the first 3 days, at most 3 times ever, at least 90 days apart, and only when no other celebration is waiting. The stores add their own limits, so the popup may not appear.
- **Share cards** carry the download link: the share text ends with the Play Store link (`AppLinks.download`) and the card image shows "Free on Google Play".
- **Invite a friend** (Settings): shares a Hinglish (or Hindi) message with the Play Store link through the phone's share sheet (WhatsApp, etc.).
- **Store search words**: see STORE_LISTING.md (title "PehlaPaisa: Budget & Savings", keyword-rich short and full descriptions).

