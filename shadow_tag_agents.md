# Shadow Tag — Shipping Spec (agents.md)

Authoritative build plan for a polished, ready-to-publish Roblox gamemode. No placeholders. Desktop, mobile, and console (Xbox) supported. Codex must implement exactly as specified.

---

## 0) High-Level Summary
Multiplayer survival. A small team of Shadows hunts Survivors in an arena where darkness spreads and empowers the Shadows. Survivors use light, stamina, teamwork, and short-cooldown tools to evade until a timed escape portal appears. Infection is enabled: tagged Survivors convert to Shadows. Four shipping maps with unique mechanics and full art/audio spec.

---

## 1) Platform Targets
- **Desktop**: Windows/macOS Roblox client. Mouse + keyboard.
- **Mobile**: iOS and Android Roblox client. Multi-touch.
- **Console**: Xbox controller. Safe-area compliant. UI readable at 720p+.
- **Frame rate**: Target 60 FPS. Accept 30 FPS floor on lower-end mobile; gameplay remains fair.

Lighting mode: **Future** with shadow map. HDR enabled. Dynamic lights capped per map (see §14).

---

## 2) Design Pillars
- **Hunt Tension**: Clear predator-prey dynamic with fair counters.
- **Readability**: Light vs dark contrast, clear silhouettes, clean UI.
- **Short Sessions**: 6–10 minute matches.
- **Cross-Platform Parity**: Equal viability on PC, mobile, console.
- **Performance Discipline**: Strict budgets; no spikes.

---

## 3) Roles and Abilities

### Survivors
- **Goal**: Live until the escape portal opens and exit, or last survivor at timer end.
- **Core Stats**: HP 100; WalkSpeed 14; SprintSpeed 18; Stamina 100; Stamina Regen 18/sec; Stamina cost 25/sec when sprinting.
- **Tools**:
  - **Flashlight**: 35° cone, range 38 studs. Battery 90 s continuous. Recharges at stations in 12 s. Light suppresses Shadow opacity and removes their speed buff while in cone.
  - **Push**: 3 m cone shove. Cooldown 10 s. Cancels Shadow grapple.
  - **Ping**: Team ping on world objects. Cooldown 8 s. On console: LB+RB.
  - **Interact**: Doors, switches, recharge, keys, ladders.
- **Debuffs**:
  - In deep shadow zones, stamina regen halved. Screen vignette increases.

### Shadows
- **Goal**: Convert or eliminate all Survivors before timer ends.
- **Core Stats**: HP 140 equivalent “form stability”; WalkSpeed 15; ShadowZone Speed Multiplier 1.12; Light Suppression reduces speed to 14 and opacity to 55%.
- **Abilities**:
  - **Phase Dash**: 10 m short teleport, ignores collisions. Cooldown 8 s. Leaves 0.4 s afterimage.
  - **Dark Surge**: 6 m AoE slow (40%) and 1.2 s blackout of Survivor flashlights. Cooldown 12 s.
  - **Wall Cling / Ambush**: Hold to stick to walls/ceilings in shadow zones. Leap attack 8 m, 0.4 s windup.
  - **Grapple Tag**: Melee lunge 3 m. On hit, 0.6 s hold; Survivor can **Push** to break if off cooldown.
- **Passives**:
  - **Shadow Feed**: Standing in shadow zones for 2 s restores 6 stability/sec.
  - **Infection**: Tagged Survivors respawn as Shadows after 3 s at nearest dark node.

---

## 4) Match Flow
- **Lobby (15 s)**: Map vote. Role lottery displays odds; party members may queue together.
- **Prep (20 s)**: Survivors spawn spread; pickups seeded. Shadows locked in spawn.
- **Hunt (6–8 min)**: Darkness expands; elites modifiers trigger at set times.
- **Endgame (60 s)**: Escape portal spawns at one of 3 pre-authored sites. All Shadows gain +6% speed and -2 s ability cooldowns.
- **Results (10 s)**: Rewards, progression, commendations.

Default population: 10 players → 2 Shadows + 8 Survivors. Scale: 6–12 total players, 1 Shadow per 4–6 Survivors.

Overtime: If a Survivor is in portal activation radius at 00:00, extend until they exit or are tagged.

---

## 5) Scoring, Rewards, and Persistence
- **Currencies**: Coins (common), Essence (rare).
- **Awards**:
  - Survivors: time survived, portal escape, assists (push breaks), objective activations.
  - Shadows: tags, multi-tags, ambush tags from cling, fastest wipe.
