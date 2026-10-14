# My Learning Buddy – Product Requirements

- **Version:** 0.3 (Draft)
- **Platforms:** Mobile app (iOS / Android, tablet-friendly) and website
- **Audience:** Children aged 2–6, with parents and teachers as supervisors
- **Price:** Free to the user

---

## 1. Overview

My Learning Buddy is a free early-learning app and website that helps children
aged 2–6 learn letters, numbers, words, shapes, days, colors and everyday things
through pictures, sounds, touch and play.

### Key decisions

| Topic | Decision |
|---|---|
| Age range | 2–6 years |
| Price | Free to the user |
| Voice | Female voice, English |
| Language | English only |
| Child profiles | Not included |
| Saving progress | Not saved – every visit starts fresh (see section 2) |
| Accounts / login | None |
| Privacy | Follow all applicable children's privacy and safety laws (see section 9) |

Every learning section must, at minimum, support:

- A picture or illustration for every item
- The item's name shown as text
- Audio pronunciation (female voice, English) when the item is tapped
- Simple next/previous navigation (swipe on touch devices, arrows on the web)

---

## 2. Session Model (No Saved Progress)

- The app and website are **stand-alone sessions**: each time they are opened, they start fresh.
- Progress, stars, stickers and badges exist **only while the app or website is open**.
- When the app is closed or the web page is closed/refreshed, all progress and rewards reset.
- No user accounts, no login, and no progress stored on a server.

---

## 3. Learning Sections

### 3.1 Letters
- Uppercase: A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
- Lowercase: a b c d e f g h i j k l m n o p q r s t u v w x y z
- Show uppercase and lowercase pairs together (e.g. "Aa")
- Audio: letter name, plus letter sound (phonics)

### 3.2 Numbers (1–20)
- 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
- Show the numeral, the number word (e.g. "seven") and a matching count of objects
- Audio: number name

### 3.3 Words (5 per letter)

| Letter | Words |
|---|---|
| A | Apple, Ant, Airplane, Alligator, Arrow |
| B | Ball, Bat, Banana, Bird, Bus |
| C | Cat, Car, Cake, Cup, Cow |
| D | Dog, Duck, Door, Drum, Doll |
| E | Egg, Elephant, Ear, Eagle, Envelope |
| F | Fish, Frog, Flower, Fan, Fork |
| G | Goat, Grapes, Girl, Gift, Guitar |
| H | Hat, House, Horse, Hen, Hand |
| I | Ice cream, Igloo, Insect, Iron, Ink |
| J | Jug, Jam, Jeep, Jellyfish, Juice |
| K | Kite, King, Key, Kangaroo, Kitten |
| L | Lion, Lamp, Leaf, Lemon, Ladder |
| M | Monkey, Moon, Mango, Mouse, Milk |
| N | Nest, Nose, Nut, Net, Nurse |
| O | Orange, Owl, Octopus, Onion, Ox |
| P | Pen, Pig, Parrot, Pencil, Pumpkin |
| Q | Queen, Quilt, Question mark, Quail, Quarter |
| R | Rabbit, Rainbow, Ring, Rose, Robot |
| S | Sun, Star, Snake, Sock, Ship |
| T | Tiger, Tree, Train, Table, Tomato |
| U | Umbrella, Unicorn, Uniform, Up, Under |
| V | Van, Violin, Vase, Vest, Volcano |
| W | Watch, Whale, Window, Watermelon, Wolf |
| X | Xylophone, X-ray, Box, Fox, Six |
| Y | Yak, Yo-yo, Yarn, Yogurt, Yacht |
| Z | Zebra, Zoo, Zip, Zero, Zigzag |

- Each word: picture + text (with the target letter highlighted) + audio
- Few kid-friendly words start with X, so Box, Fox and Six show X at the end of the word

### 3.4 Tracing
- Touch-screen tracing on mobile/tablet; mouse, stylus or touch on the website
- Traceable content: uppercase A–Z, lowercase a–z, numbers 1–20
- Dotted guide outline with stroke order and a start point
- Detect whether the child stays roughly on the path; positive feedback (sound/animation) on completion
- "Clear" / "Try again" button
- Choice of crayon color and line thickness

### 3.5 Shapes (10)
Circle, Square, Triangle, Rectangle, Oval, Star, Heart, Diamond, Pentagon, Hexagon

### 3.6 Days of the Week
Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
- Show in order; highlight "today"

### 3.7 Farm Animals (10)
Cow, Horse, Pig, Sheep, Goat, Chicken (Hen), Duck, Dog, Cat, Donkey
- Audio: animal name + animal sound

### 3.8 Wild Animals (10)
Lion, Tiger, Elephant, Giraffe, Zebra, Monkey, Bear, Kangaroo, Hippopotamus, Crocodile
- Audio: animal name + animal sound

### 3.9 Vehicles (10)
Car, Bus, Truck, Bicycle, Motorcycle, Train, Airplane, Boat (Ship), Helicopter, Fire Truck
- Audio: vehicle name + vehicle sound

### 3.10 Fruits (10)
Apple, Banana, Orange, Mango, Grapes, Strawberry, Watermelon, Pineapple, Pear, Cherry

