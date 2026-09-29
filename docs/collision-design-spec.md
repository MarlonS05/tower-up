# Collision system — Design & Layout Specification

<!--
  AGENT METADATA — parse before implementing
  feature_id: collision
  product_name: Tower Up
  source: N/A
  target_platform: Flutter / Flame
  status: in-progress
-->

> **Purpose:** Machine-readable design spec for the player–world collision system.
> **Audience:** Coding agents and contributors. Follow `AGENTS.md` and
> `docs/architecture.md` before writing code.

---

## Document map

| § | Section |
|---|---------|
| 0 | [Repo conventions](#0-repo-conventions) |
| 1 | [Feature overview](#1-feature-overview) |
| 2 | [Data model](#2-data-model) |
| 3 | [Component reuse](#3-component-reuse) |
| 4 | [Game components](#4-game-components) |
| 5 | [Collision resolution](#5-collision-resolution) |
| 6 | [Level authoring](#6-level-authoring) |
| 7 | [Out of scope](#7-out-of-scope) |
| A | [Implementation checklist](#appendix-a-implementation-checklist) |

---

## 0. Repo conventions

| Rule | This feature |
|------|--------------|
| Layer | All code under `lib/game/` — no `repo/`, `db/`, `di/`, or `router/` imports |
| Screens / BLoC / routes | N/A — pure Flame gameplay; no presentation screens |
| Persistence | N/A — collision is runtime-only from Tiled object layers |
| Errors | Missing `spawnpoints` / `collisions` layers: skip that section (no throw) |
| Theme / UI tokens | N/A |

**Replaces:** N/A (first collision design spec).

**Reference implementations:** `lib/game/components/level.dart`, `player.dart`, `collision_block.dart`, `helpers/collision_helper.dart`, `helpers/coordinates_helper.dart`, `config/player_config.dart`.

---

## 1. Feature overview

Prevents the player from moving into solid world geometry authored in Tiled.

### 1.1 Runtime flow

- **Load:** `Level` loads `{levelName}.tmx`, spawns the player from `spawnpoints`, builds `CollisionBlock`s from `collisions`.
- **Detect:** Flame `HasCollisionDetection` on `Level`; player and blocks use `RectangleHitbox` + `CollisionCallbacks`.
- **Resolve:** On `onCollisionStart` with a `CollisionBlock`, compute blocked cardinal directions; on `onCollisionEnd`, clear that block’s blocks. Each frame, zero velocity axes that are not in `allowedDirections`.

### 1.2 Flows

- **Enter solid:** collision start → forbidden directions for that block → merge into `allowedDirections` → movement clamped.
- **Leave solid:** collision end → remove block entry → recompute `allowedDirections`.
- **Multiple solids:** forbidden directions are the union across all active `CollisionBlock`s.

---

## 2. Data model

```dart
enum MoveableDirection { left, up, right, down }

MoveableDirection getMoveableDirectionOpposite(MoveableDirection direction);

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  // position + size from Tiled object; RectangleHitbox in onLoad
}

// Player
List<MoveableDirection> allowedDirections; // default: all values
Map<CollisionBlock, List<MoveableDirection>> collisionBlocks;
```

| Value | Role |
|-------|------|
| `MoveableDirection` | Cardinal axes the player may be blocked on |
| `CollisionBlock` | One Tiled rectangle solid |
| `Player.allowedDirections` | Axes still free after merging active collisions |
| `Player.collisionBlocks` | Per-block forbidden directions while overlapping |

**Default:** all four `MoveableDirection`s allowed; empty `collisionBlocks`.

**Persistence:** none — geometry comes from the Tiled `collisions` object group at level load.

### 2.1 PlayerConfig (collision-relevant)

Source: `lib/game/config/player_config.dart`. Player must read these — no hardcoded hitbox/speed literals in collision paths.

| Field | Current value | Collision role |
|-------|---------------|----------------|
| `playerHitboxSize` | `Vector2(12, 14)` | Player `RectangleHitbox` size (AABB vs solids) |
| `playerHitboxPosition` | `Vector2(10, 9)` | Hitbox offset inside the sprite |
| `playerScale` | `Vector2.all(2)` | Visual/component scale; hitbox is local to the component |
| `moveSpeed` | `180` | Cardinal speed before `allowedDirections` clamp |
| `diagonalMoveSpeedDivider` | `1.4` | Builds `diagonalMoveSpeed` |
| `diagonalMoveSpeed` | `moveSpeed / divider` | Diagonal speed before clamp |

Not collision: `animationCycleTime`. Not this feature: `SetupConfig` (camera/joystick).

**Tiled contract:**

| Layer / field | Requirement |
|---------------|-------------|
| Object group name | `collisions` (lowercase) |
| Object | `x`, `y`, `width`, `height` → `CollisionBlock` position/size |
| Object group name | `spawnpoints` (lowercase) |
| Player spawn | object `class_` / type `Player` |

---

## 3. Component reuse

### 3.1 Reuse as-is
- Flame `RectangleHitbox`, `CollisionCallbacks`, `HasCollisionDetection`
- `flame_tiled` `ObjectGroup` / map objects

### 3.2 Adapt
- `Level`: load `collisions` after spawnpoints; keep `HasCollisionDetection`
- `Player`: mix in `CollisionCallbacks`; clamp movement with `allowedDirections`

### 3.3 Do not reuse
- Domain / repo / DB — no persistence of collision state
- Screen widgets / BLoCs — not a UI feature

### 3.4 Build new
| Path | Role |
|------|------|
| `lib/game/components/collision_block.dart` | Solid AABB + hitbox |
| `lib/game/components/helpers/collision_helper.dart` | Intersection → forbidden `MoveableDirection`s |
| `lib/game/components/helpers/coordinates_helper.dart` | Midpoint / closest-corner helpers |
| `lib/game/config/player_enums.dart` | `MoveableDirection` + opposite helper |
| `lib/game/config/player_config.dart` | Hitbox size/offset, scale, move speeds |

---

## 4. Game components

### 4.1 Level (`lib/game/components/level.dart`)

```yaml
component: Level
extends: World
mixins: HasCollisionDetection
```

- Load TMX via `TiledComponent.load("$levelName.tmx", LevelsConfig.tileSize)`.
- For each object in `collisions`: create `CollisionBlock(position, size)`, `add` to world, append to `collisionBlocks`.
- Player hitbox is owned by `Player`, not Level.

### 4.2 CollisionBlock

```yaml
component: CollisionBlock
extends: PositionComponent
mixins: CollisionCallbacks
hitbox: RectangleHitbox() // full size
```

### 4.3 Player

```yaml
component: Player
extends: SpriteAnimationGroupComponent
mixins: HasGameReference<TowerUpGame>, CollisionCallbacks
scale: PlayerConfig.playerScale
hitbox: RectangleHitbox(
  size: PlayerConfig.playerHitboxSize,
  position: PlayerConfig.playerHitboxPosition,
)
```

- `onCollisionStart`: if `other is CollisionBlock`, store `CollisionHelper.getCollisionDirections(first, last, other, this)` then `_updateAvailableDirections()`.
- `onCollisionEnd`: `collisionBlocks.remove(other)` then `_updateAvailableDirections()`.
- `_updatePlayerMovement`: build velocity from `PlayerConfig.moveSpeed` / `PlayerConfig.diagonalMoveSpeed` and joystick direction; if an axis is disallowed set that component to `0`; then `position += velocity * dt`.

---

## 5. Collision resolution

`CollisionHelper.getCollisionDirections(p1, p2, block, player)`:

1. Classify each intersection point onto a block edge via `_getIntersectionSide` (`x == left/right` or `y == top`; else down).
2. **Same edge (both points):** block the opposite cardinal (e.g. both on left → forbid `right`).
3. **Opposite edges:** treat as small/thin intrusion; pick closest side midpoint to the intersection midpoint; forbid the opposite of that side.
4. **Adjacent edges (corner):** closest rectangle corner to intersection midpoint; forbid the more-intruded of the two opposite sides.
5. Player merges forbidden lists with set-union; `allowedDirections` = all cardinals minus that set.

Movement clamp (player update):

- `directionX < 0` and left forbidden → `directionX = 0`
- `directionX > 0` and right forbidden → `directionX = 0`
- `directionY < 0` and up forbidden → `directionY = 0`
- `directionY > 0` and down forbidden → `directionY = 0`

---

## 6. Level authoring

- Author solids in Tiled object layer named exactly `collisions`.
- World bounds may be thin rectangles (as in `level-1-big.tmx`).
- Rename layers carefully: code expects lowercase `collisions` and `spawnpoints`.

---

## 7. Out of scope

- Screen / BLoC / router integration
- Persisting collision state or saves
- Tile-based / auto-generated collision from tile GIDs (objects only)
- Slope / one-way / trigger / damage volumes
- Physics engines (Box2D etc.) — AABB + custom direction blocking only
- `SetupConfig` camera/joystick and `PlayerConfig.animationCycleTime`
- Resolving float edge-epsilon, unordered `Set` intersection points, or unused `Level.collisionBlocks` consumers (current code as documented)

---

## Appendix A. Implementation checklist

```
[x] Tiled `collisions` + `spawnpoints` layers (lowercase)
[x] `CollisionBlock` + hitbox
[x] `Level` loads collisions; `HasCollisionDetection`
[x] `Player` CollisionCallbacks + allowedDirections clamp
[x] `PlayerConfig` hitbox size/position, scale, move speeds wired in Player
[x] `CollisionHelper` + `CoordinatesHelper` + `MoveableDirection`
[x] Design spec `docs/collision-design-spec.md`
[ ] Verify: `flutter analyze` / `flutter test` when changing code
```