- **Progression**: Cosmetic unlocks only. No gameplay stat upgrades.
- **Data Stored**: Owned cosmetics, match stats, best escape time, total tags. DataStore with retry/backoff and soft-fail cache.

---

## 6) Darkness System
- **Zones**: Circular nodes placed per-map. Darkness radii expand by schedule. Max coverage 70% map space.
- **Light Interaction**: In darkness, world ambient drops; post-process increases grain and vignette. Survivor flashlights weaken zone effect inside cone; stationary light sources carve safe areas.
- **Expansion Schedule**: t=0 spawn 3 nodes active; +120 s expand 20%; +240 s activate 2 more nodes; +360 s expand 20%; cap at 70%.
- **Safe Lights**: Recharge stations, campfires, lantern posts, electrical panels (map-specific).

---

## 7) Interaction Objects
- **Recharge Station**: Restores flashlight battery. 12 s channel; emits area light. Limited to 3 uses per station per match.
- **Doors**: Silent swing in light, creak in darkness. Some doors locked; keys spawn with soft guidance.
- **Ladders / Vents**: Navigation options; Shadows can Phase Dash through vents.
- **Breakers**: Map-wide light restores for 20 s with 90 s cooldown; located in risky zones.
- **Campfires / Lanterns**: Temporary light with finite fuel (Forest/City).

---

## 8) Maps (4 total, shipping)

### 8.1 Warehouse: “Steelhide Depot” (Small, High LoS Breaks)
- **Theme**: Industrial cargo terminal. Wet floor reflections, steam vents.
- **Layout**: 3 aisles of crates, mezzanine catwalks, loading bay, office block.
- **Unique Mechanic**: Forklift power key randomly placed; if used, bay door opens, creating a risky shortcut to portal spawns.
- **Light Sources**: Flickering fluorescents, emergency beacons, 4 recharge stations, 1 main breaker.
- **Shadow Nodes**: 5 nodes. Initial 2 in corners, 1 at loading bay, 2 activate later.
- **Spawn Points**: 12 Survivor spawns, 2 Shadow spawns (opposite ends).
- **Art Set**: PBR metal panels, grime decals, puddle planes, animated fans.
- **Audio**: Dripping water, distant forklifts, metallic creaks.
- **Budget**: ≤ 2500 parts; 18 lights; 30 decals; navmesh proxies 0.

### 8.2 Forest: “Blackpine Reserve” (Medium, Open With Occluders)
- **Theme**: Nocturnal forest, fog banks, swaying trees, fireflies.
- **Layout**: Campsites, creek with bridges, ranger tower, cave system.
- **Unique Mechanic**: Firefly swarms follow Survivors for 10 s after interaction, granting moving light.
- **Light Sources**: Campfires (fuel 60 s), lantern posts, 3 recharge stations, tower spotlight.
- **Shadow Nodes**: 6 nodes. Creek bed has strong darkness but breaks near waterfalls.
- **Spawn Points**: 16 Survivor, 2 Shadow near cave and tower base.
- **Art Set**: Wind-animated foliage meshes, wet rock shaders, volumetric fog planes.
- **Audio**: Wind gust layers, owls, creek flow, twig snaps.
- **Budget**: ≤ 2800 parts; 16 lights; foliage impostors beyond 120 studs.

### 8.3 Asylum: “St. Verity Wing” (Large, Multi-Floor)
- **Theme**: Abandoned hospital. Flicker bulbs, peeling paint, broken windows.
- **Layout**: Two floors + basement. Wards, operating rooms, long corridors, service shafts.
- **Unique Mechanic**: Wing Breakers. Restores an entire wing’s light for 20 s (global light switch with cooldown).
- **Light Sources**: Emergency hall lights, OR lamps, 4 recharge stations.
- **Shadow Nodes**: 7 nodes. Basement start; strong choke points.
- **Spawn Points**: 20 Survivor, 3 Shadow (basement morgue, boiler, loading tunnel).
- **Art Set**: Tiled floors with grime decals, flicker shader for bulbs, broken glass planes.
- **Audio**: Vent howls, distant gurney wheel, intercom static bursts.
- **Budget**: ≤ 3000 parts; 22 lights; interior fog volumes paced per room.

