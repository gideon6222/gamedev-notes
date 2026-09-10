# PLAY.md

Getting a game onto the Google Play Store. Written 2026-09-08, when the first native
Android build started working. **Current state, not history** — rewrite in place.

Most of this is not code. The code side is a solved problem in about twenty minutes; the
account, the paperwork and the two waiting periods are what actually decide when a game
can be published, and two of them cannot be started late.

---

## Do these two first, because they have a clock on them

**1. The 12-testers gate.** A personal developer account created after 13 November 2023
cannot publish to production until it has run a **closed test with 12 testers opted in
continuously for 14 days**. Internal testing does not count toward it, no matter how many
people or how long. Twelve real Google accounts, joined through the opt-in link, on real
devices — emulators and duplicates do not count, and a tester who opts out restarts their
own 14 days.

That is a two-week wall standing between "the game is finished" and "the game is
published", and it can be served **while the game is still being built**. Start it early
with whatever is playable.

It is a **one-time, account-level gate** — passed once, for the first app, and every game
after that publishes straight to production. Worth knowing before deciding how much effort
to spend avoiding it.

### Google does not provide testers, and there is no way to ask

There is no pool, no matching service, and no request mechanism. Twelve real Google
accounts, joined through your opt-in link, on real Android devices. Emulators, duplicate
accounts and bots do not count.

**The bigger trap is not finding twelve people — it is keeping them.** A tester who opts
out restarts *their own* 14 days, so recruit fifteen to twenty and expect churn. The clock
is the thing that bites.

**And since 2026 the review checks that the testing was real.** The production access
questionnaire asks what you learned from the test, and reviewers cross-reference tester
account age, activity history, IP addresses, device fingerprints and session lengths.
Twelve dormant installs fail. What passes is evidence of a feedback loop: testers played
it, said something, and you shipped an update during the test that acted on it.

That makes the cheap Fiverr and Telegram "12 testers for $10" services actively dangerous —
they deliver accounts that opt in and never play, which is the exact pattern the review is
built to detect, and the downside is account termination rather than a rejection. Tester
*exchange* communities, where you genuinely test other people's apps in return, are
allowed — Google does not restrict how you find testers — but the quality varies and the
churn is high.

**For a game this is an easier problem than it is for most apps.** The rule is asking for
twelve people who will actually play the thing for two weeks, and a game people might
enjoy is exactly what that is easiest to find. Friends and family who would have played it
anyway are the intended answer.

### The way around it: an organization account

**Organization accounts are exempt from the closed-testing requirement entirely.** They
publish straight to production.

The cost is paperwork: a legal business entity and a **D-U-N-S number** from Dun &
Bradstreet. A **sole trader qualifies** — no limited company needed — and the D-U-N-S
number is **free** on the standard timeline. Budget roughly three to five weeks end to end,
most of it waiting.

It also changes what appears on the store listing: apps publish under the business name
rather than a personal one.

**Which to choose.** The gate is one-time, so for a hobby account the twelve testers are
usually less total effort than four weeks of business registration — and the testers are
people who wanted to play the game anyway. Take the organization route if you want to
publish under a studio name, or if waiting two weeks at the end is worse than waiting four
weeks at the start.

**2. Developer verification.** KYC identity check, plus registering package names and
signing keys. Required now for Play *and* for sideloading. Enforcement began 30 September
2026 in Brazil, Indonesia, Singapore and Thailand, with the rest following through 2027.
There is a free **limited-distribution** tier — no fee, email signup, up to 20 explicitly
authorised devices — which is the right tier for a game that only needs to reach one phone
and a few friends.

---

## What only Gideon can do

Claude cannot and should not do any of these. They involve creating an account, paying,
proving identity, or accepting a legal agreement.

- [ ] Create the Google Play developer account — **$25, one payment, forever**
- [ ] Complete developer verification (identity documents)
- [ ] Accept the Developer Distribution Agreement
- [ ] **Enable Play App Signing** on each app — do this, see below
- [ ] Create the app entry and fill the content declarations
- [ ] Recruit 12 testers and start the closed test
- [ ] Upload the AAB to Play Console (Claude hands him the file and the release notes)

## What Claude sets up

- [x] Upload keystore, generated with a cryptographic random password
- [x] The three repository secrets, set at repo creation by `/game-scaffold` through `gh secret set`
- [x] An `Android Release` export preset producing a signed **AAB**
- [x] CI that builds, tests, size-guards and signs
- [ ] Store listing text, screenshots and the feature graphic (`/ship store`)
- [ ] Privacy policy, hosted on the game's own GitHub Pages

---

## Signing: the part that is unforgiving if you get it wrong

There are **two** keys and the difference matters.

| | Upload key | App signing key |
|---|---|---|
| Signs | the AAB you upload | the APKs Google serves to phones |
| Held by | you | Google, if Play App Signing is on |
| If lost | recoverable — ask Google to reset it | the app can never be updated again |

**Enable Play App Signing.** It converts the second row of that table from catastrophic to
an email. It is on by default for new apps; do not turn it off.

