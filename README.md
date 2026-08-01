# Cleverr Mind Quiz App

`Cleverr Mind` is a native SwiftUI quiz game for iPhone and iPad. Players choose a trivia category and difficulty, answer a ten-question round, and build local statistics and Game Center leaderboard scores.

## Architecture

The project uses a small, view-driven SwiftUI architecture. `ContentView` is currently the primary feature coordinator: it owns the round state, presents each screen, starts/stops the timer, and writes local progress. Supporting views and model/service files keep shared UI, data, and platform integrations separate.

```text
QuizAppApp
  └─ ContentView (app flow and quiz state)
       ├─ Start/dashboard
       ├─ Category picker → difficulty picker
       ├─ Quiz round → results
       └─ Settings, theme picker, and help sheets

ContentView
  ├─ QuizAPI → Open Trivia DB (online questions)
  ├─ QuestionData → bundled fallback questions (offline)
  ├─ UserDefaults / @AppStorage → preferences and player statistics
  ├─ GameCenterManager → authentication, score submission, leaderboard
  └─ SoundManager → correct/incorrect system sounds and haptics
```

### Project layout

- `QuizApp/QuizAppApp.swift` — App entry point; makes the shared `GameCenterManager` available to the SwiftUI view hierarchy.
- `QuizApp/Views/ContentView.swift` — Main navigation/state machine and all core game screens.
- `QuizApp/Views/SettingsView.swift`, `ThemePickerView.swift`, `HelpView.swift` — Settings and informational sheets.
- `QuizApp/Views/ConfettiEffect.swift`, `ShimmerEffect.swift` — Reusable celebration and glitter effects.
- `QuizApp/Models/Question.swift` — `Question` and `QuestionSet` models, plus HTML entity cleanup for API text.
- `QuizApp/Models/QuestionData.swift` — Bundled fallback question banks.
- `QuizApp/Models/QuizAPI.swift` — Open Trivia DB category mapping, request, decoding, and answer shuffling.
- `QuizApp/Models/GameCenterManager.swift` — Game Center authentication, leaderboard submission, and access-point presentation.
- `QuizApp/Models/SoundManager.swift` — System audio and haptic feedback.
- `QuizApp/Models/AppColors.swift` — Central mapping of saved theme/text-color choices to SwiftUI colors.
- `QuizApp/Assets.xcassets` — App icon, accent color, and start-screen logo assets.

## Features built so far

### Quiz gameplay

- 10-question, four-answer multiple-choice rounds.
- 19 selectable categories: General Knowledge, Science & Nature, History, Geography, Sports, Movies & TV, Technology, Music, Animals, Video Games, Mythology, Board Games, Art, Vehicles, Comics, Anime & Manga, Cartoons, Books, and Gadgets.
- Medium, hard, and shuffled difficulty choices when using the online trivia source.
- “Surprise Me” selects a category not recently chosen; category ordering also reflects how often each has been played.
- Immediate correct/incorrect feedback, revealed correct answer, progress bar, elapsed timer, two skips per round, sound/haptic feedback, and confetti for correct answers.
- A leave-quiz confirmation prevents accidental loss of an active round.

### Online and offline question sources

- Online rounds request category/difficulty-filtered questions from [Open Trivia DB](https://opentdb.com/).
- API question text and options are HTML-decoded before display, and options are shuffled.
- If the request fails, a bundled ten-question set for the selected category is used instead.
- Offline rounds clearly show an offline notice and do not submit points, stats, or leaderboard scores.

### Results and player progress

- Results show score, rating, category/difficulty, elapsed time, accuracy, skips used, and a fastest-perfect-time callout when applicable.
- Dashboard tracks total quizzes, total points, average score, elite scores, daily streak, fastest perfect time, and best category.
- Per-category points and play counts are persisted locally with `@AppStorage`/`UserDefaults`.
- A score of 8 or more is treated as a perfect result for local perfect-score and fastest-time tracking; 9–10 is labeled “Legendary.”

### Platform and presentation

- Game Center integration code for authentication, score submission to leaderboard ID `com.cleverrmind.score`, and leaderboard access from the dashboard/category screens.
- Configurable app theme (30 named colors) and white/black text preference, with white text enforced for the Midnight theme.
- Animated dashboard entrance, logo asset, shimmer treatment, confetti, help/manual, and a responsive category list with a floating dice shortcut.
- The target supports iPhone and iPad and is configured with a minimum iOS deployment target of 18.0.

## Current implementation notes

- There is no separate navigation coordinator, view model layer, or persistence store yet; `ContentView` intentionally holds the current game state and persistence calls.
- The built-in question data is a fallback only. Online questions are the normal source when a network request succeeds.
- Game Center score submission depends on the player having authenticated successfully and on the configured leaderboard existing in App Store Connect. The current start-screen authentication handler updates `ContentView` state separately from `GameCenterManager`, so the manager authentication flow needs to be connected before score submission can reliably occur.
- Round/question counts are currently assumed from the selected local `QuestionSet` (ten questions per category).

## Maintaining this document

This README describes the code as of August 1, 2026. When adding or changing a meaningful feature, update the relevant section above in the same change—especially the architecture diagram, project layout, gameplay behavior, persistence rules, external integrations, and deployment requirements.
