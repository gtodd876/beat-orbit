# Beat Orbit - Game Jam Todo List

## 🎯 Game Overview
Beat Orbit is a rhythm game where players time button presses as a single arrow rotates around a drum wheel. The game starts directly on the main gameplay screen. Players progress through rounds (Kick → Snare → Hi-Hat), with hit targets appearing on specific beats for each round. The pattern grid at the bottom controls drum sample playback and shows recorded hits.

## Current Implementation Status ✅
- ✅ Core gameplay loop working
- ✅ Single rotating arrow mechanic
- ✅ Layer-based progression (Kick → Snare → Hi-Hat)
- ✅ Wild animations on successful hits
- ✅ Pattern grid visualization
- ✅ Basic scoring and combo system
- ✅ Audio samples integrated
- ✅ Input system (SPACE to hit, ESC to pause, R to restart)
- ⚠️ Need to update: Pattern grid should control playback (not the wheel)
- ⚠️ Need to update: Current beat indicator in pattern grid

---

## 🔴 High Priority Tasks (Must Have for Game Jam)

### 1. Visual Assets Integration (1.5 hours)
- [X] Integrate background (synthwave grid/gradient)
- [X] Place magenta circle for beat positions
- [X] Position 4 blue hit targets on appropriate beats
- [X] Add drum wheel center graphic
- [X] Integrate rotating arrow
- [X] Style pattern grid with background
- [X] Add beat cells that light up when recorded
- [X] Add current beat indicator that moves along top row
- [X] Apply any glow effects/overlays

### 2. Gameplay Updates (1 hour)
- [X] Move drum sample playback from wheel to pattern grid
- [X] Implement current beat tracking in pattern grid (visual indicator)
- [X] Light up pattern grid cells on current beat (blue glow)
- [X] Update hit target positioning for round-based progression
- [X] Ensure arrow rotation is visual only (not tied to playback speed)

### 3. Level Design (1 hour)
- [ ] Design 4-5 levels with specific beat patterns per round
- [ ] Level 1: Kick (1,5), Snare (3,7), Hi-hat (2,4,6,8)
- [ ] Level 2: More complex beat placement patterns
- [ ] Level 3: Syncopated patterns with off-beats
- [ ] Level 4: Full drum kit patterns
- [ ] Configure BPM progression (120 → 130 → 140 → 150)

### 4. Game Structure (1 hour) 
- [ ] Skip main menu - start directly on gameplay
- [ ] Create level complete overlay showing score
- [ ] Add "Next Level" button to progress
- [ ] Create game over screen with final score
- [ ] Add restart functionality

### 5. Web Export (30 min)
- [ ] Test web build locally
- [ ] Optimize for 60fps performance
- [ ] Fix any audio latency issues
- [ ] Test in multiple browsers

### 6. itch.io Release (30 min)
- [ ] Create itch.io page
- [ ] Write game description
- [ ] Record gameplay GIFs
- [ ] Upload and test build

---

## 🟡 Medium Priority Tasks (Should Have)

### 7. Juice & Game Feel (1 hour)
- [ ] Create particle burst effects for Perfect/Good hits
- [ ] Add tweens for smooth UI animations
- [ ] Implement subtle screen shake on perfect hits
- [ ] Add satisfying UI sound effects

### 8. Audio Enhancement (45 min)
- [ ] Add synthwave background music loop
- [ ] Implement audio ducking during gameplay
- [ ] Add UI click sounds
- [ ] Create victory fanfare

### 9. UI Polish (45 min)
- [ ] Apply Affinity Designer color scheme throughout
- [ ] Find and implement synthwave-style font
- [ ] Improve score display with animations
- [ ] Add visual feedback for combo streaks

### 10. Pause System (30 min)
- [ ] Implement pause overlay with resume/restart options
- [ ] Ensure all animations pause correctly
- [ ] Add darkened background during pause

### 11. Tutorial (30 min)
- [ ] Create first-play instruction overlay
- [ ] Or make Level 1 a guided tutorial
- [ ] Add control reminders in UI

---

## 🟢 Nice to Have Tasks (If Time Permits)

### Additional Polish
- [ ] High score system with local storage
- [ ] Rank system (S/A/B/C) based on accuracy
- [ ] More drum variations (crash, tom)
- [ ] Colorblind mode
- [ ] Settings menu (volume control)
- [ ] More elaborate victory animations
- [ ] Background animations (moving grid, particles)

---

## 🚫 Out of Scope for Game Jam
- Multiplayer/leaderboards
- Level editor
- Custom patterns
- Mobile support
- Complex animation systems
- Story mode

---

## 📋 Testing Checklist
- [ ] Full playthrough of all levels
- [ ] Check timing accuracy feels good
- [ ] Verify 60 FPS on web build
- [ ] Test on Chrome, Firefox, Safari
- [ ] Get feedback from at least 3 playtesters
- [ ] Check audio sync on itch.io

---

## 🎮 End Goal
A polished, focused rhythm game that:
- Feels great to play with tight controls
- Has clear visual feedback
- Includes 4-5 levels of increasing difficulty
- Runs smoothly on web browsers
- Can be completed in 5-10 minutes
- Makes players want "just one more try"

**Remember**: Polish over features! A simple game that feels amazing is better than a complex game that feels rough.