Keys live in `C:\dev\keys`, outside every repository, and `*.keystore` is in `.gitignore`
anyway. The password belongs in a password manager and the keystore wants an off-machine
copy: a disk failure should not be able to cost it.

**A throwaway key per CI run does not work.** Android refuses to install an update whose
signature changed, so a workflow that generates a fresh debug key every run produces builds
that cannot replace each other on a phone. Put the keystore in a base64 secret once the
second build matters.

### The secrets a game repo needs

| Secret | Value |
|---|---|
| `ANDROID_DEBUG_KEYSTORE_B64` | `C:\dev\keys\debug.keystore.base64.txt` |
| `ANDROID_UPLOAD_KEYSTORE_B64` | `C:\dev\keys\upload.keystore.base64.txt` |
| `ANDROID_UPLOAD_KEYSTORE_PASSWORD` | from `C:\dev\keys\UPLOAD-KEY-README.txt` |

---

## The build Play will accept

- **An AAB, not an APK.** Google builds the per-device APKs from it, which is why the
  download a player gets is smaller than what you upload.
- **AAB export requires the Gradle build** in Godot — `gradle_build/use_gradle_build=true`.
  The exporter refuses otherwise, and the Gradle build is also the only way to set the
  target SDK. Keep the debug APK preset on the prebuilt template; it needs no Gradle and
  exports in seconds, while the release preset pays ~300 MB of Gradle downloads on a cold
  run. Cache `~/.gradle` in CI.
- **`--install-android-build-template` only works alongside an export command.** On its own
  it opens the editor and never returns.
- **The release keystore comes from environment variables**, not editor settings:
  `GODOT_ANDROID_KEYSTORE_RELEASE_PATH` / `_USER` / `_PASSWORD`. Godot falls back to editor
  settings for the *debug* key only, so a release export without them fails with
  "Could not find release keystore" — a message that reads like a missing file rather than
  a missing setting.
- **Verify the target SDK from `android/build/config.gradle`, not from the bundle.** An
  AAB's manifest is protobuf rather than binary XML, so `aapt2 dump xmltree` cannot read it
  and returns nothing — and a check that passes on an empty string is worse than no check.
- **`GRADLE_OPTS=-Dorg.gradle.daemon=false`, or the export never exits.** Godot writes a
  valid bundle and then waits on the Gradle daemon Gradle forked behind it. Measured: 0%
  CPU for eight minutes with the AAB already on disk. With the daemon off, exit 0. In CI
  that is a job burning until the timeout with nothing wrong.
- **Verify the artifact, not the exit code.** This export has returned -1 having produced a
  perfectly good bundle, and returned 0 having produced nothing at all. Assert the file
  exists, is a plausible size, and passes `jarsigner -verify`. An exit code is a proxy; the
  bundle is the thing.
- **Target API 36 (Android 16)** for new apps and updates from 31 August 2026. Existing
  apps below API 35 become invisible to new users on newer devices. **This rises every
  year** — it is a recurring maintenance item, not a one-off.
- **64-bit is required.** arm64-v8a only is fine and halves the native payload.
- Every release needs a **higher `version/code`** than the last.

---

## The listing

Mandatory before a store listing can be published:

| Asset | Spec |
|---|---|
| App icon | **512 × 512**, 32-bit PNG with alpha, sRGB, max 1024 KB. Google adds the rounded corners and shadow — do not draw them |
| Feature graphic | **1024 × 500**, JPEG or 24-bit PNG, **no transparency**. Required for every app |
| Phone screenshots | **at least 2**, up to 8. 1080 × 1920 works; each side 320–3840 px, aspect no wider than 2:1. JPEG or 24-bit PNG |
| Short description | 80 characters |
| Full description | 4000 characters |

Tablet screenshots are optional. Screenshots come straight off the phone with
`adb shell screencap -p /sdcard/x.png` then `adb pull` — the S26 Ultra's native resolution
is already a valid size.

## Privacy policy and data safety

**Every app needs a privacy policy URL, including one that collects nothing.** The Data
safety form is separate from it and the two must agree.

For a game with no analytics, no ads, no accounts and no network calls, both are short:
nothing is collected, nothing is shared. Host the policy on the game's own GitHub Pages so
it has a stable URL and lives in the same repo as the thing it describes.

**The mistake to avoid: third-party SDKs count.** Any analytics, crash reporting, ads,
attribution or backend SDK linked into the app must be declared, whatever it does with the
data. A game that genuinely links none of them can honestly declare none — and that is
worth protecting deliberately, because it keeps this section a two-minute job forever.

---

## Order of operations, once there is a game

1. Gideon creates the developer account and completes verification.
2. Create the app in Play Console. Enable Play App Signing.
3. Fill the content declarations: privacy policy URL, data safety, content rating
   questionnaire, target audience, ads declaration, app access.
4. Add the repository secrets; CI produces a signed AAB.
5. Upload to **internal testing** — up to 100 testers, no review wait. This is the fastest
   way to get the game onto the phone through Play, with automatic updates.
6. Start the **closed test** and leave it running 14 days with 12 testers.
7. Apply for production access, then release.

Steps 5 and 6 can both be running while the game is still being worked on.
