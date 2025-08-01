# Beat Orbit - Game Jam Todo List

## 🎯 Game Overview
Beat Orbit is a rhythm game where players time button presses as a single arrow rotates around a drum wheel. Players must match pre-defined patterns for each drum layer (Kick → Snare → Hi-Hat) to progress.

## Current Implementation Status ✅
- ✅ Core gameplay loop working
- ✅ Single rotating arrow mechanic
- ✅ Layer-based progression (Kick → Snare → Hi-Hat)
- ✅ Wild animations on successful hits
- ✅ Pattern grid visualization
- ✅ Basic scoring and combo system
- ✅ Audio samples integrated
- ✅ Input system (SPACE to hit, ESC to pause, R to restart)

---

## 🔴 High Priority Tasks (Must Have for Game Jam)

### 1. Visual Polish (2 hours)
- [ ] Add synthwave background - grid pattern or gradient with glow
- [ ] Add glow shader to arrow and beat circles for neon effect
- [ ] Create proper visual styling for the drum wheel
- [ ] Add emission/bloom post-processing for that Tron aesthetic

### 2. Game Structure (1.5 hours)
- [ ] Create main menu scene with Play/Quit buttons
- [ ] Create level complete screen showing score and next level button
- [ ] Create game over screen with final score
- [ ] Implement proper scene transitions

### 3. Level Design (1 hour)
- [ ] Design 4-5 levels with progressively harder patterns
- [ ] Level 1: 60 BPM - Simple 4/4 pattern (tutorial)
- [ ] Level 2: 80 BPM - Add syncopation
- [ ] Level 3: 100 BPM - Complex patterns
- [ ] Level 4: 120 BPM - Full drum patterns
- [ ] Create level loading system

### 4. Web Export (30 min)
- [ ] Test web build locally
- [ ] Optimize for 60fps performance
- [ ] Fix any audio latency issues
- [ ] Test in multiple browsers

### 5. itch.io Release (30 min)
- [ ] Create itch.io page
- [ ] Write game description
- [ ] Record gameplay GIFs
- [ ] Upload and test build

---

## 🟡 Medium Priority Tasks (Should Have)

### 6. Juice & Game Feel (1 hour)
- [ ] Create particle burst effects for Perfect/Good hits
- [ ] Add tweens for smooth UI animations
- [ ] Implement subtle screen shake on perfect hits
- [ ] Add satisfying UI sound effects

### 7. Audio Enhancement (45 min)
- [ ] Add synthwave background music loop
- [ ] Implement audio ducking during gameplay
- [ ] Add menu click sounds
- [ ] Create victory fanfare

### 8. UI Polish (45 min)
- [ ] Style UI with neon colors (cyan, hot pink, purple)
- [ ] Find and implement synthwave-style font
- [ ] Improve score display with animations
- [ ] Add visual feedback for combo streaks

### 9. Pause System (30 min)
- [ ] Implement pause overlay with resume/restart/quit options
- [ ] Ensure all animations pause correctly
- [ ] Add darkened background during pause

### 10. Tutorial (30 min)
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