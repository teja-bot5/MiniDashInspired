# QA report

Date: 2026-10-20

## Environment inspection

| Check | Result | Evidence |
|---|---|---|
| Godot executable available | Not found | `command -v godot` / `godot4` returned no path |
| Java | Available | OpenJDK 21.0.12.1 |
| Android SDK / sdkmanager | Not found | `command -v sdkmanager` returned no path; Android SDK environment variables not set |
| adb | Not found | `command -v adb` returned no path |
| Engine project parse | Not run | No Godot executable available |
| Android APK export | Not run | No Godot editor/export templates/Android SDK available |
| APK install/launch | Not run | No APK or adb/emulator available |
| Physical-device test | Not run | No connected device verification available |

## Test checklist

| Test | Status | Notes |
|---|---|---|
| Complete level start-to-exit | Not tested | Requires engine execution and playthrough |
| Jump and double-jump | Not tested | Requires engine execution |
| Ceiling cling | Not tested | Approximation; requires controller tuning |
| Touch simultaneous inputs | Not tested | Needs emulator and physical-device test |
| Hazards and death/retry | Not tested | Requires runtime test |
| Collectibles and counter | Not tested | Requires runtime test |
| Pause/resume and replay | Not tested | Requires runtime test |
| Collision corners / high-speed collisions | Not tested | Requires runtime physics test |
| Aspect ratios and safe areas | Not tested | Requires Android devices/emulators |
| Offline cold launch | Not tested | No APK available; source has no network calls |
| Android 10 / API 29 | Not tested | No export or emulator |
| Newer Android version | Not tested | No export or device |

## Static source review update

A further source pass made these changes, still not runtime-tested:

- Set the handheld orientation to landscape (orientation value `0` for the Godot 4 setting) to match the intended game layout.
- Disable player physics at startup until gameplay begins, avoiding an initial title-screen fall.
- Keep the held-jump ceiling-cling state active on consecutive ceiling-contact frames when vertical velocity is zero; this remains an approximation, not verified original physics.
- Clear held touch states when pausing and when resetting/restarting.
- Track touches independently by touch ID so movement and jump can be held simultaneously.
- Extend static checks for orientation, ceiling-cling condition, and touch-state cleanup.

A network probe to fetch the Godot engine failed because DNS resolution was unavailable in this environment. Therefore, installing the engine and building an APK here is currently blocked. A source archive integrity check and custom project-file/reference checks do not substitute for the Godot parser or runtime tests.

## Release decision

**Not release-ready.** The source and documentation are present, but the project has not been parsed or run by Godot. No APK is claimed or included. First actionable blocker: install Godot 4.x with matching export templates, configure Android SDK/JDK, parse and run the project, fix all script/runtime errors, then export and test an APK. Revisit touch handling and ceiling movement after the first real playthrough.
