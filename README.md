# 🏃 Stick Adventure

A daily AI-generated monster hunt adventure game built with **Flutter + Flame** for iOS and Android.

## What Is It?

Every day, a new procedurally-generated creature spawns in the game world. Explore 4 zones of increasing difficulty, battle enemies, discover rest spots, and catch the daily creature to add it to your **MonsterDex** — a calendar-style collection tracker.

## Features

- **🗺️ 4 Zones** — Peaceful Meadow → Whispering Forest → Scorched Highlands → Abyssal Edge
- **🎯 Daily Creature Hunt** — Deterministic procedural generation: same creature worldwide each day
- **📖 MonsterDex** — Calendar grid view showing caught/missed creatures with full detail cards
- **🚶 Idle Auto-Explore** — Toggle auto-walk with smart alerts for enemies, creatures, low HP
- **⚔️ Combat** — Auto-resolve fights with zone-scaled enemies, earn XP
- **📊 Leveling** — XP from catching, exploring, fighting; level gates for zones
- **🏠 Home Base** — Safe zone at distance 0 with full HP restore
- **✦ Rest Spots** — Discoverable healing spots scattered through zones
- **🔥 Streak Tracking** — Consecutive daily catches tracked

## Screenshots

*Coming soon*

## Tech Stack

- **Flutter 3.41+** — Cross-platform framework
- **Flame 1.22** — 2D game engine
- **SharedPreferences** — Local persistence
- **Canvas-drawn** stick figure (no sprite sheets needed)

## Getting Started

```bash
# Clone
git clone https://github.com/broccolilife/stick-adventure.git
cd stick-adventure

# Install dependencies
flutter pub get

# Run on connected device/simulator
flutter run
```

## Game Controls

- **Left joystick** — Move left/right
- **JUMP button** — Jump (right side)
- **CATCH button** — Catch nearby creatures
- **ATK button** — Attack enemies
- **AUTO toggle** — Enable idle auto-explore mode

## Zones

| Zone | Distance | Level | HP Drain |
|------|----------|-------|----------|
| Peaceful Meadow | 0-500m | 1+ | 1/min |
| Whispering Forest | 500-1500m | 5+ | 3/min |
| Scorched Highlands | 1500-3000m | 15+ | 5/min |
| Abyssal Edge | 3000m+ | 30+ | 10/min |

## XP Rewards

- Catch creature: 50 × rarity multiplier
- Kill enemy: 10-50 XP (based on level)
- Explore 100m: 5 XP
- Find rest spot: 20 XP
- Complete zone: 200 XP

## License

MIT
