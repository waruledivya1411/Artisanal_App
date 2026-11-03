# Artisnal — Click & Social

A Flutter app that teaches artisans, step by step and in their own language,
how to photograph their crafts, set up Instagram, post content, and read
their numbers. A static client website in `client-website/` follows the same
lessons inside the same phone frame.

Languages: English (the default), Assamese, Odia, and Telugu.
Listen buttons speak the screen in the chosen language.

## Features

- **Log in** — after the splash screen, email and password with **Forgot
  password?** (reset link flow; no backend yet — continues into onboarding).
- **Onboarding** — language picker (Assamese, English, Odia, Telugu) with
  spoken language names, and three welcome pages.
- **Learn home** — five tasks, a live progress bar (tasks done out of 5),
  and a bottom bar (Learn, Photo, Me).
- **Me** — all five lesson badges stay locked until the matching Learn task
  is finished.
- **Next task** — finishing a task, or its badge, opens the next Learn task.
- **Lessons** — each task is split into short parts. Most parts have a learn
  page with an illustration and a “Which is better?” check. The answer stays
  hidden until the user picks one.
  - **Photography** — Hold steady, Plain sheet, Window light, a straight
    phone, then how light falls on cotton and silk. The Photo tab opens the
    product picker (Saree, Mekhala sador, Stole, Gamusa, Shawl, Jod kappur,
    Yardages, Cushion covers). Each product already has its yarn, so there is
    no material page. The user picks one or more ways to show it, then a shot
    list and a camera guide with a dotted outline.
  - **Set up your page** — Good name, Clear photo, Professional (profile
    quiz), then a hidden “Try it” wizard (what you sell, then your Pro page).
    Try it does not get its own row on the task list.
  - **Create a post** — Allow photo access, then Post, Story, and Reel in
    that order. Each one walks through the Instagram plus button, a photo
    gallery, and “Did you post it?”. A badge appears when all three are done.
  - **Posting plan** — Post often, Good time, Mix posts.
  - **Read the numbers** — Saves matter, Reply fast, What they mean, then
    Find your numbers and a completion badge.
- **Celebration** — confetti keeps falling on badge screens.
- On a wide browser window the Flutter app sits in a phone-sized frame
  (390 wide, up to 844 tall).

## Client website

`client-website/` is plain HTML, CSS, and JavaScript. It does not change the
Flutter app. It repeats the same screens: language, lessons, task lists,
product and display pickers, Create a post, and the badges.

Pictures are loaded from `../assets/images/`. Keep `client-website/` and
`assets/` as sibling folders, or the pictures will not load. A domain can
point at `client-website/` later, as long as `assets/` stays beside it.

From the repository root:

```bash
python -m http.server 8765
```

Then open `http://127.0.0.1:8765/client-website/`.

On a wide screen the site stays inside the phone frame. On a narrow screen
(600px or less) it fills the window.

## Getting started

Requirements: Flutter 3.44 or newer (Dart 3.12).

```bash
git clone https://github.com/waruledivya1411/Artisanal_App.git
cd Artisanal_App
flutter pub get
```

Run the app:

```bash
flutter run -d chrome --release   # in the browser
flutter run                        # on a connected phone or emulator
```

Build an Android APK:

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Run the checks:

```bash
flutter analyze
flutter test
```

On Windows, building for Android or desktop needs **Developer Mode** turned
on (Settings → System → For developers), because Flutter plugins use symlinks.

## Project structure

```
lib/
  main.dart                       App entry point
  app/
    app.dart                      MaterialApp and theme
    phone_frame.dart              Phone-sized frame on wide browser windows
  core/
    speech/speech_player.dart     Text-to-speech for Listen buttons
    l10n/app_text.dart            Assamese, Odia, and Telugu strings
    theme/button_shadow.dart      Shared shadow for primary buttons
    widgets/                      Bottom bar, confetti, speaker buttons
  features/
    auth/screens/                 Log in and forgot password
    onboarding/screens/           Splash, language picker, welcome pages
    shell/                        Main tab (Learn, Photo, Me)
    me/screens/                   Badge gallery
    learn/
      data/                       Tasks, progress, products, displays, guides
      screens/                    Learn home, pickers, lessons, badges
      widgets/                    Lesson step, Instagram previews, diagrams
client-website/
  index.html                      Phone frame and page shell
  styles.css                      Layout, matching the app
  app.js                          Screens and navigation
  i18n.js                         Assamese, Odia, and Telugu strings
assets/images/
  icons/                          Speaker, Learn, and Me icons
  onboarding/                     Welcome illustrations
  lessons/<task>/                 Lesson art and photos
  lessons/products/               Product photos
  lessons/displays/               How each product is shown
test/
  app_flow_test.dart              Onboarding, login, and lesson walkthrough
```

### Adding a new lesson part

Lesson content lives in `lib/features/learn/data/learn_tasks.dart`. Add a
`TaskPart` to the task, open a `LearnPartScreen` from it, and pass a
`CheckPartScreen` as its `nextBuilder`. Use `showOnList: false` on a part
if it should run in order via **Next** but not appear as its own row on the
task list. Put images in `assets/images/lessons/<task>/` (folders are listed
in `pubspec.yaml`).

Task completion for the home progress bar and Me badges uses part counts in
`lib/features/learn/data/learn_task_chain.dart`.

The website reads the same English strings. When a new learner-facing
sentence is added, add it to `lib/core/l10n/app_text.dart` and to
`client-website/i18n.js`.
