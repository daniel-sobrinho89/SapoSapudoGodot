# Repository Guidelines

## Project Structure & Module Organization

This is a Godot 4.7 2D game. `project.godot` holds engine settings and starts `res://scenes/world.tscn`. Keep reusable scenes in `scenes/`: `world.tscn` assembles the playable world and `goblin.tscn` defines the enemy. Put node behavior in matching GDScript files under `scripts/` (for example, `scenes/goblin.tscn` uses `scripts/goblin.gd`). Store imported art below `assets/`, grouped by character, such as `assets/Sapudo/` and `assets/Goblin/`. Do not hand-edit generated `.import` or `.uid` files.

## Build, Test, and Development Commands

Open the project in the Godot editor:

```sh
godot --editor project.godot
```

Run the configured main scene locally:

```sh
godot --path . --editor
# Press F6 for the current scene or F5 for the project.
```

For a quick non-graphical project-load check, use:

```sh
godot --headless --path . --quit
```

Use the same major Godot version declared in `project.godot` (4.7) to avoid scene or import-format churn.

## Coding Style & Naming Conventions

Write GDScript with tabs for indentation, explicit types for exported and node-reference values, and `snake_case` for variables, functions, files, and scene names. Follow the existing Portuguese gameplay vocabulary (`velocidade_corrida`, `alvo`) within related code. Use `PascalCase` for Godot node classes such as `CharacterBody2D`. Keep per-frame movement and AI in `_physics_process(delta)` and use typed signal handlers named `_on_<node>_<signal>`.

Prefer editor-based changes for `.tscn` scenes and `project.godot`; preserve resource paths and animation names referenced by scripts. No formatter or linter is configured, so mirror nearby code and let the Godot editor report parser errors.

## Testing Guidelines

There is no automated test framework or coverage target. Before submitting gameplay changes, run the affected scene and the full project in Godot. Verify player input (WASD and arrows), sprite direction and animations, goblin detection, chase behavior, attack range, and cooldown behavior. Use the headless command above as a lightweight syntax/project validation when practical.

## Commit & Pull Request Guidelines

This checkout has no accessible Git history, so no repository-specific commit convention can be inferred. Use short, imperative subjects such as `Add goblin attack cooldown`. Keep commits focused. Pull requests should describe behavior changes, list validation performed, link related issues when available, and include screenshots or a short recording for visual or gameplay changes.


## Gameplay Change Guidelines

- Prefer Godot-native nodes and systems before introducing custom infrastructure.
- Preserve existing scene composition and resource paths unless the task requires restructuring.
- When modifying a character, inspect its `.tscn`, script, animations, collision shapes, and related areas before editing.
- Do not silently change gameplay constants such as detection radius, movement speed, attack range, or cooldown.
- When a gameplay behavior changes, validate the complete behavior in-game, not only parser/syntax correctness.
- For animation changes, verify the animation name, frame order, loop setting, playback state, and horizontal flip behavior.



## Asset Guidelines

- Do not rename, move, replace, or regenerate an asset unless the task explicitly requests it.
- When moving or renaming an asset, update every affected resource path and verify the project after the change.
- Prefer existing spritesheets and animations over generating placeholder assets.