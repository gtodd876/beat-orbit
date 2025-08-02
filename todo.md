# Beat Orbit - Game Jam Todo List

## 🎯 Game Overview
Beat Orbit is a rhythm game where players time button presses as a single arrow rotates around a drum wheel. The game starts directly on the main gameplay screen. Players progress through rounds (Kick → Snare → Hi-Hat), with hit targets appearing on specific beats for each round. The pattern grid at the bottom controls drum sample playback and shows recorded hits.

## Current Implementation Status ✅
- ✅ Core gameplay loop working
- ✅ Single rotating arrow mechanic
- ✅ Layer-based progression (Kick → Snare → Hi-Hat)
- ✅ Wild animations on successful hits (kick spins, snare reverses, hihat changes direction)
- ✅ Pattern grid visualization with beat tracking
- ✅ Basic scoring and combo system
- ✅ Audio samples integrated (3 velocity layers per drum)
- ✅ Input system (SPACE to hit, ESC to pause, R to restart)
- ✅ Pattern grid controls playback
- ✅ Current beat indicator ("B" marker) in pattern grid
- ✅ Hit targets appear/disappear when successfully hit
- ✅ Completion messages for layers and patterns
- ✅ Beat detection properly aligned (1 at 12 o'clock, etc.)
- ✅ Music integration with BPM sync (Level 1 complete)
- ✅ Visual miss feedback (magenta line shows where arrow was pointing)
- ✅ Dialog positioning (level complete left, layer complete right)
- ✅ 4-second delay before "Press SPACE for next level"
- ✅ Pattern grid drum samples stay synced to music BPM

---

## 🔴 High Priority Tasks (Must Have for Game Jam)


### 1. Level Design (1 hour)
- [X] Design 4 levels with specific beat patterns per round
- [X] Level 1: Kick (1,5), Snare (3,7), Hi-hat (2,4,6,8)
- [X] Level 2: More complex beat placement patterns
- [X] Level 3: Syncopated patterns with off-beats
- [X] Level 4: Full drum kit patterns
- [X] Configure BPM progression (120 → 132 → 144 → 156)

### 2. Game Structure (1 hour) 
- [X] Skip main menu - start directly on gameplay
- [X] Create level complete overlay showing score
- [X] Use level complete overlay also for game over state
- [X] Add "Next Level" button to progress - use space
- [X] Add restart functionality (R key)

### 3. Background Music (30 min)
- [X] Add synthwave background music loop to level 1
- [ ] Add synthwave background music loop to level 2
- [ ] Add synthwave background music loop to level 3
- [ ] Add synthwave background music loop to level 4
- [X] Sync music BPM with game BPM

### 4. Music Integration Remaining (1.5 hours)
- [ ] Level 2 music (132 BPM) - needs creation and integration
- [ ] Level 3 music (144 BPM) - needs creation and integration  
- [ ] Level 4 music (156 BPM) - needs creation and integration
- [ ] Ensure BPM changes work correctly between levels

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

### 1. Juice & Game Feel (1 hour)
- [X] Create particle burst effects for Perfect/Good hits
- [X] Add tweens for smooth UI animations
- [X] Screen shake on perfect hits and pattern completion
- [X] Layer completion messages display for 3 seconds

### 2. Audio Enhancement (45 min)
- [ ] Create victory fanfare
- [X] Improve drum sample quality

### 3. UI Polish (45 min)
- [X] Apply Affinity Designer color scheme throughout
- [X] Find and implement synthwave-style font (Audiowide)
- [ ] Improve score display with animations
- [ ] Add visual feedback for combo streaks

### 4. Pause System (30 min)
- [X] Implement pause overlay with resume/restart options
- [X] Ensure all animations pause correctly
- [X] Add darkened background during pause

---

## 🟢 Nice to Have Tasks (If Time Permits)

### Quick Fixes Before Release
- [ ] Add victory music/fanfare for game completion
- [ ] Test and fix any edge cases with restart (R key)
- [ ] Verify all 4 levels progress correctly
- [ ] Clean up any debug print statements

### Additional Polish (If Time Permits)
- [ ] High score system with local storage
- [ ] Rank system (S/A/B/C) based on accuracy
- [ ] More drum variations (crash, tom)
- [ ] Colorblind mode
- [ ] Settings menu (volume control)
- [ ] More elaborate victory animations
- [ ] Background animations (moving grid, particles)
- [ ] Visual feedback for combo streaks (from medium priority)

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

---

## 📈 Progress Summary
- **Core Mechanics**: 100% Complete ✅
- **Visual Integration**: 100% Complete ✅
- **Level System**: 100% Complete (All 4 levels designed) ✅
- **Game Flow**: 90% Complete (Missing victory fanfare) ✅
- **Audio**: 70% (Level 1 music done, 3 more needed) 🟡
- **Polish**: 80% (Great game feel, missing combo streak visuals) 🟡
- **Web Export**: 0% (Next Priority) 🔴