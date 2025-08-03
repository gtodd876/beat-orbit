# Beat Orbit - Complete Codebase Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Core Game Systems](#core-game-systems)
3. [Class Documentation](#class-documentation)
4. [Signal Flow](#signal-flow)
5. [Game State Management](#game-state-management)
6. [Audio System](#audio-system)
7. [Visual Effects System](#visual-effects-system)
8. [UI System](#ui-system)
9. [Input Handling](#input-handling)
10. [Level Progression](#level-progression)

---

## Architecture Overview

Beat Orbit is a rhythm game built in Godot 4.4 with a clean separation of concerns between gameplay logic, UI, effects, and audio systems. The codebase follows these key architectural principles:

- **Scene-Script Pairing**: Each major component has a corresponding `.tscn` scene file paired with a `.gd` script
- **Signal-Driven Communication**: Components communicate through Godot's signal system for loose coupling
- **Autoload Singletons**: Global state managed through `GameData` and `GlobalAudio` autoloads
- **Manager Pattern**: Specialized managers handle effects (screen shake, hit feedback)

### Directory Structure
```
scripts/
├── autoload/          # Global singletons
├── game/              # Core gameplay logic
├── ui/                # User interface components
└── effects/           # Visual feedback systems
```

---

## Core Game Systems

### 1. Gameplay Loop

The core gameplay revolves around a rotating arrow that the player must align with beat targets by pressing SPACE at the right time. The game features:

- **8-beat measures** with different drum patterns per level
- **3 drum layers** (Kick, Snare, Hi-Hat) that must be completed sequentially
- **Timing windows**: Perfect (50ms), Good (100ms), Miss (150ms)
- **Visual feedback** for each drum type (spin effects, color changes)

### 2. Beat Synchronization

The game maintains beat synchronization through:
- Music playback position as the source of truth
- Fallback to timer-based beats if music isn't playing
- BPM-based rotation speed calculations
- Real-time beat position updates

---

## Class Documentation

### DrumWheel (`scripts/game/drum_wheel.gd`)

**Purpose**: The heart of the gameplay - manages the rotating arrow, hit detection, and pattern recording.

**Key Properties**:
- `wheel_radius`: Visual radius of the drum wheel (200 pixels)
- `arrow_rotation`: Current angle of the rotating arrow
- `rotation_speed`: Calculated from BPM (TAU / (beat_duration * 8))
- `current_layer`: Active drum type being recorded (KICK → SNARE → HIHAT)
- `player_pattern`: Dictionary tracking successful hits for each layer

**Key Methods**:

1. **`check_hit()`** (lines 235-323)
   - Calculates which beat the arrow is closest to
   - Determines timing quality (PERFECT/GOOD/MISS)
   - Records successful hits to player_pattern
   - Triggers visual/audio feedback

2. **`apply_visual_effect(drum_type)`** (lines 334-358)
   - KICK: Full 360° spin animation
   - SNARE: Half 180° spin animation
   - HIHAT: Instant direction reversal

3. **`load_level_patterns()`** (lines 688-697)
   - Loads drum patterns from GameData based on current level
   - Patterns define which beats should have hits

4. **`update_target_visuals()`** (lines 421-464)
   - Creates/updates hit targets based on current layer's pattern
   - Positions targets around the wheel at correct angles
   - Adds pulse animations to draw attention

**Signal Emissions**:
- `drum_hit(drum_type, timing_quality, beat_number)` - On every hit attempt
- `layer_complete(drum_type)` - When all beats in a layer are hit
- `pattern_complete` - When all 3 layers are completed
- `beat_played(beat_number)` - Every time a new beat starts

### HUD (`scripts/ui/hud.gd`)

**Purpose**: Manages all UI elements including score, combo, lives, and pattern grid visualization.

**Key Properties**:
- `score`: Current player score
- `combo`: Current combo streak
- `active_beat_cells`: Visual representations of recorded beats

**Key Methods**:

1. **`_on_drum_hit(drum_type, timing_quality, beat_position)`** (lines 93-117)
   - Updates score based on timing quality and combo multiplier
   - PERFECT: 100 points × (1 + combo/10)
   - GOOD: 50 points × (1 + combo/10)
   - Resets combo on MISS

2. **`update_pattern_grid()`** (lines 224-282)
   - Visualizes the player's recorded pattern
   - Shows completed layers and current progress
   - Creates beat cells at grid positions

3. **`play_pattern_sounds_at_beat(beat_position)`** (lines 393-402)
   - Plays drum sounds for recorded beats during playback
   - Creates the looping drum pattern effect

4. **`show_completion_message(message)`** (lines 304-369)
   - Displays animated messages for layer/pattern completion
   - Slides in from right with fade effects

### GameDialog (`scripts/ui/game_dialog.gd`)

**Purpose**: Modal dialog system for level completion, game over, and victory screens.

**Key Features**:
- Score rollup animation with combo bonus
- 4-second delay before allowing progression (prevents accidental skips)
- Different dialog types with appropriate messaging
- Smooth slide-in/out animations

**Dialog Types**:
1. `LEVEL_COMPLETE`: Shows score and prompts for next level
2. `GAME_OVER`: Allows restart after 3 misses
3. `GAME_WIN`: Final victory screen after level 3

### GameData (`scripts/autoload/GameData.gd`)

**Purpose**: Global singleton managing game state and level data.

**Level Patterns**:
- **Level 1**: Simple patterns to learn mechanics
  - Kick: Beats 1, 5 (basic downbeat)
  - Snare: Beats 3, 7 (backbeat)
  - Hi-Hat: Beats 2, 4, 6, 8 (off-beats)

- **Level 2**: Four-on-the-floor pattern
  - Kick: Beats 1, 3, 5, 7 (all odd beats)
  - Snare: Beats 3, 7 (classic backbeat)
  - Hi-Hat: Beats 2, 6 (selective off-beats)

- **Level 3**: Complex breakbeat pattern
  - Kick: Beats 1, 4, 6 (syncopated pattern)
  - Snare: Beats 3, 5, 7, 8 (dense pattern)
  - Hi-Hat: Beats 1, 3, 4, 6, 8 (nearly full)

**BPM Progression**:
- Level 1: 120 BPM
- Level 2: 132 BPM
- Level 3: 144 BPM

---

## Signal Flow

The game uses signals extensively for decoupled communication:

```
DrumWheel signals:
├── drum_hit → HUD
│   └── Updates score, combo, lives
├── beat_played → HUD
│   ├── Updates beat cursor
│   └── Plays pattern sounds
├── layer_complete → HUD
│   └── Shows completion message
├── pattern_complete → HUD
│   └── Shows GameDialog
├── level_started → HUD
│   └── Resets UI for new level
└── game_over → HUD
    └── Shows game over dialog

GameDialog signals:
└── continue_pressed → HUD
    └── Advances level or resets game

PauseOverlay signals:
└── resume_pressed → (internal handling)
```

---

## Game State Management

### State Flow

1. **Level Start**
   - Load patterns from GameData
   - Reset player progress
   - Update BPM and rotation speed
   - Start music playback

2. **Gameplay**
   - Arrow rotates continuously
   - Player hits SPACE on beat targets
   - Successful hits recorded to pattern
   - Visual/audio feedback provided

3. **Layer Completion**
   - Check if all required beats hit
   - Show completion message
   - Advance to next drum type

4. **Pattern Completion**
   - All 3 layers completed
   - Show level complete dialog
   - Wait for player input

5. **Level Progression**
   - Increment level counter
   - Load new patterns/BPM
   - Reset game state

### Miss Handling

- 3 misses allowed per level
- Lives displayed as heart icons
- Game over on 3rd miss
- Full reset required after game over

---

## Audio System

### Audio Buses
- **Master**: Overall volume control
- **Music**: Background music tracks
- **SFX**: Drum sounds and UI effects

### Audio Players (in Game scene)
- `MusicPlayer`: Level-specific background music
- `KickPlayer`: Kick drum samples
- `SnarePlayer`: Snare drum samples  
- `HiHatPlayer`: Hi-hat samples
- `MissPlayer`: Miss sound effect
- `WinMusicPlayer`: Victory music (in HUD)

### Music Loading
Music files follow naming convention: `level-X-music.wav`
- Loaded dynamically based on current level
- 48kHz sample rate for web optimization
- Low latency settings (20ms output latency)

---

## Visual Effects System

### HitFeedbackManager (`scripts/effects/hit_feedback_manager.gd`)

Creates floating text feedback ("PERFECT", "GOOD", "MISS") at hit positions:
- Golden yellow for PERFECT
- Blue for GOOD  
- Magenta for MISS
- Animates up with fade out

### ScreenShakeManager (`scripts/effects/screen_shake_manager.gd`)

Camera shake effects for impact:
- `shake_perfect_hit()`: Subtle 0.3 intensity
- `shake_layer_complete()`: Medium 0.6 intensity
- `shake_pattern_complete()`: Strong 1.0 intensity

### Particle System

Hit particles spawn on successful hits:
- Use disc sprites with drum layer colors
- Burst outward from hit position
- More particles for PERFECT hits

---

## UI System

### Visual Design
- **Color Palette**: 
  - Blue (0.2, 0.8, 1.0) - Primary accent (Cyan-ish blue)
  - Magenta (0.85, 0.35, 0.85) - Secondary accent
  - Black (0.09, 0.09, 0.09) - Background
  - White (1.0, 1.0, 1.0) - Text

- **Typography**: Default Godot font at various sizes
- **Layout**: Left-aligned HUD, right-side pattern grid

### Pattern Grid Visualization

The pattern grid shows:
- 8 columns for beats
- 3 rows for drum types (K/S/H)
- Beat cursor moves with playback
- Active cells show recorded hits

### Pause System

- ESC/P keys toggle pause
- Pause overlay with semi-transparent background
- Game tree paused except UI
- Smooth scale/fade animations

---

## Input Handling

### Main Input: SPACE Key

The SPACE input is context-sensitive:

1. **During Gameplay**: Attempts drum hit
2. **Pattern Complete**: Advances to next level
3. **Dialog Visible**: Closes dialog (after delay)
4. **Game Over**: Restarts game

### Additional Inputs

- **ESC/P**: Pause/unpause
- **R**: Restart current level
- **Mouse Click**: Alternative to SPACE

### Input Blocking

Input is blocked when:
- Game is paused
- Dialog is visible but delay hasn't passed
- Spin animation is active (input still processed)

---

## Level Progression

### Level Structure

Each level consists of:
1. Unique drum patterns
2. Increased BPM
3. Level-specific music track

### Completion Requirements

To complete a level:
1. Hit all required beats in kick pattern
2. Hit all required beats in snare pattern
3. Hit all required beats in hi-hat pattern
4. Less than 3 total misses

### Score Calculation

- Base points: PERFECT (100), GOOD (50)
- Combo multiplier: 1 + (combo ÷ 10)
- Combo bonus at level end: combo × 100
- Score persists across levels

### End Game

After completing Level 3:
- Victory music plays
- Final score displayed
- Option to restart from Level 1

---

## Code Quality & Style

The codebase follows GDScript best practices:

- **Naming**: snake_case for variables/functions, PascalCase for classes
- **Organization**: Properties → Methods → Signal handlers
- **Documentation**: Clear method purposes and parameter descriptions
- **Error Handling**: Null checks for node references
- **Performance**: Efficient signal connections, proper cleanup

### Notable Patterns

1. **Tween Animations**: Extensive use for smooth UI
   - All tweens use `bind_node()` to prevent errors when targets are freed
   - Example: `tween.bind_node(target)` before animating properties
2. **Meta Properties**: Storing data on nodes (beat numbers, tweens)
3. **Signal Chaining**: Events cascade through proper channels
4. **Resource Preloading**: Scenes/assets loaded at startup

---

## Key Algorithms

### Beat Detection (`drum_wheel.gd` lines 235-244)
```gdscript
# Normalize angle to start at 12 o'clock
var normalized_angle = wrapf(arrow_rotation + PI/2, 0, TAU)
var beat_angle = TAU / 8
# Calculate closest beat with offset correction
var raw_beat = int(round(normalized_angle / beat_angle)) % 8
var closest_beat = (raw_beat - 2 + 8) % 8
```

### Timing Window Calculation
```gdscript
# Convert angle distance to time
var angle_distance = abs(angle_diff(arrow_rotation, beat_target_angle))
var time_difference = angle_distance / rotation_speed
```

---

## Tips for Modification

1. **Adding New Drum Types**: 
   - Extend DrumType enum
   - Add pattern arrays in GameData
   - Update visual effects in apply_visual_effect()

2. **Changing Difficulty**:
   - Adjust timing windows (PERFECT_WINDOW, etc.)
   - Modify BPM progression
   - Change max_misses allowed

3. **New Visual Effects**:
   - Add to apply_visual_effect() for drum-specific effects
   - Extend HitFeedbackManager for new feedback types
   - Modify particle system parameters

4. **UI Modifications**:
   - Pattern grid layout in HUD update_pattern_grid()
   - Dialog animations in GameDialog
   - Score calculations in _on_drum_hit()

5. **Preventing Tween Errors**:
   - Always use `tween.bind_node(target)` when animating nodes that might be freed
   - Check `is_instance_valid(node)` before operations in callbacks
   - Kill existing tweens stored in meta properties before creating new ones

---

This documentation covers all major aspects of the Beat Orbit codebase. Each system is designed to be modular and extensible, making it easy to add new features or modify existing behavior.