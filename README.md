# My Learning Buddy

A free early-learning app and website for children aged 2–6, built with Flutter
(one codebase for iOS, Android and web). See [requirements.md](requirements.md)
for the full product requirements.

## What's built so far

- Home screen with the 12 learning sections as big picture tiles
- Card viewer for each section: swipe or big arrow buttons, item name and picture
  - Letters (Aa–Zz), Numbers 1–20 with objects to count, Words (5 per letter, target letter highlighted)
  - Shapes (drawn in code), Days of the Week (opens on today, marked "Today"), Colors (swatch + object)
  - Farm Animals, Wild Animals, Vehicles, Fruits, Vegetables
- Tracing: pick A–Z, a–z or 1–20, trace over a faint guide with crayon colours and two line widths
- Rewards: a star for finishing each section or tracing a character, with a "Great job!" celebration
- Parent area behind a simple sum: show/hide each section, speech and sound-effect switches
- Nothing is saved: stars and settings reset when the app or web page is closed

## Not done yet

- **Pictures:** emoji are temporary placeholders. They will be replaced with free public-domain
  cartoon clip art. On the website the emoji font is downloaded from Google, which must not happen
  in the released product.
- **Audio:** `lib/services/audio_service.dart` is a stub. Pre-generated clips from a free
  text-to-speech tool (female, US English) still need to be made and bundled.
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
| `test/` | Content checks and widget tests |

## Running it

Install [Flutter](https://docs.flutter.dev/get-started/install) (stable channel), then:

```sh
flutter pub get
flutter test                 # run the tests
flutter run -d chrome        # run the website locally
flutter run                  # run on a connected phone/tablet or emulator
```

Build the website so it loads nothing from outside servers:

```sh
flutter build web --no-web-resources-cdn
```
