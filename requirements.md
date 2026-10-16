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
| Voice | Free text-to-speech tool, female voice, US English; the puppy has its own livelier, child-like voice |
| Language | English only |
| Child profiles | Not included |
| Saving progress | Nothing is saved – every visit starts fresh (see section 2) |
| Games | Find It (see section 4a) |
| Images | Free public-domain cartoon clip art (e.g. OpenClipart) |
| Helper character | A friendly cartoon puppy that celebrates at the end of each section and game |
| Release country | United States only |
| Technology | Flutter |
| Accounts / login | None |
| Privacy | Follow all applicable children's privacy and safety laws (see section 8) |

Every learning section must, at minimum, support:

- A picture or illustration for every item
- The item's name shown as text
- Audio pronunciation (computer-generated female voice, English) when the item is tapped
- Simple next/previous navigation (swipe on touch devices, arrows on the web)
- A home button at the bottom of every screen inside a section, to return to the main menu
- A large back button at the top left of every screen inside a section

---

## 1a. Home Screen

- Title "My Learning Buddy" in big, bold letters, each letter a different colour, in the Fredoka font
  (free, SIL Open Font License, bundled with the app)
- The puppy next to the title. Tapping the puppy or the title (on any screen that shows it) goes to the
  main menu, where the puppy hops in and says "This is fun!"
- A soft pop sound for taps on the main menu (section tiles, mode buttons, title)
- Sticker bar under the title, then three mode buttons – **Easy** 🐣, **Medium** 🐥, **Hard** 🦢 (a swan) – only one can be
  picked (default Easy, resets when the app is closed):
  - Easy: each section shows only its first 5 items (e.g. letters A–E, Words A–E, tracing A–E)
  - Medium: the first 8
  - Hard: everything
  Find It uses the same limit when choosing pictures. Days of the Week always shows all 7 days, and
  short stories are always read to the end
- One big picture tile per section; tile pictures must not be cut off at the edges
- The tiles are grouped under four sub-headings, in this order:
  - **Learning:** Letters, Numbers, Words, Farm Animals, Wild Animals, Birds, Sea Creatures, Insects,
    Vehicles, Fruits, Vegetables, Food, Colors, Shapes, Days of the Week, Months, Weather and Seasons,
    Body Parts, Family, Emotions, Community Helpers, Places We Visit, Things Around the House, At the Park,
    In the School, Opposites, Phrases
  - **Tracing:** Shapes, Letters, Numbers
  - **Games:** Find It
  - **Short Stories:** Hansel & Gretel, Red Riding Hood, Cinderella, Sleeping Beauty, Beauty & the Beast
- Fruits tile is yellow
- When the app or website opens, the puppy says "Hi! How are you?" (on the website it waits for the first
  tap, because browsers only allow sound after a tap); each time the child comes back to the main menu,
  the puppy hops in and says "This is fun!"

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

To keep each section easy to learn, a section has **at most 10 items**, except where the
subject needs more (letters, numbers, words, tracing letters and numbers, and the 12 months).

### 3.1 Letters
- Uppercase: A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
- Lowercase: a b c d e f g h i j k l m n o p q r s t u v w x y z
- Show uppercase and lowercase pairs together (e.g. "Aa")
- Each letter in a different colour
- Audio: letter name, plus letter sound (phonics)

### 3.2 Numbers (1–20)
- 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
- Show the numeral, the number word and a matching count of objects
- Use a different everyday object for each number, named on screen and aloud (e.g. "7 – seven strawberries")
- Audio: the count only, said once (e.g. "Seven strawberries.")

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
| I | Ice cream, Ice Cube, Insect, Ivy, Ink Pen |
| J | Jeans, Jacket, Jeep, Jellyfish, Juice |
| K | Kite, King, Key, Kangaroo, Kitten |
| L | Lion, Lamp, Leaf, Lemon, Ladder |
| M | Monkey, Moon, Mango, Mouse, Milk |
| N | Nest, Nose, Nut, Net, Nurse |
| O | Orange, Owl, Octopus, Onion, Ox |
| P | Pen, Pig, Parrot, Pencil, Pumpkin |
| Q | Queen, Quiet, Question mark, Quill, Quarter |
| R | Rabbit, Rainbow, Ring, Rose, Robot |
| S | Sun, Star, Snake, Sock, Ship |
| T | Tiger, Tree, Train, Teapot, Tomato |
| U | Umbrella, Unicorn, Upset, Up, Uncle |
| V | Van, Violin, Vase, Vest, Volcano |
| W | Watch, Whale, Window, Watermelon, Wolf |
| X | X-mas Tree, X-ray, Box, Fox, Six |
| Y | Yellow, Yo-yo, Yarn, Yolk, Yacht |
| Z | Zebra, Zoo, Zip, Zero, Zigzag |