### 8.4 Coastal City: “Harborline District” (Medium-Large, Vertical)
- **Theme**: Rainy neon waterfront. Alleyways, rooftops, pier, subway entrance.
- **Layout**: Street grid with alley shortcuts, rooftop path network, pier end portal spawn chance.
- **Unique Mechanic**: Neon signs act as hackable light to create temporary safe lanes. Rain reduces Shadow afterimages, improving stealth but dampening audio cues.
- **Light Sources**: Neon billboards, street lamps, interior shop lights, 3 recharge kiosks.
- **Shadow Nodes**: 6 nodes. Rooftop access gives uneven light distribution.
- **Spawn Points**: 18 Survivor, 2 Shadow (subway tunnel and pier warehouse).
- **Art Set**: PBR wet asphalt with puddle masks, emissive neon textures, raindrop particle sheets.
- **Audio**: Rain loops, ship horns, subway rumbles, neon buzz.
- **Budget**: ≤ 2900 parts; 20 lights; occlusion portals for interiors.

---

## 9) UI/UX and Accessibility
- **HUD (Survivor)**: HP, Stamina, Flashlight battery, Timer, Minimal compass, Ping indicator.
- **HUD (Shadow)**: Ability cooldowns, Darkness meter, Survivor count.
- **Menus**: Map vote, role odds, cosmetics, settings, controller glyphs.
- **Accessibility**: Colorblind-friendly UI hues; adjustable brightness and vignette; camera shake toggle; reduced SFX mode; subtitles for key events.
- **Console Safe Area**: 90% safe zone; all HUD elements within.
- **Localization**: English baseline with key set; right-to-left not required. Text length reserve 30% for expansion.

---

## 10) Controls Mapping

### Desktop
- Move: WASD. Sprint: Shift. Crouch: Ctrl. Jump: Space.
- Flashlight: F. Push: Q. Ping: Middle Mouse. Interact: E.
- Shadow: Phase Dash: Right Mouse. Dark Surge: R. Wall Cling: Hold Space near wall.

### Mobile
- Left virtual stick: move. Right stick: camera.
- Buttons: Sprint, Flashlight, Push, Interact. Shadow: Dash, Surge, Cling.
- Auto-pickup for keys within 2 studs. Aim assist 5° cone for Push.

### Console (Xbox)
- Move: LS. Look: RS.
- Sprint: LB (hold). Crouch: B.
- Jump: A.
- Interact: X.
- Flashlight: Y (toggle).
- Push: RB.
- Ping: LS press.
- Shadow Phase Dash: RT.
- Shadow Dark Surge: LT.
- Wall Cling: Hold A near wall while in shadow zone.
- Menu/Pause: Menu button. Scoreboard: View button.
- **Controller Glyphs**: Platform-specific icons in HUD prompts.
- **Input buffering**: 100 ms buffer for combos; rumble feedback on tags and portal open.

---

## 11) Networking and Authority
- Server authoritative for: tagging, damage, conversions, pickups, darkness expansion, portal state.
- Remotes:
  - `Net/ReqPush` (client→server): rate-limited, server does overlap check.
  - `Net/ReqInteract` (client→server): validates target instance and distance.
  - `Net/DoFlashCone` (client→server): periodic sample of flashlight direction; server resolves suppression.
  - `Net/PortalEnter` (client→server): server checks radius and state.
- Anti-cheat: sanity limits, server side position sampling, cooldown enforcement.

---

## 12) Economy and Cosmetics
- **Store**: Skins for Survivors and Shadows, flashlight skins, auras, trails, finishers. All cosmetic.
- **Rarity**: Common, Rare, Epic. Purchased with Coins; certain featured sets with Essence.
- **No Lootboxes**: Direct purchase and seasonal bundles. Secure UGC compliance.

---

## 13) Audio Spec
- **Mix**: Master (-6 dBFS headroom), Music, SFX, VO, Ambience buses. Ducking: SFX duck music by 3 dB on tags.
- **Survivor SFX**: Footsteps (material variants), heartbeat near Shadow, flashlight click, low-battery buzz, push whoosh, portal hum.
- **Shadow SFX**: dash whoosh, surge pulse, cling skitter, lunge impact, conversion roar.
- **Ambience per Map**: listed in §8. Loop length ≥ 60 s. Seamless.
- **Delivery**: 44.1 kHz or 48 kHz WAV → compressed in Roblox. Loop points authored.
- **Dynamic**: RTPC-like routing via distance and darkness factor for filter/volume.

---

## 14) Graphics and VFX
- **Lighting**: Future lighting. Max 20 dynamic lights per map; priority based on proximity. Shadow-casting on key lights only.
- **Materials**: PBR where possible using MeshParts. Detail via decals and trim sheets.
- **Post**: Mild bloom, vignette in darkness, color grading per-map.
- **VFX**: Particle afterimages on Phase Dash, embers at campfires, rain sheets in Harborline, dust motes in Asylum.
- **LODs**: Mesh LODs with impostors past 120–160 studs.
- **Budget**: See map budgets; particle count ≤ 150 active.

