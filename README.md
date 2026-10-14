# My Learning Buddy

A free early-learning app and website for children aged 2–6, built with Flutter
(one codebase for iOS, Android and web). See [requirements.md](requirements.md)
for the full product requirements.

## What's built so far

- Home screen with the 12 learning sections as big picture tiles
- Card viewer for each section: swipe or big arrow buttons, item name and picture
  - Letters (Aa–Zz, each a different colour); Numbers 1–20 with a different object to count each time ("seven strawberries")
  - Words: one card per letter showing all 5 words; tap a picture to hear it
  - Shapes in different colours, Days of the Week (Monday to Sunday), Colors (swatch + object)
  - Farm Animals and Wild Animals (whole animals), Vehicles, Fruits, Vegetables (names only, no sounds)
- Voice: every item, section name and "Great job!" is spoken in a slow, friendly female voice,
  plus a chime when a star is earned
- Tracing: pick A–Z (then 1–10), a–z or 1–20, trace over a faint guide with crayon colours and two line
  widths, and move on with the next button
- A home button on every screen returns to the main menu
- Rewards: a star for finishing each section or tracing a character, with a "Great job!" celebration
- Parent area behind a simple sum: show/hide each section, speech and sound-effect switches
- Nothing is saved: stars and settings reset when the app or web page is closed

## Not done yet

- **Pictures:** most pictures are emoji placeholders; the lion, zebra, bear, school bus and
  cauliflower are our own drawings in `assets/images/`. Some words (e.g. Igloo, Zoo) still show only
  their letter. (The emoji font, Noto Color Emoji under the SIL Open Font License, is served from
  `web/fonts/` so the website makes no requests to other servers.)
- **Tracing:** stroke-order hints and checking that the child stayed on the path.
- **Rewards:** sticker book and section badges.
- **Accessibility:** high-contrast mode, dyslexia-friendly font, reduce-motion option.
- App icons, store listings and the privacy policy.

## Project layout

| Path | What it is |
|---|---|
| `assets/content/content.json` | All learning content (sections, items, words). Edit this to change content. |
| `lib/models/content.dart` | Reads `content.json` |
| `lib/state/app_state.dart` | In-memory stars and parent settings |
| `lib/screens/` | Home, section viewer, word/tracing pickers, tracing canvas, parent area |
| `lib/widgets/` | Item card, shapes, star counter, celebration popup |
| `assets/audio/` | Voice clips (one per sentence) and sound effects |
| `assets/images/` | SVG pictures drawn for the app |
| `lib/services/speech.dart` | What the app says aloud |
| `tool/generate_audio.py` | Makes the voice clips (see below) |
| `test/` | Content, speech and widget tests |

## Running it

Install [Flutter](https://docs.flutter.dev/get-started/install) (stable channel), then:

```sh
flutter pub get
flutter test                 # run the tests
flutter run -d chrome        # run the website locally
flutter run                  # run on a connected phone/tablet or emulator
```

## Voice clips

The voice is **Kokoro-82M** (free, Apache-2.0 licence), voice `af_heart` (US English, female),
at 0.75 speed so it is easy for young children to follow. Each clip is recorded after a short
lead-in ("Okay...") that is then cut off, because Kokoro adds a faint "uh" at the very start of
a recording, which made single words sound like "a horse". Clips are made ahead of time and
bundled, so the app works offline and sends nothing to a speech service.

After changing `content.json`, run `tool/generate_audio.py` (setup steps are at the top of the
script) to make clips for any new sentences. `flutter test` fails if a clip is missing.

## Building

Build the website so it loads nothing from outside servers:

```sh
flutter build web --no-web-resources-cdn
```

## Deploying the website (Vercel)

`vercel.json` tells Vercel how to build the site: it downloads Flutter 3.47.7, runs
`flutter build web`, and serves the `build/web` folder. In the Vercel project settings, leave
**Root Directory** empty (the repository root) and **Framework Preset** as "Other". Vercel then
rebuilds the site on every push to `main`.