- Any word still waiting for its picture shows an "Image to be added" placeholder
- One card per letter showing all 5 words together; each word has a picture + text (with the target letter highlighted)
- Opening a letter's card reads the letter, then each of its 5 words with a 3-second pause between them
- Tapping a word's picture says just that word (and stops the read-out)
- Few kid-friendly words start with X, so Box, Fox and Six show X at the end of the word
- "X-mas Tree" is said as "ex-mas tree"

### 3.4 Tracing
- Touch-screen tracing on mobile/tablet; mouse, stylus or touch on the website
- Three tiles under the **Tracing** heading:
  - **Shapes:** every shape from the Shapes section (including the lines and signs), picked from a grid
    of shape pictures
  - **Letters:** uppercase A–Z and lowercase a–z (two lists)
  - **Numbers:** 1–20
- **No voice in tracing** (owner's choice): no section name and no "Trace the …" prompt
- A next button moves on to the next shape, letter or number in the list
- Tapping "Great job!" after tracing moves on to the next one; after the last one, the puppy and stickers
- Dotted guide outline with stroke order and a start point
- Detect whether the child stays roughly on the path; positive feedback (sound/animation) on completion
- "Clear" / "Try again" button
- Choice of crayon color and line thickness

### 3.5 Shapes (17)
Circle, Square, Triangle, Rectangle, Oval, Star, Heart, Diamond, Pentagon, Hexagon, then lines and signs:
Vertical Line, Horizontal Line, Plus, Minus, Cross, Check, Equal
- Each shape in a different colour; lines and signs are drawn as thick bars so they can be traced
- Easy and Medium show only the first 5 or 8; Hard shows all 17

### 3.6 Days of the Week
Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
- Show in order from Monday to Sunday, with no reference to today's date
- Always all 7 days, whatever the Easy / Medium / Hard mode
- Each day in its own colour
- The section's tile shows a calendar page for January 1

### 3.7 Farm Animals (10)
Cow, Horse, Pig, Sheep, Goat, Chicken (Hen), Duck, Dog, Cat, Donkey
- Show the whole animal, not just its head
- Audio: animal name only (no animal sounds)

### 3.8 Wild Animals (10)
Lion, Tiger, Elephant, Giraffe, Zebra, Monkey, Bear, Kangaroo, Hippopotamus, Crocodile
- Show the whole animal, not just its head
- Audio: animal name only (no animal sounds)

### 3.9 Vehicles (10)
Car, Bus, Truck, Bicycle, Motorcycle, Train, Airplane, Ship, Helicopter, Fire Truck
- Bus: a yellow school bus
- Train: side view showing the engine and its railcars
- Audio: vehicle name only (no vehicle sounds)

### 3.10 Fruits (10)
Apple, Banana, Orange, Mango, Grapes, Strawberry, Watermelon, Pineapple, Pear, Cherry

### 3.11 Vegetables (10)
Carrot, Potato, Tomato, Onion, Cabbage, Cauliflower, Peas, Corn, Cucumber, Broccoli

### 3.11a Food (10)
Pizza, Bread, Cheese, Rice, Pasta, Egg, Milk, Pancakes, Sandwich, Soup
- Names only, one emoji picture each; listed after Vegetables on the home screen

### 3.12 Colors (10)
Red, Blue, Yellow, Green, Orange, Purple, Pink, Brown, Black, White
- Show a color swatch plus a familiar object of that color

### 3.13 Body Parts (10)
Eye, Ear, Nose, Mouth, Teeth, Tongue, Hand, Arm, Leg, Foot

### 3.14 Family (8)
Mother, Father, Baby, Sister, Brother, Grandmother, Grandfather, Family

### 3.15 Emotions (10)
Happy, Sad, Angry, Scared, Surprised, Sleepy, Silly, Excited, Calm, Worried

### 3.16 Opposites (10 pairs)
Big / Small, Hot / Cold, Up / Down, Day / Night, Happy / Sad, Fast / Slow, Open / Closed,
Loud / Quiet, Hard / Soft, Stop / Go
- Both words on one card, side by side, each with a picture (e.g. a big elephant and a small mouse)
- Audio: both words with a clear pause (about 1 second) between them, e.g. "Big … Small."

### 3.17 Weather and Seasons (10)
Weather: Sunny, Cloudy, Rainy, Snowy, Windy, Stormy. Seasons: Spring, Summer, Fall, Winter

### 3.18 Months (12)
January to December, each with a picture for that time of year (e.g. a pumpkin for October)

### 3.19 Birds (10)
Parrot, Owl, Eagle, Penguin, Flamingo, Peacock, Swan, Dove, Turkey, Duck

### 3.20 Sea Creatures (10)
Fish, Whale, Dolphin, Shark, Octopus, Crab, Jellyfish, Seal, Sea Turtle, Lobster

### 3.21 Insects (10)
Butterfly, Bee, Ant, Ladybug, Caterpillar, Beetle, Cricket, Fly, Mosquito, Dragonfly

### 3.22 Community Helpers (10)
Doctor, Nurse, Firefighter, Police Officer, Teacher, Farmer, Chef, Pilot, Mechanic, Construction Worker

### 3.23 Things Around the House (10)
Bed, Chair, Sofa, Door, Window, Clock, Toothbrush, Bathtub, Television, Broom

### 3.23a At the Park (10)
Slide, Swing, Kite, Ball, Bicycle, Tree, Flowers, Picnic Basket, Ice Cream, Duck
- Listed after Things Around the House; the swing is the project's own drawing

### 3.23b In the School (10)
Teacher, Book, Pencil, Crayons, Backpack, Scissors, Ruler, Chair, Globe, School Bus

### 3.24 Places We Visit (10)
Zoo, Aquarium, Police Station, School, Hospital, Library, Playground, Beach, Grocery Store, Farm

### 3.25 Phrases (10)
How are you? · I am doing well · This is fun · I am happy · I like playing · I am eating ·
Please and thank you · Good Morning · Good night · See you later
- One phrase per card with a matching picture; the voice says the phrase, and the child taps next to
  move on (no auto-advance)

---

### 3.26 Short Stories (under the Short Stories heading)
Five well-known fairy tales, each condensed to 7–8 short, gentle lines for ages 2–6 (no scary endings:
Gretel tricks the witch and opens the door; a woodcutter comes and the wolf runs away):
Hansel & Gretel, Red Riding Hood, Cinderella, Sleeping Beauty, Beauty & the Beast
- One line per card with a matching picture; **no voice** (owner's choice) – a parent reads along and the
  child taps next
- The line is shown in large text that wraps; a story always shows every line, whatever the mode
- At the end of a story (5 seconds after the last line shows): the puppy and a sticker, like every section

## 4. Rewards and Motivation

- Stars earned for finishing a section, a game and each traced letter
- **Puppy:** at the end of every section (on its last card), the last tracing letter and every game, a
  cartoon puppy hops around the screen, wags its tail and says "Woof woof! You did it!". It appears only
  after the voice has finished the last item, so the child sees and hears it first. Tapping skips it
- **Sticker reward:** after the puppy, a screen says "Great Job! Now pick your sticker" and offers up to
  5 stickers (ones the child doesn't have yet first). It opens with falling confetti, clapping hands
  beside "Great Job!", and the sound of a classroom clapping while the puppy says "Woof woof! You did it!" in its own voice (about 3.5 s, no crowd cheering; chosen by the owner), then the voice. Picking one returns to the main menu
- **Sticker bar:** under the "My Learning Buddy" title on the home screen, showing the stickers collected
  (newest first)
- Celebration sounds (chime) on success; sound effects (pop, cheering and clapping, chime) are made by the project's
  own script, so there are no licensing questions
- Encouraging (never negative) feedback when tracing goes off the path – e.g. "Try again!"
- Rewards are **not saved**: they reset when the app or website is closed (see section 2)

---

## 4a. Games

Shown under the **Games** heading on the home screen; parents can hide it like any section.

- **Find It:** the child picks a section with clear pictures (animals, fruits, shapes, colours …). The
  voice asks "Can you find … Cow?" and shows 3 pictures. Right: the picture grows, shows its name and the
  voice says "Yay! You found it!". Wrong: the picture shakes and the voice says "Try again!".
  5 rounds, then the puppy and a sticker
- A speaker button repeats the question; stars at the top show the rounds done

---

## 5. Audio

- **Voice:** a clear, friendly, computer-generated (text-to-speech) female voice
- **Language:** English (US)
- Audio clips are generated ahead of time and bundled with the app/website, so the voice sounds the same
  on every device, works offline and sends no data to any speech service while the child uses the app
- Tool: **Kokoro-82M** (free, Apache-2.0 licence), voice "Heart" (`af_heart`) – approved by the owner
- Spoken slowly (0.75 speed) so it is easy for young children to follow
- **Puppy voice** (greetings and rewards only – "Hi! How are you?", "This is fun!", "Woof woof! You
  did it!", "Great job!", "Great job! Now pick your sticker.", "Yay! You found it!", "Well done!",
  "Try again!"): Kokoro voice "Nova" (`af_nova`) at normal speed, raised 4 semitones so it sounds like a
  child – chosen by the owner (sample 4, "Sparkly"). Same loudness as the learning voice
- All learning words keep the calm "Heart" voice
- Letter names **and** letter sounds (phonics)
- Captions: the text of what is spoken is always shown on screen
- Separate volume / mute controls for speech and for music and sound effects

---

## 6. Parent Area

- Protected by a parental lock (e.g. "solve this sum" or press-and-hold) so children can't enter
- **Show / hide categories:** parents can turn each learning section (3.1–3.24) on or off;
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

- More games: matching pairs, sound to picture, counting, drag and drop, coloring pages
- Additional learning section: Food
- Child profiles and age-based levels
- Saved progress, progress reports and sync across devices
- Multiple languages and voices
- Remembering parent settings between visits
- Screen-time / break reminder

---

## 12. Open Items / To Be Decided

None – all requirements decisions are made. Individual clip-art images are chosen during building,
within the rules above.
