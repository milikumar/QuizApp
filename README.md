# Cleverr Mind Quiz App

`Cleverr Mind` is a native SwiftUI quiz game for iPhone and iPad. Players choose a trivia category and difficulty, answer a ten-question round, and build local statistics and Game Center leaderboard scores.

## Architecture

The project uses a small, view-driven SwiftUI architecture. `ContentView` is the feature coordinator: it owns round state, routes between screens, starts/stops the timer, and writes local progress. Each major screen is a composable view in `QuizScreens.swift`; supporting views and model/service files keep shared UI, data, and platform integrations separate.

```text
QuizAppApp
  └─ ContentView (screen routing, quiz state, actions, persistence)
       ├─ StartScreenView
       ├─ CategorySelectionView → DifficultySelectionView
       ├─ QuizRoundView → ResultsView
       └─ LoadingView / settings, badges, theme picker, category stats, help, and onboarding overlay

ContentView
  ├─ QuizAPI → Open Trivia DB (online questions)
  ├─ QuestionData → bundled fallback questions (offline)
  ├─ UserDefaults / @AppStorage → preferences and player statistics
  ├─ BadgeProgress → badge definitions, progress evaluation, and persisted awards
  ├─ TutorialManager → first-launch walkthrough state and spotlight targets
  ├─ GameCenterManager → authentication, score submission, leaderboard
  └─ SoundManager → correct/incorrect system sounds and haptics
```

### Project layout

- `QuizApp/QuizAppApp.swift` — App entry point; makes the shared `GameCenterManager` available to the SwiftUI view hierarchy.
- `QuizApp/Views/ContentView.swift` — Main screen router, game state, gameplay actions, lifecycle handling, and local persistence.
- `QuizApp/Views/QuizScreens.swift` — Composable loading, start, category, difficulty, quiz, and results screens, plus their screen-local UI components.
- `QuizApp/Views/SettingsView.swift`, `ThemePickerView.swift`, `HelpView.swift`, `BadgesView.swift`, `CategoryStatsView.swift` — Settings and informational sheets, including the badge list and per-category stat breakdown. `ThemePickerView` also contains text-color selection and theme reset controls.
- `QuizApp/Views/SpotlightOverlay.swift` — Reusable dimming/cutout overlay, tutorial callout, and view-anchor preference helper.
- `QuizApp/Views/ConfettiEffect.swift`, `ShimmerEffect.swift` — Reusable celebration and glitter effects.
- `QuizApp/Models/Question.swift` — `Question` and `QuestionSet` models, plus HTML entity cleanup for API text.
- `QuizApp/Models/QuestionData.swift` — Bundled fallback question banks.
- `QuizApp/Models/QuizAPI.swift` — Open Trivia DB category mapping, request, decoding, and answer shuffling.
- `QuizApp/Models/GameCenterManager.swift` — Game Center authentication, leaderboard submission, and access-point presentation.
- `QuizApp/Models/SoundManager.swift` — System audio and haptic feedback.
- `QuizApp/Models/AppColors.swift` — Central mapping of saved theme/text-color choices to SwiftUI colors.
- `QuizApp/Models/Badges.swift` — Ordered 23-badge catalog, progress snapshot, and award/persistence helpers.
- `QuizApp/Models/TutorialManager.swift` — Ten-step onboarding state machine and spotlight target definitions.
- `QuizApp/Models/CategoryStatRow.swift` — Per-category statistics model (plays, points, perfects, elites, fastest time).
- `QuizApp/Assets.xcassets` — App icon, accent color, and start-screen logo assets.

## Features built so far

### Quiz gameplay

- 10-question, four-answer multiple-choice rounds.
- 19 selectable categories: General Knowledge, Science & Nature, History, Geography, Sports, Movies & TV, Technology, Music, Animals, Video Games, Mythology, Board Games, Art, Vehicles, Comics, Anime & Manga, Cartoons, Books, and Gadgets.
- Medium, hard, and shuffled difficulty choices when using the online trivia source.
- “Surprise Me” selects a category not recently chosen; category ordering also reflects how often each has been played. Its floating dice shortcut stays hidden initially and appears only after the Surprise Me button scrolls off-screen.
- Immediate correct/incorrect feedback, revealed correct answer, progress bar, elapsed timer, two skips per round, sound/haptic feedback, and confetti for correct answers.
- A leave-quiz confirmation prevents accidental loss of an active round.

### Online and offline question sources

