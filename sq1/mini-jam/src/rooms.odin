package arena

// The run through ROOM_COUNT rooms: starting a room, its 30 s timer, the exit
// door that slides open when the timer runs out, and walking through it.

import "core:math/rand"
import rl "vendor:raylib"

// The settings of the room the player is in now.
current_room :: proc(g: ^Game) -> Room_Config {
	rooms := ROOMS // copy the constant table into a local so it can be indexed at run time
	return rooms[g.room_index]
}

// Starts a whole new run from room 1 with full health and zero score.
start_run :: proc(g: ^Game) {
	g.player.hp = PLAYER_MAX_HP
	g.score = 0
	g.room_index = 0
	g.door_side = Side(rand.int_max(4)) // room 1's door can be on any wall
	start_room(g)
}

// Sets up the current room: empty, full size, player in the middle.
// HP and score are NOT reset here, so they carry over between rooms.
start_room :: proc(g: ^Game) {
	clear(&g.bullets)
	clear(&g.enemy_bullets)
	clear(&g.enemies)
	clear(&g.pickups)

	g.arena = ARENA
	g.arena_scale = 1
	g.room_time = 0
	g.room_cleared = false
	g.door_open = 0
	g.spawn_timer = current_room(g).spawn_interval_start
	g.pickup_timer = PICKUP_SPAWN_INTERVAL
	g.banner_timer = ROOM_BANNER_TIME

	g.player.pos = rect_center(ARENA)
	g.player.invuln_timer = 0
	g.player.fire_cooldown = 0
}

// Counts down the room's 30 seconds. When it runs out, the last room wins the
// game and every other room is cleared so its door can open.
update_room_timer :: proc(g: ^Game, dt: f32) {
	g.banner_timer -= dt
	if g.room_cleared do return

	g.room_time += dt
	if g.room_time >= ROOM_LENGTH {
		if g.room_index == ROOM_COUNT - 1 {
			g.state = .Won
		} else {
			clear_room(g)
		}
	}
}

// The room is beaten: remove every enemy and enemy bullet so the player can
// walk to the door safely.
clear_room :: proc(g: ^Game) {
	g.room_cleared = true
	clear(&g.enemies)
	clear(&g.enemy_bullets)
}

// Slides the door open over DOOR_OPEN_TIME seconds once the room is cleared.
update_door :: proc(g: ^Game, dt: f32) {
	if g.room_cleared {
		g.door_open = min(1, g.door_open + dt / DOOR_OPEN_TIME)
	}
}

door_is_fully_open :: proc(g: ^Game) -> bool {
	return g.door_open >= 1
}

// The doorway: a DOOR_WIDTH-long strip centred on the door's wall.
door_rect :: proc(g: ^Game) -> rl.Rectangle {
	a := g.arena
	c := rect_center(a)
	switch g.door_side {
	case .Top:    return {c.x - DOOR_WIDTH / 2, a.y - DOOR_THICKNESS / 2, DOOR_WIDTH, DOOR_THICKNESS}
	case .Bottom: return {c.x - DOOR_WIDTH / 2, a.y + a.height - DOOR_THICKNESS / 2, DOOR_WIDTH, DOOR_THICKNESS}
	case .Left:   return {a.x - DOOR_THICKNESS / 2, c.y - DOOR_WIDTH / 2, DOOR_THICKNESS, DOOR_WIDTH}
	case .Right:  return {a.x + a.width - DOOR_THICKNESS / 2, c.y - DOOR_WIDTH / 2, DOOR_THICKNESS, DOOR_WIDTH}
	}
	return {}
}

// True when the whole player circle fits inside the doorway's width, i.e. they
// are lined up to walk through it.
player_lined_up_with_door :: proc(g: ^Game) -> bool {
	d := door_rect(g)
	p := g.player.pos
	switch g.door_side {
	case .Top, .Bottom: return p.x >= d.x + PLAYER_RADIUS && p.x <= d.x + d.width - PLAYER_RADIUS
	case .Left, .Right: return p.y >= d.y + PLAYER_RADIUS && p.y <= d.y + d.height - PLAYER_RADIUS
	}
	return false
}

// Once the player's centre has crossed the wall line through the open door,
// move on to the next room.
check_door_exit :: proc(g: ^Game) {
	if !door_is_fully_open(g) do return

	a := g.arena
	p := g.player.pos
	went_through := false
	switch g.door_side {
	case .Top:    went_through = p.y <= a.y
	case .Bottom: went_through = p.y >= a.y + a.height
	case .Left:   went_through = p.x <= a.x
	case .Right:  went_through = p.x >= a.x + a.width
	}
	if went_through {
		go_to_next_room(g)
	}
}

// Picks the next room's door and starts that room. The new door may not be on
// the wall opposite the last door: you enter the new room from that side, so a
// door there would lead straight back where you came from.
go_to_next_room :: proc(g: ^Game) {
	came_in_through := opposite_side(g.door_side)
	g.room_index += 1
	g.door_side = random_side_except(came_in_through)
	start_room(g)
}

opposite_side :: proc(s: Side) -> Side {
	switch s {
	case .Top:    return .Bottom
	case .Bottom: return .Top
	case .Left:   return .Right
	case .Right:  return .Left
	}
	return .Top
}

// Picks one of the four walls at random, re-rolling if it lands on `forbidden`.
random_side_except :: proc(forbidden: Side) -> Side {
	for {
		s := Side(rand.int_max(4)) // `Side(n)` converts the number 0-3 to the matching enum value
		if s != forbidden do return s
	}
}

rect_center :: proc(r: rl.Rectangle) -> rl.Vector2 {
	return {r.x + r.width / 2, r.y + r.height / 2}
}