---

## 15) Performance Budgets
- Server step ≤ 16 ms at 60 Hz target. Client render ≤ 16 ms typical; ≤ 33 ms worst-case.
- Active characters ≤ 12. Total parts ≤ 3k per map. Draw calls minimized via instancing.
- Physics: No more than 20 moving assemblies.
- Raycasts: Flashlight 8/sec per Survivor; total ≤ 80/sec.
- Network: Replicated events ≤ 30/sec average.

---

## 16) Data Model (canonical)

```lua
GameDef = {
  Build = { version = "1.0.0", schema = 1 },
  Match = {
    PrepTime = 20, HuntMin = 360, HuntMax = 480, Endgame = 60,
    Infection = true, ShadowsPerSurvivorMin = 1/6, ShadowsPerSurvivorMax = 1/4,
  },
  Player = {
    Survivor = { HP=100, Walk=14, Sprint=18, Stamina=100, StamRegen=18, PushCD=10, PingCD=8,
                 FlashRange=38, FlashAngle=35, FlashBattery=90, FlashRecharge=12 },
    Shadow   = { HP=140, Walk=15, SpeedInDark=1.12, SuppressedWalk=14, DashCD=8, SurgeCD=12,
                 AmbushRange=8, GrappleRange=3, FeedRate=6 }
  },
  Darkness = {
    MaxCoverage=0.7,
    Expansion = {
      {t=0,    expand=0.0, activateNodes=3},
      {t=120,  expand=0.2 },
      {t=240,  activateNodes=2},
      {t=360,  expand=0.2 }
    }
  },
  Maps = {
    SteelhideDepot = { size="Small", nodes=5, lights=18, stations=4, breakers=1 },
    BlackpineReserve = { size="Medium", nodes=6, lights=16, stations=3, breakers=1 },
    StVerityWing = { size="Large", nodes=7, lights=22, stations=4, breakers=2 },
    HarborlineDistrict = { size="MedLarge", nodes=6, lights=20, stations=3, breakers=1 },
  },
  Economy = {
    Rewards = { SurvivePerMin=6, EscapeBonus=40, Assist=6, Tag=10, MultiTag=6, AmbushTag=8, Wipe=40 },
    Drop = { EssenceChance=0.06 }
  }
}
```

---

## 17) Folder and File Structure

```
ReplicatedStorage/
  Shared/
    GameDef.lua
    Signals.lua
    Types.lua
    Util.lua
  Net/
    Remotes.lua

ServerScriptService/
  SrvInit.server.lua
  Match.server.lua
  Darkness.server.lua
  Spawns.server.lua
  Interact.server.lua
  Tagging.server.lua
  Economy.server.lua
  Save.server.lua

StarterPlayer/
  StarterPlayerScripts/
    ClientInit.client.lua
    Controller.client.lua
    SurvivorHUD.client.lua
    ShadowHUD.client.lua
    Flashlight.client.lua
    Ping.client.lua
    Audio.client.lua
  StarterCharacterScripts/
    Camera.client.lua

StarterGui/
  HUD.gui
  Menus.gui
  Vote.gui
  Results.gui
  Settings.gui

Lighting/
  PostFX
  ColorCorrection
  Bloom
```

All files must be created. No stubs.

---

## 18) QA and Tests
- **Smoke.server.lua**: Start match, run darkness expansion, spawn portal, validate no nils.
- **TagFlow.server.lua**: Simulate tag and infection loop, ensure timers and conversions.
- **Input.client.lua**: Validate control mappings across PC/mobile/console emulation.
- **Perf.server.lua**: Spawn max players and measure server step; assert within budget.
- **UX.client.lua**: Verify safe-area and font scales.

---

## 19) Compliance and Policies
- **Console**: Safe-area 90%, pausing supported, persistent settings saved, no external links.
- **Privacy**: No external HTTP. Analytics via `AnalyticsService` only.
- **Moderation**: Chat filtered. No offensive content in cosmetics. Audio within Roblox policy.

---

## 20) Release Checklist
- [ ] All four maps completed per §8.
- [ ] Darkness system meets schedule and coverage.
- [ ] Controls tested on PC, mobile, console.
- [ ] Performance budgets respected.
- [ ] Cosmetics store functional and cosmetic-only.
- [ ] Localization keys resolved; English shipped.
- [ ] Data safety with retries; failure shows user-safe messaging.
- [ ] Changelog updated to 1.0.0.

---

## 21) Changelog (initial)
**1.0.0**
- Shipping build. Four maps, cross-platform, cosmetic economy, full audio/graphics, infection mode, escape portal endgame.
