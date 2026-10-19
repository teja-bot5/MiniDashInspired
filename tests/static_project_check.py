"""Dependency-free sanity checks for the MiniDashInspired source tree.

Run with: python tests/static_project_check.py
This does not parse GDScript or replace Godot runtime/Android QA.
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = (
    "project.godot",
    "scenes/main.tscn",
    "scripts/game.gd",
    "scripts/player.gd",
    "README.md",
    "docs/reference_notes.md",
    "docs/visual_spec.md",
    "docs/qa_report.md",
    "docs/reference_access_report.md",
)

missing = [name for name in REQUIRED if not (ROOT / name).is_file()]
if missing:
    print("FAIL: missing required files:", ", ".join(missing))
    sys.exit(1)

project = (ROOT / "project.godot").read_text(encoding="utf-8")
scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
game = (ROOT / "scripts/game.gd").read_text(encoding="utf-8")
player = (ROOT / "scripts/player.gd").read_text(encoding="utf-8")
checks = {
    "main scene configured": 'run/main_scene="res://scenes/main.tscn"' in project,
    "main scene references game script": 'res://scripts/game.gd' in scene,
    "game script references player script": 'res://scripts/player.gd' in game,
    "CharacterBody2D controller uses slide movement": "CharacterBody2D" in player and "move_and_slide()" in player,
    "touch input tracks IDs": "touch_zones" in game,
    "player physics follows game state": 'player.set_physics_process(game_state == "playing")' in game,
    "landscape orientation configured": "window/handheld/orientation=0" in project,
    "ceiling cling supports held-jump contact": "is_on_ceiling() and jump_held and velocity.y <= 0.0" in player,
    "touch inputs can be cleared on pause/reset": "func _clear_touch_input()" in game,
    "no obvious remote dependency in gameplay script": "HTTPRequest" not in game and "WebSocketPeer" not in game,
}
failed = [name for name, passed in checks.items() if not passed]
for name, passed in checks.items():
    print(f"{'PASS' if passed else 'FAIL'}: {name}")
if failed:
    sys.exit(1)
print("NOTE: These static checks do not validate GDScript syntax, runtime behaviour, Android export, or device compatibility.")
