# PehlaPaisa — Test Report

**Date:** 12 Nov 2026 · **App version:** 1.2.0 (build 8) · **Flutter:** 3.47.2 / Dart 3.13.2

This report lists only what was actually run. It also states plainly what was **not** tested.

## Summary

| Check | Result |
|---|---|
| `flutter analyze` | **0 issues** |
| Automated tests (`flutter test`) | **664 passed, 0 failed** (18 skipped: optional screenshot/store-image generators) — version 1.5.0 |
| On-device automated tests (`integration_test`) on Realme RMX3943 | **Passed**: full flow + UPI app detection (12 Nov 2026, version 1.1.3 code) |
| Android release build (signed App Bundle + per-ABI APKs) | **Built** |
| Install + launch of the release build on a real phone | **Passed** (no crashes logged) |
| iOS build | **Not run on this PC** (iOS can only be compiled on a Mac). Prepared: iOS Pay with UPI, privacy manifest, Info.plist (portrait, Hindi, export compliance, UPI app schemes) and a GitHub Actions workflow that compiles iOS on a cloud Mac (`.github/workflows/ci.yml`). Key flows pass in the test engine running as iOS. |

The 17 skipped tests are the optional screenshot generator in `test/screenshots`. It only runs when `PP_SCREENSHOTS` is set, and it checks nothing.

## Automated tests by group

