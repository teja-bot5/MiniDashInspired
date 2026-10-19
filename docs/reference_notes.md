# Reference notes — Mini Dash Inspired

Research date: 2026-10-20. These are notes from accessible web results, not a claim that the old mobile app was run.

| Feature | Evidence/source | Observed behaviour | Confidence | Implementation decision |
|---|---|---|---|---|
| Core loop | Official PlayCreek page: https://www.playcreek.com/minidash/ | Fast platforming through trap-filled levels to reach an exit | High | One authored level, exit trigger, retry loop |
| Basic controls | Official page and Kongregate: https://www.kongregate.com/en/games/playcreek/mini-dash | Left/right and jump | High for browser build | Keyboard for development; touch controls for Android |
| Double jump | Pocket Gamer review and Kongregate how-to-play | Mid-air second jump | High for browser build; mobile parity not independently tested | Two-jump controller with configurable values |
| Ceiling traversal | Pocket Gamer review and Kongregate how-to-play | Holding jump can stick to ceiling; review also reports wall/ceiling running | High for browser build | Initial ceiling cling approximation; full gravity rotation/wall-running not implemented |
| Mobile steering | Pocket Gamer review | Accelerometer steering and on-screen controls mentioned; accelerometer described as more responsive | Medium-high | MVP uses on-screen controls only; accelerometer deferred pending device tests |
| Collectibles | Official page and Android gallery | Mushrooms/collectibles unlock content in original | High | Original abstract collectible motes; no original assets copied |
| Worlds and themes | Official page | Three worlds, plus retro bonus levels; original project prompt mentions Doodle/Clay/Industrial but not confirmed in inspected text | High for three worlds; low for exact named themes | One original dusk palette level; no claim of exact original world art |
| Historical Android package | Android gallery: https://playcreek-minidash.andro.io/ | Lists package `com.playcreek.MiniDash`, version 1.05, 28 MB | Medium; third-party archive | Recreation uses a distinct package ID |
| Trailer | https://www.youtube.com/watch?v=Cg0sJPkQG-Q | Direct page fetch failed during this run | Not observed | No footage-specific claims |
| Android Central thread | https://forums.androidcentral.com/threads/game-free-mini-dash-free-from-death-worm-devs.281587/ | Direct inspection failed in this run | Not observed | Do not infer details from the thread |
| Not Doppler archive | https://www.notdoppler.com/minidash.php | Page describes Mini Dash and identifies PlayCreek; current embedded gameplay not tested | High for page text, unknown for playability | Use as historical reference only |
| Kongregate archive | https://www.kongregate.com/en/games/playcreek/mini-dash | Historical Flash game page accessible; instructions list arrows, space/up, double-jump, ceiling stick | High for page text; current playability unverified | Mechanic reference only; do not depend on Flash at runtime |

## Important distinction

The browser build is not proof of exact mobile behaviour. Mechanics are implemented as an original approximation until checked against accessible footage or a functioning original build. This project uses original procedural artwork and does not bundle extracted game sprites, screenshots, music, or proprietary files.
