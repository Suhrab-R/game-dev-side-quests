package arena

// Enemy spawning, the behaviour of each enemy kind, and what happens when one dies.

import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

// Picks a random point on one of the four walls of the current arena.
random_edge_point :: proc(a: rl.Rectangle) -> rl.Vector2 {
	t := rand.float32()
	switch rand.int_max(4) {
	case 0: return {a.x + t * a.width, a.y}            // top
	case 1: return {a.x + t * a.width, a.y + a.height} // bottom
	case 2: return {a.x, a.y + t * a.height}           // left
	case:   return {a.x + a.width, a.y + t * a.height} // right (`case:` is the default)
	}
}

// Spawns enemies on a timer. The gap between spawns shrinks steadily from the
// room's start value to its end value over the room's spawn_ramp_time seconds,
// then stays at the end value for the rest of the room.
update_enemy_spawning :: proc(g: ^Game, dt: f32) {
	if g.room_cleared do return

	g.spawn_timer -= dt
	if g.spawn_timer <= 0 {
		room := current_room(g)
		kind := pick_enemy_kind(room)
		append(&g.enemies, make_enemy(kind, random_edge_point(g.arena)))

		progress := min(g.room_time / room.spawn_ramp_time, 1) // 0 at the start of the room, 1 once the ramp is done
		g.spawn_timer = room.spawn_interval_start + (room.spawn_interval_end - room.spawn_interval_start) * progress
	}
}

// Rolls one random number and walks through the chances in order:
// expander first, then (if the room has them) charger, shooter, splitter.
// Whatever is left over is a regular enemy.
pick_enemy_kind :: proc(room: Room_Config) -> Enemy_Kind {
	roll := rand.float32()

	if roll < room.expander_chance do return .Expander
	roll -= room.expander_chance

	if room.special_enemies {
		if roll < CHARGER_SPAWN_CHANCE do return .Charger
		roll -= CHARGER_SPAWN_CHANCE
		if roll < SHOOTER_SPAWN_CHANCE do return .Shooter
		roll -= SHOOTER_SPAWN_CHANCE
		if roll < SPLITTER_SPAWN_CHANCE do return .Splitter
	}
	return .Regular
}

// Builds a new enemy of the given kind with its starting HP and timers.
make_enemy :: proc(kind: Enemy_Kind, pos: rl.Vector2) -> Enemy {
	e := Enemy{kind = kind, pos = pos, hp = 1, phase = .Chasing}
	#partial switch kind { // `#partial` = we don't need a case for every enum value
	case .Charger:
		e.hp = CHARGER_HP
	case .Shooter:
		e.hp = SHOOTER_HP
		e.timer = SHOOTER_FIRE_INTERVAL
	}
	return e
}

enemy_radius :: proc(kind: Enemy_Kind) -> f32 {
	switch kind {
	case .Regular, .Expander: return ENEMY_RADIUS
	case .Charger:            return CHARGER_RADIUS
	case .Shooter:            return SHOOTER_RADIUS
	case .Splitter:           return SPLITTER_RADIUS
	case .Splitter_Child:     return SPLIT_CHILD_RADIUS
	}
	return ENEMY_RADIUS
}

// How fast regular enemies chase right now: faster in later rooms and the
// longer you stay in a room. Other kinds use a multiple of this.
chase_speed :: proc(g: ^Game) -> f32 {
	room := current_room(g)
	return ENEMY_BASE_SPEED + room.enemy_speed_bonus + g.room_time * room.enemy_speed_growth
}

// Moves every enemy according to its kind, then keeps it inside the walls
// (which matters when the walls are closing in).
update_enemies :: proc(g: ^Game, dt: f32) {
	speed := chase_speed(g)
	// `for &e in` loops by reference, so changing `e` changes the enemy in the array.
	for &e in g.enemies {
		switch e.kind {
		case .Regular:        move_toward(&e.pos, g.player.pos, speed, dt)
		case .Expander:       move_toward(&e.pos, g.player.pos, speed * EXPANDER_SPEED_MULT, dt)
		case .Splitter:       move_toward(&e.pos, g.player.pos, speed * SPLITTER_SPEED_MULT, dt)
		case .Splitter_Child: move_toward(&e.pos, g.player.pos, speed * SPLIT_CHILD_SPEED_MULT, dt)
		case .Charger:        update_charger(g, &e, speed, dt)
		case .Shooter:        update_shooter(g, &e, speed, dt)
		}
		e.pos = clamp_circle_to_rect(e.pos, enemy_radius(e.kind), g.arena)
	}
}

