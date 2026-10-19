# Mini Dash Inspired — Godot project

An original, offline 2D platformer prototype informed by historical descriptions of PlayCreek's Mini Dash. It does **not** contain the original game's assets and is not affiliated with PlayCreek. Exact mobile fidelity has not yet been verified.

## Status

- Source project: created.
- Playable build: **not yet verified**. This environment did not have Godot, Android SDK tools, or `adb` installed during project creation.
- APK: **not produced**. Do not label the source ZIP as an APK.
- QA: static project inspection only; no engine parse, emulator, or physical-device test has been run.
- Latest source pass: landscape orientation configured; player physics is disabled before gameplay and outside active play; held-jump ceiling contact persists while touching the ceiling; touch zones are tracked by ID and cleared on pause/reset. All of these changes still require engine/device validation.

## Requirements

- Godot 4.x (project settings currently target the Godot 4.4 feature set; use a matching 4.x editor to open it).
- For Android export: a Godot Android export template matching the editor version, a supported JDK, Android SDK platform/build-tools, and an Android debug/release signing setup.
- The exact currently supported Android target SDK must be selected in the installed Godot export workflow before release. Android export preset and SDK configuration have not been generated/validated in this environment.

## Dependency-free static check

From this directory run `python tests/static_project_check.py`. This checks required project files and a few source references only; it does not parse GDScript or prove runtime behaviour.

## Run on desktop

1. Open Godot 4.x.
2. Import this folder by selecting `project.godot`.
3. Run the project (F6/F5).
4. Controls: Left/Right or A/D; Space/Up/W to jump and double-jump; hold jump against an overhead platform to test the approximate ceiling-cling behaviour. `R` restarts; `Esc` pauses/resumes; `F3` toggles debug overlay.
5. On touch screens, tap the start screen, then use the lower-left movement regions and lower-right jump region.

## Android target

- Minimum Android version requested: Android 10 / API 29. This has not yet been validated in an export build.
- Orientation: landscape.
- Intended renderer: GL Compatibility.
- Suggested distinct application ID: `com.example.minidashinspired` (set it in the Android export preset before building).
- Version: 0.1.0 / version code 1 (set version code in export settings).
- Offline: gameplay uses local scenes and code only; no network calls or external assets.

## Export steps (after installing prerequisites)

1. Open the project in the chosen Godot 4.x editor and install matching export templates via **Editor → Manage Export Templates**.
2. Install/configure the Android SDK and JDK under **Editor Settings → Export → Android**.
3. Add an Android export preset. Set package ID to `com.example.minidashinspired`, minimum SDK to 29, target SDK to a currently supported value offered by that toolchain, and architecture to ARM64.
4. Create a release keystore locally. Keep the keystore and passwords outside Git and never commit them.
5. Export a release APK to `build/MiniDashInspired.apk`.
6. Verify the file exists, install it on an API 29+ emulator/device, launch it, test the complete level, and capture logs before marking it released.

The export preset is intentionally not presented as validated: this environment lacks the engine and Android toolchain. Add and verify the preset with the actual selected editor/toolchain.

## Project map

- `project.godot` — engine configuration.
- `scenes/main.tscn` — main scene.
- `scripts/game.gd` — authored level, state flow, touch handling, HUD and procedural scenery.
- `scripts/player.gd` — CharacterBody2D controller, jump buffer, coyote time, double jump and approximate ceiling cling.
- `docs/reference_notes.md` — evidence and confidence notes.
- `docs/visual_spec.md` — visual direction and remaining reference gaps.
- `docs/qa_report.md` — actual verification status.

## Known limitations

This is an initial implementation, not a verified release. The player art is procedurally drawn rather than a finished sprite sheet; audio, settings persistence, checkpoints, accelerometer controls, and full floor/wall/ceiling gravity transitions are not implemented. Ceiling cling is an approximation based on browser-version descriptions and has not been runtime-tested. Further physics and touch-input tuning requires Godot execution and Android device testing.