- Online rounds request category/difficulty-filtered questions from [Open Trivia DB](https://opentdb.com/).
- API question text and options are HTML-decoded before display, and options are shuffled.
- The question client spaces requests at least five seconds apart and retries the API’s rate-limit response, preventing rapid replay requests from falling back to predictable bundled questions. [Open Trivia DB documents a one-request-per-five-seconds IP limit.](https://opentdb.com/api_config.php)
- If the trivia service request fails, a bundled ten-question set for the selected category is used instead without incorrectly marking the player offline.
- The offline notice appears only when the device reports that it has no internet connection; those rounds do not submit points, stats, or leaderboard scores.

### Results and player progress

- Results show score, rating, category/difficulty, elapsed time, accuracy, skips used, and a fastest-perfect-time callout when applicable.
- The primary results action is labeled “Play [Category] Again,” dynamically inserting the just-played category; “New Category” returns to category selection.
- Dashboard tracks total quizzes, total points, average score, elite scores, daily streak, fastest perfect time, and best category.
- The dashboard’s summary cards and primary actions use matching horizontal padding, and each swipeable highlight card has a small horizontal inset.
- Per-category points and play counts are persisted locally with `@AppStorage`/`UserDefaults`.
- A score of 8 or more is treated as a perfect result for local perfect-score and fastest-time tracking; 9–10 is labeled “Legendary.”
- Daily streaks and category play counts are recorded for completed offline rounds; points and score-based statistics remain online-only.

### Badges

- A Settings → Badges sheet presents all 23 badges as an ordered, grouped list: Completion, Score, Speed, Streak, and Master.
- Each row shows an icon, name, and requirement; earned badges are full color with a checkmark, while locked badges are muted but remain readable. Tapping any badge explains its requirement or confirms it was earned.
- Badge awards are persistent. Completion, score, and speed progress only use online rounds; streak badges can be earned from any completed round.
- The app tracks the additional Elite-score count, Hard Elite achievement, 8+-score consistency streak, online-only category play counts, and earned badge IDs needed for the badge rules.

### Category statistics

- A Settings → Category Stats sheet lists every category with its play count, points earned, perfect-score count, elite-score count, and fastest perfect time, sorted by points earned.
- Per-category perfect counts, elite counts, and fastest times are persisted locally alongside the existing per-category points and play counts, all recorded only for online rounds.
- Categories with no perfect score yet show a placeholder fastest time instead of a zero duration.

### Theme and appearance

- Settings → App Theme presents a selectable, 30-color grid, text-color choices, and a Reset Theme control in one sheet; the former standalone text-color settings row was consolidated here.
- Reset Theme restores Indigo / White without changing player statistics or progress, and its caption makes that scope explicit. Midnight enforces white text and visibly disables the black-text option.

### Sound and vibration feedback

- Settings → Feedback is the final Settings item and provides independent, persistent toggles for answer sound effects and vibration (haptic) feedback. Its custom high-contrast switches use a shadowed thumb so their on/off state remains clear in either text-color mode.
- Correct and incorrect answer feedback reads these preferences at the time of the answer, so either form of feedback can be disabled without affecting gameplay.

### First-launch tutorial

- A persisted `hasSeenTutorial` flag runs a 10-step Spotlight walkthrough only on the app’s first launch.
- The tutorial measures actual control frames in global screen coordinates and converts them into the overlay’s drawing space, so cutouts stay aligned when screen layouts change; it explains Settings, Play, Home, Surprise Me, difficulty, timer, exit, skip, results, and where to find the Manual and Badges.
- Informational steps provide Next; Play, Surprise Me, and difficulty steps advance only through the actual highlighted controls.
- The quiz segment uses a non-persistent demo result so a new player can see the Results screen without answering a full round. Offline mode and category “Played Xx” details remain in the Manual.

### Platform and presentation

- Game Center integration code supports authentication and score submission to leaderboard ID `com.cleverrmind.score`. Leaderboard controls are temporarily hidden from the dashboard and category screens.
- Configurable app theme (30 named colors) and white/black text preference, with white text enforced for the Midnight theme.
- Animated dashboard entrance, logo asset, shimmer treatment, confetti, help/manual, and a responsive category list with a floating dice shortcut.
- The target supports iPhone and iPad and is configured with a minimum iOS deployment target of 18.0.

## Current implementation notes

- There is no separate view-model layer or persistence store yet; `ContentView` intentionally holds the current game state and persistence calls, while `QuizScreens.swift` keeps rendering concerns out of the coordinator.
- The built-in question data is a fallback only. Online questions are the normal source when a network request succeeds.
- Game Center score submission depends on the player having authenticated successfully and on the configured leaderboard existing in App Store Connect. The current start-screen authentication handler updates `ContentView` state separately from `GameCenterManager`, so the manager authentication flow needs to be connected before score submission can reliably occur.
- Round/question counts are currently assumed from the selected local `QuestionSet` (ten questions per category).
- `ThemePickerView` requires both an `appColorName` and a `textColorName` binding from callers.
- `SettingsView` now requires a `categoryStats` array from its caller in addition to the existing theme/text-color bindings.

## Maintaining this document

This README describes the code as of August 11, 2026. When adding or changing a meaningful feature, update the relevant section above in the same change—especially the architecture diagram, project layout, gameplay behavior, persistence rules, external integrations, and deployment requirements.