| Group | Tests | What it covers |
|---|---|---|
| `test/domain` | 100 | iOS UPI links (gpay://upi/pay, phonepe://pay, paytmmp://pay, same parameters; apps without an iOS scheme not offered) ·  UPI QR reading and validation, pay links (amount added, signed merchant QRs untouched, `%20` not `+`) · Coin-drop animation timing · weekly limits for every everyday glass · weekly alerts re-arming each week · next salary date (incl. day 31, year change) · budget split for all 3 income bands, family mode and ₹10 rounding (total always equals income) · overflow borrowing (never takes from Savings automatically) · streaks (breaks, gaps between months, year change) · goal estimates · month rollover and salary day 31 · irregular income splitting · every badge rule · levels · low-glass and weekly-food alerts · monthly report maths |
| `test/data` | 14 | Create, read, update and delete for all 7 repositories, run against both real Hive storage and in-memory storage |
| `test/widget` | 22 | **Run as both Android and iOS:** onboarding → salary day → shelf, add expense, borrowing (never Savings), Pay with UPI. Also: Pay with UPI: amount + optional name → app list → chosen UPI app opens on its home screen (user pays there) → nothing recorded until the user comes back and taps Yes, paid · note "UPI · name" or "UPI payment" · Open another app (last app listed first) · No / failed records nothing · over the glass (Fun first, never Savings) · closing the list opens nothing · no UPI app · Savings has no Pay button · onboarding, add expense, ✕ on warnings, weekly limits, shelf (a11y, Hindi, family, font scaling, tablet) |
| `test/devices` | 550 | Device matrix + bottom-button checks, details below |

## Device matrix (`test/devices`)

Each device below was tested in **English and Hindi**. On each one the test opened every screen (Shelf, Goals, Report, Badges, Settings, Food and Savings jar details, Split editor, About, Share card) and scrolled it to the end. It also ran four flows: all onboarding steps, the salary-day animation, the Add Expense sheet and the Goal detail sheet. A test fails on any layout overflow or error.

| Device (logical size in dp) | English | Hindi |
|---|---|---|
| Small phone 320×568 (iPhone SE 1st gen, older Androids) | ✅ | ✅ |
| Compact Android 360×640 | ✅ | ✅ |
| Typical Android / Realme 360×800 | ✅ | ✅ |
| iPhone 15 393×852 | ✅ | ✅ |
| Pixel 7 412×915 | ✅ | ✅ |
| iPhone 15 Pro Max 430×932 | ✅ | ✅ |
| 7-inch tablet 600×960 | ✅ | ✅ |
| iPad Mini 744×1133 | ✅ | ✅ |
| iPad Air 820×1180 | ✅ | ✅ |
| iPad Pro 12.9" 1024×1366 | ✅ | ✅ |

Separately, every screen was also tested at **1.3× system font size** on the three smallest phones (English).

**Navigation-bar checks (200 tests).** Every test simulates a real Android status bar (24dp) and 3-button navigation bar (48dp). On every device and in both languages, a test checks that each main button is fully visible above the navigation bar:
- Save expense: without scrolling, also with the note field open
- Move money
- Goal Save and Add from savings
- Edit profile Save
- Split Save
- Share
- Fill Savings First and Go to my shelf
- Continue and Start saving

To confirm these checks are real, the original bug (Save hidden under the navigation bar) was temporarily put back. All 20 "Save expense" checks failed, for example *"Button spans 504–556 but the navigation bar starts at 520"*. The fix was then restored.

**Problems this matrix found, now fixed:**
- On the 320dp phone, the "This week" card overflowed, and so did the onboarding header and the glass labels.
- At 360×800, the onboarding glasses were 5px too wide.
- With large system fonts, the share card grew taller than its image.
- On small phones, the salary-day button was below the fold. It is now pinned to the bottom of the screen.
- On Android 15+ (edge-to-edge), the Save expense button and other bottom buttons were hidden under the navigation bar. Found on the real phone; fixed everywhere.
- The Add Expense sheet was taller than small screens, so Save scrolled out of view. Save is now pinned to the bottom of the sheet.
- On small phones, the Move money dropdowns overflowed with long glass names (Hindi included).
- On the smallest phone, the "Do you live with family?" answers were below the fold.
- The salary-day dropdown overflowed after its label changed to "Every month on day N".

**How the matrix works, and its limit:** it runs in Flutter's test engine, which simulates each screen size and font scale with the app's real layout code. This reliably catches layout problems. It does **not** run on those physical devices, so it cannot catch device-specific issues such as manufacturer battery savers delaying notifications.

## Real-device check

| Device | OS | Build | Result |
|---|---|---|---|
| Realme RMX3943 | Android 16 (API 36), screen 424×944dp, nav bar 44dp | Signed release APK (arm64) | Installed and launched. The crash log had **0** entries for the app. Package `com.pehlapaisa.app`, signed with the PehlaPaisa release key. Cold start (`am start -W`, release build): **0.8–1.0s** after the first launch. |
| Realme RMX3943 | same | Automated on-device test (`integration_test/on_device_test.dart`) | **Passed 6 of 6 runs.** The test runs onboarding, the salary-day animation and Add Expense, checks each main button is above the phone's real navigation bar, and saves a ₹85 expense. It uses in-memory data, so it never touches real user data. |

The release build asks for only these permissions: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE` (plus the standard Android receiver permission tied to the app's own package). It does **not** request `INTERNET`.

**Note on the on-device test:** it was not re-run after the latest changes (coin animation, weekly limits, ✕ on warnings). Running it installs a separate debug build, and Android must first remove the release app, which would **erase the real data** on the phone. The release build was instead updated in place (data kept), and the new screens were checked live on the phone with screenshots: the coin drop on the loading screen, the ✕ on warnings (hidden after a tap), and the weekly limits card.

**Scan & Pay on the real phone:** release 1.1.0 was installed in place (data kept) and launched with **0 crash-log entries**. The phone has these UPI apps that can receive the payment link: Google Pay, PhonePe, BHIM (Canara), Jio, Groww, WhatsApp, Amazon and super.money. **First real-phone attempt (12 Nov 2026), PhonePe:** (1) a QR of the user's *own* UPI ID was rejected with "same bank account", which is expected (nobody can pay themselves). (2) A payment to a person was rejected with "declined for security reasons". PhonePe blocks person-to-person payments that start from another app. A third attempt (another UPI app, ₹1 to a person) failed the same way, with a generic "technical issue" message. **Conclusion:** UPI apps refuse person-to-person payments started from another app. So from version 1.1.2, payments to people are **only** done inside the user's UPI app (UPI ID copied, app opened). The direct payment link is used only for shop/merchant QR codes. On this phone, the UPI apps PehlaPaisa can open are Google Pay, PhonePe, BHIM (Canara), Amazon and super.money. **A successful real payment has not been confirmed yet.** That needs a person, a real QR code and their UPI PIN (see below).

Bugs the new tests found and fixed:
- Text fields in three dialogs (UPI ID, salary amount, custom glass) were disposed while their dialog was still closing, which crashed the screen.
- A leftover "not a UPI QR" message covered the Pay button.
- Paying from a pay screen opened directly (nothing to go back to) crashed on return.

**UPI app detection on the real phone (12 Nov 2026):** version 1.1.2 wrongly said "No UPI app found on this phone". It looked for each app's home screen, which Android doesn't report this way. Version 1.1.3 asks which apps can handle a `upi://pay` payment, which is what Android's own chooser does. An on-device test confirmed it finds **8 apps**: Google Pay, PhonePe, BHIM (Canara), Amazon Pay, WhatsApp, super.money, MyJio and Groww. On-device tests now run as a separate test app (`com.pehlapaisa.app.debug`), so the real app and its data were never touched. The full on-device flow test also passed again.

**Why payments to people failed (12 Nov 2026):** UPI apps refuse person-to-person payments started by another (non-registered) app, so every pre-filled link to a person was declined. From version 1.1.4, for a person PehlaPaisa copies the UPI ID and opens the chosen UPI app's **home screen** through Android's `getLaunchIntentForPackage` (native code in `MainActivity.kt`). The user pays inside the app, which UPI allows. An on-device test confirmed the 8 apps are detected and PhonePe's home screen opens (`openHome` returned true). Shop QRs still open the app pre-filled.

**Shop payment only copied the UPI ID (13 Nov 2026):** version 1.1.4 decided "shop or person" from the QR's merchant code, but many real shop QRs (BharatPe, sticker QRs) have none, so a shop was treated as a person. From version 1.1.5 there is **no guessing**: every payment first opens the chosen app with payee and amount filled in. "Pay inside the app" (copy UPI ID + open the app) is only a backup, offered when the user says the app declined.

**Version 1.3.0 (13 Nov 2026), why payments changed:** on the real phone, a shop QR payment handed from PehlaPaisa to Google Pay failed in Google Pay with "amount not debited" (earlier PhonePe said "declined for security reasons"). Passing the QR unchanged (1.2.1) did not help. UPI apps decline payments handed over by apps that are not registered payment partners; this can't be fixed in PehlaPaisa's code. From 1.3.0, PehlaPaisa no longer sends a payment link. It opens the chosen UPI app, the user scans and pays there (a normal payment), and PehlaPaisa records it when the user confirms. The in-app camera scanner and the CAMERA permission were removed. **Confirmed on the real phone (13 Nov 2026): the user paid through Pay with UPI and it worked.**

**Version 1.4.0 (17 Nov 2026), Google AdMob ads and release check:** banner ads on Shelf and Share, native ads on Goals and Report. On the real phone (13 Nov) the app started without crashes, ads initialised, and the phone was confirmed as an AdMob test device. The first ads build crashed on start (R8 removed WorkManager's database class used by the Ads SDK); fixed with `android/app/proguard-rules.pro`. Store bundle check: signed with the upload key (CN=PehlaPaisa), versionCode 11 / 1.4.0, minSdk 24, targetSdk 36, real AdMob App ID, permissions = notifications, boot, vibrate, internet/network state, AD_ID and Android ad-services (from the Ads SDK). Real ads were not shown yet: AdMob returns "Account not approved yet" until the account and app are approved. Widget and device tests use a same-sized placeholder in each ad slot.

## Not tested yet

| Item | Why not / how to test |
|---|---|
| A manual walk-through of every screen on the physical phone | The automated on-device test covers the main flow only. Tap through the other screens once yourself. |
| Android 12+ system splash (the moment before the app draws) | It passed too quickly (under 1s) to capture in a screenshot. Check by eye that it is dark navy with no white tile. |
| Notifications actually arriving at the scheduled times | Use **Settings → Send a test notification** for an instant check. Scheduled reminders also depend on the phone's battery settings. On Realme, allow PehlaPaisa to run in the background. |
| iOS on a real iPhone | Needs a Mac (or the cloud workflow / Codemagic) and an iPhone. Check before submitting: Pay with UPI opening Google Pay, PhonePe and Paytm (schemes `gpay://`, `phonepe://`, `paytmmp://`, **not yet verified on a device**) and notifications. |
| Other physical phones and tablets | Only one physical device was available. Screen sizes are covered by the matrix above. |

## Re-running

```bash
flutter analyze
flutter test                 # everything (412)
flutter test test/devices    # device matrix only (510)
flutter test integration_test -d <device-id>   # on a connected phone (unlocked)
```
