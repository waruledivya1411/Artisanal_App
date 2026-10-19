# Artisnal — Click & Social

A Flutter app that teaches artisans, step by step and in their own language,
how to photograph their crafts and sell them on Instagram.

## Features

- **Onboarding** — splash screen, language picker (Assamese, English, Odia,
  Telugu) with spoken language names, and three welcome pages.
- **Learn home** — the artisan's tasks, progress and location, with a bottom
  bar (Learn, Photo, Me).
- **Lessons** — each task is split into short parts. Every part has a learn
  page with an illustration and a "Which is better?" check that reveals the
  answer only after the user picks one.
  - Photography: Hold steady, Plain sheet, Window light, Straight angle, Try it
    (opens the camera)
  - Set up your page: Good name, Clear photo
  - Posting plan: Post often, Good time, Mix posts
- **Read aloud** — every screen has a Listen button that reads the text using
  the device's text-to-speech in the chosen language.
- On a laptop browser the app is shown in a phone-sized frame.

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
    speech/speech_player.dart     Text-to-speech playback for Listen buttons
    theme/button_shadow.dart      Shared shadow for primary buttons
    widgets/                      Shared widgets (bottom bar, Listen and
                                  speaker buttons)
  features/
    onboarding/screens/           Splash, language picker, welcome pages
    learn/
      data/learn_tasks.dart       Lesson content for each task
      data/learn_progress.dart    Which parts of each task are done
      screens/                    Learn home, task parts, learn page,
                                  "Which is better?" check, Try it
      widgets/lesson_step.dart    Links each part to the next one
assets/images/
  icons/                          Speaker, Learn and Me icons
  onboarding/                     Welcome page illustrations
  lessons/<task>/                 Illustrations and photos for each lesson
test/
  app_flow_test.dart              Walks through onboarding and every lesson
```

### Adding a new lesson part

Lesson content lives in `lib/features/learn/data/learn_tasks.dart`. Add a
`TaskPart` to the task, open a `LearnPartScreen` from it, and pass a
`CheckPartScreen` as its `nextBuilder`. Put the images in
`assets/images/lessons/<task>/`; that folder is already listed in
`pubspec.yaml`.