// Moves `pos` straight toward `target`. `pos: ^rl.Vector2` is a pointer, so
// the caller's position is changed.
move_toward :: proc(pos: ^rl.Vector2, target: rl.Vector2, speed: f32, dt: f32) {
	pos^ += linalg.normalize0(target - pos^) * speed * dt // `pos^` reads/writes the value the pointer points at
}

// Charger cycle: chase -> stop and flash (warning) -> dash -> stand still -> chase.
// The dash direction is locked when the warning starts, so a player who reads
// the flash can sidestep it.
update_charger :: proc(g: ^Game, e: ^Enemy, speed: f32, dt: f32) {
	switch e.phase {
	case .Chasing:
		move_toward(&e.pos, g.player.pos, speed * CHARGER_SPEED_MULT, dt)
		if linalg.distance(e.pos, g.player.pos) < CHARGER_TRIGGER_RANGE {
			e.phase = .Telegraph
			e.timer = CHARGER_TELEGRAPH_TIME
			e.dash_dir = linalg.normalize0(g.player.pos - e.pos)
		}
	case .Telegraph:
		e.timer -= dt
		if e.timer <= 0 {
			e.phase = .Dashing
			e.timer = CHARGER_DASH_TIME
		}
	case .Dashing:
		e.pos += e.dash_dir * CHARGER_DASH_SPEED * dt
		e.timer -= dt
		if e.timer <= 0 {
			e.phase = .Recovering
			e.timer = CHARGER_RECOVER_TIME
		}
	case .Recovering:
		e.timer -= dt
		if e.timer <= 0 {
			e.phase = .Chasing
		}
	}
}

// Shooters hover around SHOOTER_PREFERRED_DIST from the player (closing in if
// too far, backing off if too close) and fire a slow bullet at the player on a timer.
update_shooter :: proc(g: ^Game, e: ^Enemy, speed: f32, dt: f32) {
	dist := linalg.distance(e.pos, g.player.pos)
	step := speed * SHOOTER_SPEED_MULT
	if dist > SHOOTER_PREFERRED_DIST + SHOOTER_DIST_TOLERANCE {
		move_toward(&e.pos, g.player.pos, step, dt)
	} else if dist < SHOOTER_PREFERRED_DIST - SHOOTER_DIST_TOLERANCE {
		move_toward(&e.pos, g.player.pos, -step, dt) // negative speed = move away
	}

	e.timer -= dt
	if e.timer <= 0 {
		dir := linalg.normalize0(g.player.pos - e.pos)
		append(&g.enemy_bullets, Bullet{pos = e.pos, vel = dir * ENEMY_BULLET_SPEED})
		e.timer = SHOOTER_FIRE_INTERVAL
	}
}

// Removes the enemy at `index`, scores it, applies the shrinking-room effect,
// and splits splitters into two children.
kill_enemy :: proc(g: ^Game, index: int) {
	dead := g.enemies[index] // a copy, so we still have its data after removing it
	unordered_remove(&g.enemies, index)
	g.score += 1
	apply_kill_to_arena(g, dead.kind)

	if dead.kind == .Splitter {
		spawn_splitter_children(g, dead.pos)
	}
}

// Two children appear side by side, at right angles to the line between the
// splitter and the player, so they come at you from two directions.
spawn_splitter_children :: proc(g: ^Game, pos: rl.Vector2) {
	to_player := linalg.normalize0(g.player.pos - pos)
	sideways := rl.Vector2{-to_player.y, to_player.x} // to_player rotated 90 degrees
	append(&g.enemies, make_enemy(.Splitter_Child, pos + sideways * SPLIT_CHILD_OFFSET))
	append(&g.enemies, make_enemy(.Splitter_Child, pos - sideways * SPLIT_CHILD_OFFSET))
}