### 3.11 Vegetables (10)
Carrot, Potato, Tomato, Onion, Cabbage, Cauliflower, Peas, Corn, Cucumber, Broccoli

### 3.12 Colors (10)
Red, Blue, Yellow, Green, Orange, Purple, Pink, Brown, Black, White
- Show a color swatch plus a familiar object of that color

---

## 4. Activities and Games

- **Quizzes:** "Tap the red apple", "Which one is the cow?", "Find the letter B"
- **Matching pairs:** memory card game (picture-to-picture, letter-to-word, uppercase-to-lowercase)
- **Sound to picture:** play a sound (animal, vehicle) and the child taps the matching picture
- **Counting games:** count the objects and tap the right number
- **Drag and drop:** put shapes in matching holes, sort fruits vs. vegetables, simple jigsaw puzzles
- **Coloring pages:** color in animals, vehicles, shapes, etc. with a tap-to-fill or brush tool
- Games use content from the learning sections

---

## 5. Rewards and Motivation

- Stars or stickers earned for completing items, tracing and games
- Sticker book screen to view rewards earned during the current session
- Progress badges per section (e.g. "Alphabet Star", "Number Champ")
- Celebration animations and sounds on success
- Encouraging (never negative) feedback on wrong answers – e.g. "Try again!"
- Rewards are **not saved**: they reset when the app or website is closed (see section 2)

---

## 6. Audio

- **Voice:** a clear, friendly female voice
- **Language:** English only
- Letter names **and** letter sounds (phonics)
- Captions: the text of what is spoken is always shown on screen
- Separate volume / mute controls for speech and for music and sound effects

---

## 7. Parent Area

- Protected by a parental lock (e.g. "solve this sum" or press-and-hold) so children can't enter
- **Show / hide categories:** parents can turn each learning section (3.1–3.12) and each game on or off;
  hidden categories do not appear on the child's home screen
- Sound settings (speech volume, music / effects on or off)
- No progress reports (progress is not saved)

---

## 8. Accessibility

- Large touch targets suited to small fingers
- High-contrast mode
- Easier tracing settings (wider path tolerance, thicker guide lines)
- Dyslexia-friendly font option
- Screen-reader support where practical
- Avoid flashing or fast-moving animations; option to reduce motion

---

## 9. Privacy and Safety

The product must follow all applicable children's privacy and safety laws and
store rules, including:

- **COPPA** (United States – Children's Online Privacy Protection Act)
- **GDPR / GDPR-K** (European Union) and **UK GDPR + Age Appropriate Design Code** (United Kingdom)
- Other local equivalents in each country where it is released
- **Apple App Store Kids Category** rules and **Google Play Families Policy**

Requirements that follow from this:

- **No personal data collected** – no names, emails, accounts, photos, voice recordings or location
- No user tracking, no advertising IDs, and no third-party tracking or analytics SDKs
- **No ads**
- **No in-app purchases**
- No chat, messaging or contact with other users
- No external links or social sharing for children; any link (e.g. privacy policy) sits behind the parental lock
- No microphone or camera access
- A clear, simple privacy policy for parents, published on the website and the app store listings
- Website: no cookies other than strictly necessary ones (so no cookie banner is needed)

---

## 10. Technical Requirements

- Same content and sections on the app and the website
- Prefer one shared codebase for app and web (e.g. Flutter, or React Native + web) – to be decided
- No backend database, user accounts or login; no progress stored on servers
- App works offline once installed
- Runs smoothly on low-cost tablets and older phones; small download size
- Works in portrait and landscape on phones and tablets
- Website works in modern desktop and mobile browsers
- Content (pictures, audio, word lists) stored as data files, not hard-coded, so it is easy to add more

---

## 11. Business and Operations

- Free to the user: no ads, no in-app purchases, no subscription
- Follow app store rules for kids' apps (Apple Kids Category, Google Play Families Policy)
- Source of images and audio: create in-house, commission, or license – confirm the licence allows free distribution in an app and website
- Feedback channel for parents (e.g. a contact email shown behind the parental lock)
- Running costs to plan for (paid by the owner, not the user):
  - Apple Developer Program (about US$99 per year)
  - Google Play developer account (one-time US$25)
  - Website domain name and hosting

---

## 12. Future Ideas (Not in Current Scope)

These were considered and left out for now:

- Additional learning sections: Body Parts, Family Members, Emotions, Opposites, Weather, Seasons,
  Months, Birds, Sea Creatures, Insects, Community Helpers, Food, Things Around the House
- Child profiles and age-based levels
- Saved progress, progress reports and sync across devices
- Multiple languages and voices

---

## 13. Open Items / To Be Decided

- Should the parent's show/hide choices be remembered on the device between visits, or reset like everything else?
- Technology stack for app and website
- Art style and app character / mascot (and the app's name / logo)
- Where images and audio will come from (create, commission or license); who records the female voice
  or whether to use a text-to-speech voice
- Which sections and games are in the first release vs. later releases
- Countries to release in at launch
- Whether the website should also work offline
- Should the parent area include an optional screen-time / break reminder?
