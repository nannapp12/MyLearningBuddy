# My Learning Buddy – Product Requirements

- **Version:** 1.0 (Ready to build)
- **Platforms:** Mobile app (iOS / Android, tablet-friendly) and website
- **Audience:** Children aged 2–6, with parents and teachers as supervisors
- **Price:** Free to the user
- **Release country:** United States only
- **Technology:** Flutter (one codebase for iOS, Android and web)

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
| Voice | Free text-to-speech tool, female voice, US English |
| Language | English only |
| Child profiles | Not included |
| Saving progress | Nothing is saved – every visit starts fresh (see section 2) |
| Games | Not in the first release – learning sections only |
| Images | Free public-domain cartoon clip art (e.g. OpenClipart) |
| Mascot | None |
| Release country | United States only |
| Technology | Flutter |
| Accounts / login | None |
| Privacy | Follow all applicable children's privacy and safety laws (see section 8) |

Every learning section must, at minimum, support:

- A picture or illustration for every item
- The item's name shown as text
- Audio pronunciation (computer-generated female voice, English) when the item is tapped
- Simple next/previous navigation (swipe on touch devices, arrows on the web)

---

## 2. Session Model (No Saved Progress)

- The app and website are **stand-alone sessions**: each time they are opened, they start fresh.
- Progress, stars, stickers, badges **and parent settings (show/hide, sound)** exist **only while the app or website is open**.
- When the app is closed or the web page is closed/refreshed, everything resets to the defaults
  (all categories shown, sound on).
- Nothing is stored on the device or on a server.
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

## 4. Rewards and Motivation

- Stars or stickers earned for viewing items in a section and completing tracing
- Sticker book screen to view rewards earned during the current session
- Progress badges per section (e.g. "Alphabet Star", "Number Champ")
- Celebration animations and sounds on success
- Encouraging (never negative) feedback when tracing goes off the path – e.g. "Try again!"
- Rewards are **not saved**: they reset when the app or website is closed (see section 2)

---

## 5. Audio

- **Voice:** a clear, friendly, computer-generated (text-to-speech) female voice
- **Language:** English (US)
- Audio clips are generated ahead of time and bundled with the app/website, so the voice sounds the same
  on every device, works offline and sends no data to any speech service while the child uses the app
- Use a **free** text-to-speech tool whose terms allow the generated audio to be used in a free app and website
- The owner approves a sample of the voice before all audio clips are generated
- Letter names **and** letter sounds (phonics)
- Captions: the text of what is spoken is always shown on screen
- Separate volume / mute controls for speech and for music and sound effects

---

## 6. Parent Area

- Protected by a parental lock (e.g. "solve this sum" or press-and-hold) so children can't enter
- **Show / hide categories:** parents can turn each learning section (3.1–3.12) on or off;
  hidden categories do not appear on the child's home screen
- Sound settings (speech volume, music / effects on or off)
- Settings apply to the current visit only and reset when the app or website is closed (see section 2)
- No progress reports (progress is not saved)
- No screen-time or break reminder

---

## 7. Accessibility

- Large touch targets suited to small fingers
- High-contrast mode
- Easier tracing settings (wider path tolerance, thicker guide lines)
- Dyslexia-friendly font option
- Screen-reader support where practical
- Avoid flashing or fast-moving animations; option to reduce motion

---

## 8. Privacy and Safety

The product is released in the United States only and must follow all applicable
children's privacy and safety laws and store rules, including:

- **COPPA** (Children's Online Privacy Protection Act) and the FTC's COPPA Rule
- US state privacy laws that cover children (e.g. California's CCPA/CPRA and similar state laws)
- **ADA** accessibility expectations for the website (see section 7)
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
- Website: no cookies and no browser storage

---

## 9. Technical Requirements

- Same content and sections on the app and the website
- **Flutter** – one shared codebase for the iOS app, Android app and website
- No backend database, user accounts or login; nothing stored on servers or on the device
- App works offline once installed
- Runs smoothly on low-cost tablets and older phones; small download size
- Works in portrait and landscape on phones and tablets
- Website works in modern desktop and mobile browsers
- Website loads nothing from third-party servers (rendering engine, fonts and pictures are all served
  from our own site), so no data about visitors reaches anyone else
- Content (pictures, audio, word lists) stored as data files, not hard-coded, so it is easy to add more

---

## 10. Business and Operations

- Free to the user: no ads, no in-app purchases, no subscription
- Release in the United States only (App Store and Google Play availability set to US)
- Follow app store rules for kids' apps (Apple Kids Category, Google Play Families Policy)
- **Images:** free public-domain (CC0) cartoon clip art, e.g. from OpenClipart; every image's licence must
  allow use in an app and website. Keep a record of each image's source
  and licence, and give credit where the licence requires it (e.g. on a credits page behind the parental lock)
- **Audio:** female voice from a free text-to-speech tool (see section 5)
- **No mascot / app character**; branding is the name "My Learning Buddy"
- Feedback channel for parents (e.g. a contact email shown behind the parental lock)
- Running costs to plan for (paid by the owner, not the user):
  - Apple Developer Program (about US$99 per year)
  - Google Play developer account (one-time US$25)
  - Website domain name and hosting

---

## 11. Future Ideas (Not in Current Scope)

These were considered and left out for now:

- Activities and games: quizzes, matching pairs, sound to picture, counting, drag and drop, coloring pages
- Additional learning sections: Body Parts, Family Members, Emotions, Opposites, Weather, Seasons,
  Months, Birds, Sea Creatures, Insects, Community Helpers, Food, Things Around the House
- Child profiles and age-based levels
- Saved progress, progress reports and sync across devices
- Multiple languages and voices
- Remembering parent settings between visits
- Screen-time / break reminder

---

## 12. Open Items / To Be Decided

None – all requirements decisions are made. Remaining choices (exact text-to-speech tool and
individual clip-art images) are made during building, within the rules above.
