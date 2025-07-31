# TODO - Day 1 (Beat Orbit Development)

## 🎯 Morning Session (2-3 hours)
**Goal: Get the core game loop working**

### 1. Complete Scene Setup (30 min)
- [X] Create Game.tscn with proper node hierarchy
- [X] Create Arrow.tscn with basic triangle shape (Polygon2D)
- [X] Add DrumWheel node and attach script
- [X] Create hit zone visual (arc at top of wheel)
- [X] Test that arrows spawn and rotate correctly

### 2. Implement Audio System (45 min)
- [ ] Create AudioSequencer.gd script
- [ ] Add AudioStreamPlayer nodes for each drum type
- [ ] Load placeholder/temp drum sounds (can use Godot's built-in sine wave generator)
- [ ] Connect drum_hit signal to audio playback
- [ ] Test that sounds play on successful hits

### 3. Get Basic Gameplay Working (45 min)
- [ ] Implement proper hit detection with timing windows
- [ ] Add visual feedback for Perfect/Good/Miss
- [ ] Display current pattern as text (for debugging)
- [ ] Ensure pattern loops correctly
- [ ] Add beat indicator (visual pulse or text)

### 4. Quick Testing & Debugging (30 min)
- [ ] Verify BPM sync is working correctly
- [ ] Check that patterns record and loop properly
- [ ] Test all input methods (keyboard, mouse)
- [ ] Fix any critical bugs

---

## 🎵 Afternoon Session (2-3 hours)
**Goal: Add real audio and basic progression**

### 1. Audio Production (45 min)
- [ ] Export drum samples from Native Instruments:
  - [ ] Kick: 3 velocity layers (soft, medium, hard)
  - [ ] Snare: 3 velocity layers
  - [ ] Hi-hat: 3 velocity layers (closed)
  - [ ] Optional: Crash cymbal for level complete
- [ ] Normalize all samples, export as 16-bit WAV
- [ ] Import into Godot with correct settings

### 2. Create Level System (45 min)
- [ ] Create Level class or resource
- [ ] Define 3-4 levels with different:
  - [ ] BPM (60, 80, 100, 120)
  - [ ] Target patterns
  - [ ] Number of measures
  - [ ] Available drum types
- [ ] Implement level loading and progression

### 3. Basic UI Implementation (45 min)
- [ ] Create simple HUD showing:
  - [ ] Current level
  - [ ] Target pattern vs your pattern
  - [ ] Score/accuracy
  - [ ] Beat counter
- [ ] Add pause functionality
- [ ] Create minimal main menu (just Start button)

### 4. First Playable Build (45 min)
- [ ] Test complete game flow: menu → game → win → next level
- [ ] Export to HTML5
- [ ] Test in browser locally
- [ ] Upload to itch.io as private/draft
- [ ] Test on itch.io, note any issues

---

## 🌆 Evening Session (2-3 hours) 
**Goal: Polish and visual style**

### 1. Create Visual Assets (1 hour)
- [ ] Create in Affinity Designer/Inkscape:
  - [ ] Drum wheel (circle with gradient stroke)
  - [ ] Arrow shapes (distinct per drum type)
  - [ ] Hit zone indicator
  - [ ] Simple background pattern
- [ ] Export at appropriate sizes
- [ ] Import with correct filter settings

### 2. Implement Visual Effects (45 min)
- [ ] Add glow effect to arrows and wheel
- [ ] Create hit particle effect
- [ ] Add screen shake on perfect hits
- [ ] Implement color-coded feedback
- [ ] Add emission/bloom to UI elements

### 3. Game Feel Improvements (45 min)
- [ ] Add tweens for smooth animations
- [ ] Implement combo system with visual feedback
- [ ] Add satisfying sound effects for UI
- [ ] Create victory animation/effect
- [ ] Polish transitions between levels

### 4. End of Day Testing (30 min)
- [ ] Full playthrough of all levels
- [ ] Check performance (maintain 60 FPS)
- [ ] Test on different browsers
- [ ] List bugs for tomorrow
- [ ] Backup project!

---

## 📋 If Time Permits
- [ ] Add tutorial/instruction screen
- [ ] Create additional levels
- [ ] Implement high score saving
- [ ] Add more drum types (crash, toms)
- [ ] Create background music

## 🚫 Do NOT Do Today
- Complicated visual effects
- Perfect art (placeholder is fine)
- Feature creep
- Multiplayer/leaderboards
- Complex animation systems

## 💡 Quick Wins If Stuck
- Use Godot's built-in shapes for visuals
- Use simple colors instead of textures
- Focus on one perfect level rather than many rough ones
- Use text labels if UI is taking too long

## 🎮 End of Day Goal
**A playable game with:**
- Working core mechanic
- 3-4 levels
- Basic visual style
- Uploaded to itch.io (even if private)

Remember: Game feel > features. A simple game that feels great is better than a complex game that feels rough!