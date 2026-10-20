# Artisnal — Click & Social

A Flutter app that teaches artisans, step by step and in their own language,
how to photograph their crafts, set up Instagram, post content, and read
their numbers.

## Features

- **Log in** — after the splash screen, email and password with **Forgot
  password?** (reset link flow; no backend yet—continues into onboarding).
- **Onboarding** — language picker (Assamese, English, Odia, Telugu) with
  spoken language names, and three welcome pages.
- **Learn home** — five tasks, live **progress bar** (tasks done out of 5),
  and a bottom bar (Learn, Photo, Me).
- **Me** — all five lesson badges shown **locked** until you finish the
  matching Learn task; they unlock as you earn badges in lessons.
- **Next task** — finishing a task (or its badge) can jump you to the next
  Learn task from the same chain.
- **Lessons** — each task is split into short parts. Most parts have a learn
  page with an illustration and a “Which is better?” check that reveals the
  answer only after the user picks one.
  - **Photography** — product → material → display pickers, per-display
    shooting guides, then camera with a dotted outline for that shot.
  - **Set up your page** — Good name, Clear photo, Professional (profile
    quiz), then a hidden in-flow “try it” wizard (name, bio, category, pro
    page) without a separate row on the task list.
  - **Create a post** — photo access, then Post → Story → Reel in order, with
    badge and confetti when all three are done.
  - **Posting plan** — Post often, Good time, Mix posts.
  - **Read the numbers** — Saves matter, Reply fast, What they mean, plus
    Find your numbers and a completion badge.
- **Celebration** — confetti keeps falling on badge screens while you stay
  on them.
- **Read aloud** — Listen buttons use device text-to-speech in the chosen
  language.
- On a wide browser window the app is shown in a phone-sized frame.

## Getting started

Requirements: Flutter 3.44 or newer (Dart 3.12).

```bash
git clone https://github.com/waruledivya1411/Artisanal_App.git
cd Artisanal_App
flutter pub get
```

Run it:

```bash
flutter run -d chrome --release   # in the browser
flutter run                        # on a connected phone or emulator
```

Build an Android APK:

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Run the tests:

```bash
flutter analyze
flutter test
```

> On Windows, building for Android or desktop needs **Developer Mode** turned
> on (Settings → System → For developers), because Flutter plugins use symlinks.

## Project structure

```
lib/
  main.dart                       App entry point
  app/
    app.dart                      MaterialApp and theme
    phone_frame.dart              Phone-sized frame on wide browser windows
  core/
    speech/speech_player.dart     Text-to-speech for Listen buttons
    theme/button_shadow.dart      Shared shadow for primary buttons
    widgets/                      Bottom bar, confetti, speaker buttons
  features/
    auth/screens/                 Log in and forgot password
    onboarding/screens/           Splash, language picker, welcome pages
    shell/                        Main tab (Learn + Me)
    me/screens/                   Badge gallery
    learn/
      data/                       Tasks, progress, task chain, navigation,
                                  products, materials, displays, guides,
                                  create-post progress
      screens/                    Learn home, pickers, lessons, badges,
                                  create-post flow, professional / try-it
      widgets/                    Lesson step, IG previews, next-task button
assets/images/
  icons/                          Speaker, Learn and Me icons
  onboarding/                     Welcome illustrations
  lessons/<task>/                 Lesson art and photos
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
