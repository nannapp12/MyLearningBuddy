# My Learning Buddy

A free early-learning app and website for children aged 2–6, built with Flutter
(one codebase for iOS, Android and web). See [requirements.md](requirements.md)
for the full product requirements.

## What's built so far

- Home screen with tabs: Words (Level 1 and Level 2), Phrases (Greetings, Activities, Feelings), Tracing (Shapes,
  Letters, Numbers), Games (Find It, Memory), Nursery Rhymes (10) and Short Stories (12 fairy tales and fables,
  one line at a time). Tracing has no voice; stories and rhymes are read aloud only with Auto-read on
- Card viewer for each section: swipe or big arrow buttons, item name and picture
  - Letters (Aa–Zz, each a different colour); Numbers 1–20 with a different object to count each time ("seven strawberries")
  - Words: one card per letter showing all 5 words; tap a picture to hear it
  - Shapes in different colours, Days of the Week (Monday to Sunday), Colors (swatch + object)
  - Farm Animals and Wild Animals (whole animals), Vehicles, Fruits, Vegetables, Food, At the Park, In the
    School, Clothing, Sports, Appliances (names only, no sounds), and Time (1 to 12 o'clock)
- 12 more sections: Body Parts, Family, Emotions, Opposites (both words on one card), Weather and
  Seasons, Months, Birds, Sea Creatures, Insects, Community Helpers, Things Around the House, Places
  We Visit – at most 10 items each (12 for Months)
- Voice: every item, section name and "Great job!" is spoken in a slow, friendly female voice,
  plus a chime when a star is earned
- Tracing: pick a shape, A–Z, a–z or 1–20, trace over a faint guide with crayon colours and two line
  widths, and move on with the next button
- A home button on every screen returns to the main menu; a speaker button says the card again
- Games: **Find It** ("Can you find the cow?") and **Memory** (find the 4 pairs among 8 face-down cards)
- **Phrases**: Greetings (11), Activities (10) and Feelings (12), and **Easy / Medium / Hard** modes (first 5, 8 or all items)
- **Auto-read** button: reads each card, waits 5 seconds and moves on; also reads stories and rhymes aloud, slowly
- The puppy says "Hi! How are you?" on start and "This is fun!" back on the main menu
- Rewards: at the end of each section, game and the last tracing letter, an animated puppy hops around
  and cheers, then the child picks one of 5 stickers, shown in a sticker bar under the title
- Parent area behind a simple sum: show/hide each section, speech and sound-effect switches
- Nothing is saved: stars and settings reset when the app or web page is closed

## Not done yet

- **Pictures:** most pictures are emoji placeholders; the lion, zebra, bear, school bus,
  cauliflower, dragonfly, zoo, aquarium, police station, zip, zigzag and Jan 1 calendar are our own
  drawings in `assets/images/`. (The emoji font, Noto Color Emoji under the SIL Open Font License, is served from
  `web/fonts/` so the website makes no requests to other servers.)
- **Tracing:** stroke-order hints and checking that the child stayed on the path.
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

The puppy's greetings and rewards use a second, livelier voice (`af_nova`, pitched up 4 semitones to
sound like a child), saved in `assets/audio/puppy/`. The list of puppy lines is `Speech.mascot` in
`lib/services/speech.dart` and `MASCOT_LINES` in the script.

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
