# Beat Orbit - Rhythm Game Requirements

## Project Overview
A rhythm game for GMTK Game Jam 2025 (theme: "Loop") built in Godot 4.4. Players time button presses as arrows rotate around a drum wheel, building drum patterns that loop continuously.

## Game Mechanics
- **Single-button gameplay**: One input (spacebar/click) to hit drums
- **Rotating arrows**: Different arrow types (kick/snare/hi-hat) rotate around a circular wheel
- **Hit zone**: Fixed position where players must time their input
- **Pattern building**: Successfully hit drums are added to a looping pattern (2-4 measures)
- **Visual feedback**: Perfect/Good/Miss timing windows with color feedback

## Technical Stack
- **Engine**: Godot 4.4
- **Target Platform**: HTML5/Web (itch.io)
- **Resolution**: 1280x720
- **Audio**: 48kHz, 50ms latency for web
- **Art Style**: Synthwave/Tron aesthetic with neon glows

## Current Project State
- ✅ Project settings configured for web export
- ✅ Folder structure created
- ✅ Input mapping complete (hit_drum, pause_game)
- ✅ Audio buses configured (Master, Music, SFX, Drums)
- ✅ Autoload scripts (GlobalAudio.gd, GameData.gd)
- ✅ Core scripts created (DrumWheel.gd, Arrow.gd)
- ⏳ Scene setup in progress
- ❌ Visual assets not created
- ❌ Audio implementation pending
- ❌ Level progression system
- ❌ UI/HUD implementation

## File Structure
```
res://
├── scenes/
│   ├── game/
│   │   ├── Game.tscn (main game scene)
│   │   ├── DrumWheel.tscn 
│   │   └── Arrow.tscn
│   ├── ui/
│   │   ├── MainMenu.tscn
│   │   ├── HUD.tscn
│   │   └── PauseMenu.tscn
│   └── effects/
├── scripts/
│   ├── game/
│   │   ├── DrumWheel.gd (✅ created)
│   │   ├── Arrow.gd (✅ created)
│   │   └── AudioSequencer.gd
│   ├── ui/
│   └── autoload/
│       ├── GlobalAudio.gd (✅ created)
│       └── GameData.gd (✅ created)
├── assets/
│   ├── audio/
│   │   └── drums/ (needs samples)
│   └── art/
│       └── sprites/ (needs assets)
```

## Key Classes

### DrumWheel.gd
- Manages rotating arrows
- Handles hit detection and timing windows
- Records drum patterns
- Syncs rotation to BPM

### Arrow.gd  
- Individual arrow visuals
- Drum type assignment (kick/snare/hihat)
- Color coding by type

## Immediate Tasks Needed

### 1. Scene Assembly
- Create Game.tscn with proper node hierarchy
- Link DrumWheel script and configure exported variables
- Set up Arrow.tscn with placeholder graphics
- Add hit zone visual indicator

### 2. Audio Implementation
- Load drum samples into AudioStreamPlayers
- Connect audio playback to drum hit events
- Implement quantized playback for pattern looping
- Add click track/metronome option

### 3. Visual Assets (Synthwave Style)
- **Drum wheel**: Neon circle with glow effect
- **Arrows**: Geometric shapes with color coding (red=kick, green=snare, blue=hihat)
- **Hit zone**: Pulsing arc segment
- **Background**: Animated grid or starfield
- **UI elements**: Minimalist with high contrast

### 4. Game Flow
- Main menu with "Start" and level select
- Tutorial level (slow BPM, kick only)
- 5-7 levels with increasing complexity
- Victory condition: Match target pattern
- Scoring system with combo multiplier

### 5. Polish & Effects
- Particle effects on successful hits
- Screen shake on perfect hits
- Beat-synced visual effects
- Smooth transitions between levels

## Art Direction
- **Colors**: Deep purple (#1a0033), bright cyan (#00ffff), hot pink (#ff006e), white accents
- **Effects**: Heavy use of glow/bloom, emission shaders
- **Style**: Clean geometric shapes, avoid pixel art
- **Tools**: Affinity Designer or Inkscape for asset creation

## Audio Resources
- Native Instruments Komplete available for drum samples
- Need: kick, snare, hi-hat samples (3-4 velocity layers each)
- Optional: crash, ride, toms for advanced levels
- Background music tracks for each level

## Level Design Guidelines
1. **Tutorial**: 60 BPM, kick only, 1 measure
2. **Level 1**: 80 BPM, kick + snare, 2 measures  
3. **Level 2**: 100 BPM, add hi-hat, 2 measures
4. **Level 3**: 120 BPM, all drums, 4 measures
5. **Level 4**: 140 BPM, complex patterns
6. **Bonus levels**: Polyrhythms, odd time signatures

## Performance Targets
- Maintain 60 FPS on web
- Load time under 5 seconds
- File size under 50MB for itch.io
- Support mouse, keyboard, and gamepad

## Testing Checklist
- [ ] Audio latency acceptable on web
- [ ] All input methods working
- [ ] Visual feedback clear and responsive
- [ ] Difficulty curve appropriate
- [ ] No memory leaks during extended play
- [ ] Works in Chrome, Firefox, Safari

## Export Settings
- HTML5 export with Godot 4.4
- Compression enabled
- Focus canvas on start
- Canvas resize policy: Project settings

## Game Jam Deadline
- Submission deadline: [Check GMTK website]
- Target 90% completion 2 hours before deadline
- Reserve final time for testing and bug fixes

## Additional Notes
- Keep scope manageable - better to have 5 polished levels than 10 rough ones
- Prioritize game feel and responsiveness over feature count
- Test early and often on itch.io
- Consider accessibility (visual indicators for audio cues)