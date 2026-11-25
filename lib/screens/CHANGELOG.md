# app-screens Changelog

Owner: JinboLi
JinboLi is responsible for the app-screens branch: the Home, Game Options, and Results screens and the navigation between them.

## 2026-11-24
- Built the Home screen with the Raumschach title, a 5×5×5 subtitle, and New Game, Tutorial, and Settings buttons.
- New Game creates a shared GameController, opens Game Options, and disposes the controller when the session ends.
- Tutorial and Settings show a "Coming soon" SnackBar until those screens are implemented.
- Pointed the app entry in main.dart at the Home screen.
- Added a minimal Game Options placeholder so New Game navigation works.
- Built the Game Options screen with local pass-and-play and four chaos-modifier toggles (Wraparound, Gravity, Rubik's slice, and Portals).
- Stored modifier choices in an immutable GameOptions model; they are not wired to the engine yet.
- Start Game calls controller.startNewGame() and opens a temporary board placeholder, because GameScreen is still a teammate stub.
- Built the Results screen with a White wins / Black wins / Draw headline, a reason when available, and the number of moves played.
- Added New Game (returns to Game Options so modifiers can be changed), Home, and a disabled Replay button.
- Added a temporary dev-only Preview results button on the board placeholder so the Results screen can be opened before GameScreen exists.
- Added a Practice button on the Home screen for the planned sandbox mode.
- Marked Settings and Practice as "In development"; tapping either shows an "In development" SnackBar. Tutorial still shows "Coming soon".

## 2026-11-18
- Set up the app-screens branch and verified pushing to GitHub works.
- Merged the latest main (Flutter SDK requirement lowered to ^3.8.1).
- Renamed the test file to lib/screens/CHANGELOG.md to track app-screens changes.
- Restored pubspec.lock to the main version (pubspec.lock is no longer committed from this branch).
