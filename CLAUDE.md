# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Beat Orbit is a rhythm game built in Godot 4.4 for GMTK Game Jam 2025 (theme: "Loop"). Players time button presses as arrows rotate around a drum wheel, building drum patterns that loop continuously.

## Key Development Commands

### Fix linting error 
use gdlint to check for linting error s and warnings and fix them before finishing your task. use gdlint and gdformat on the command line.

### Running the Game
```bash
# Open in Godot Editor
godot project.godot

# Run specific scene
godot scenes/game/game.tscn

# Run with debugging
godot --verbose --debug project.godot
```

### Web Export
```bash
# Export for web (requires export templates)
godot --export "HTML5" build/index.html

# Test web build locally
python -m http.server -d build/
```

## Architecture Overview

### Scene Structure
- **Game.tscn**: Main game scene containing DrumWheel and UI
- **DrumWheel**: Core gameplay node that manages rotating arrows and hit detection
- **Arrow.tscn**: Individual arrow instances that rotate around the wheel
- **Pattern System**: Records player inputs into looping drum patterns (2-4 measures)

### Core Classes

**DrumWheel.gd** (`scripts/game/drum_wheel.gd`):
- Manages arrow spawning and rotation synced to BPM
- Handles hit detection with timing windows (Perfect/Good/Miss)
- Records and plays back drum patterns
- Emits signals for drum hits and pattern completion

**Arrow.gd** (`scripts/game/arrow.gd`):
- Visual representation of drum types (Kick=Red, Snare=Green, HiHat=Blue)
- Handles color coding and glow effects

### Autoload Scripts
- **GlobalAudio**: Manages volume levels and audio playback
- **GameData**: Stores game state, current level, scores, and BPM settings

### Input System
- Single button gameplay: `hit_drum` (Space/Enter/Click)
- Additional inputs: `pause` (ESC/P), `restart` (R)

## Audio Implementation
- 48kHz sample rate optimized for web
- Low latency settings (20ms) for responsive gameplay
- Drum samples needed: kick, snare, hi-hat (3 velocity layers each)
- Beat synchronization uses `beat_timer` in DrumWheel

## Visual Style
- Synthwave/Tron aesthetic with neon glows
- Color palette: Deep purple (#1a0033), cyan (#00ffff), hot pink (#ff006e)
- Heavy use of emission shaders and bloom effects
- Geometric shapes, avoid pixel art

## Current Development State
- Core scripts created (DrumWheel, Arrow)
- Input mapping complete
- Audio buses configured
- Scene assembly needed
- Visual assets pending
- Level progression system not implemented

## Testing Considerations
- Target 60 FPS on web
- Test in Chrome, Firefox, Safari
- Check audio latency on itch.io
- Verify pattern recording/playback accuracy
- Monitor memory usage during extended play

## Code Style Guidelines (GDLint)

### Class Structure Order
Classes must follow this specific order:
1. `tool` declarations
2. `class_name` declarations
3. `extends` statements
4. Docstrings
5. Signals
6. Enums
7. Constants
8. Static variables
9. Export variables
10. Public variables
11. Private variables (with `_` prefix)
12. `@onready` public variables
13. `@onready` private variables
14. Other elements (methods, etc.)

### Naming Conventions
- **Classes**: PascalCase (e.g., `DrumWheel`, `GameManager`)
- **Variables**: snake_case with optional `_` prefix for private (e.g., `hit_count`, `_internal_state`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`, `DEFAULT_BPM`)
- **Functions**: snake_case or `_on_PascalCase` for signal callbacks (e.g., `calculate_score`, `_on_Button_pressed`)
- **Signals**: snake_case (e.g., `drum_hit`, `pattern_completed`)
- **Enums**: PascalCase (e.g., `DrumType`, `GameState`)
- **Enum values**: UPPER_SNAKE_CASE (e.g., `KICK`, `SNARE`, `HI_HAT`)

### Code Quality Limits
- Maximum line length: 120 characters
- Maximum file length: 1200 lines
- Maximum function arguments: 10
- Maximum public methods: 20
- Maximum returns per function: 6

### Additional Rules
- Use single tab for indentation
- No trailing whitespace
- No mixed tabs and spaces
- Avoid unnecessary `pass` statements
- Don't use `elif`/`else` after `return`
- Remove unused arguments

### Running Linter
```bash
# Run gdlint on all GDScript files
gdlint scripts/

# Auto-format files
gdformat scripts/
```