package arena

// The shrinking arena (rooms 2 and 5): the walls close in at a constant rate,
// non-green kills shrink it further, green (expander) kills push it back out.
// The size is stored as a scale: 1.0 = full ARENA. If it reaches
// ARENA_CRUSH_SCALE the player is crushed and loses the run.

import rl "vendor:raylib"

// Squeezes the walls a little every frame while the room is still being played.
update_arena_shrink :: proc(g: ^Game, dt: f32) {
	if !current_room(g).shrinking || g.room_cleared do return
	change_arena_scale(g, -current_room(g).shrink_rate * dt)
}

// Called for every kill. In a shrinking room the kind of enemy decides whether
// the walls move in or out; that's the room's core decision: which enemies to shoot.
apply_kill_to_arena :: proc(g: ^Game, kind: Enemy_Kind) {
	if !current_room(g).shrinking do return
	if kind == .Expander {
		change_arena_scale(g, EXPANDER_GROW_AMOUNT)
	} else {
		change_arena_scale(g, -current_room(g).kill_shrink_amount)
	}
}

// Changes the scale (kept between ARENA_CRUSH_SCALE and 1) and rebuilds the walls.
change_arena_scale :: proc(g: ^Game, amount: f32) {
	g.arena_scale = clamp(g.arena_scale + amount, ARENA_CRUSH_SCALE, 1)
	g.arena = scaled_arena(g.arena_scale)
}

// True once the walls have closed all the way in. The clamp above stops the
// scale at exactly ARENA_CRUSH_SCALE, so `<=` reliably catches it.
arena_is_crushed :: proc(g: ^Game) -> bool {
	return current_room(g).shrinking && g.arena_scale <= ARENA_CRUSH_SCALE
}

// The full arena scaled down around its centre.
scaled_arena :: proc(scale: f32) -> rl.Rectangle {
	c := rect_center(ARENA)
	w := ARENA.width * scale
	h := ARENA.height * scale
	return {c.x - w / 2, c.y - h / 2, w, h}
}

// Pushes a circle back inside a rectangle. Used for anything the walls close in on.
clamp_circle_to_rect :: proc(pos: rl.Vector2, radius: f32, r: rl.Rectangle) -> rl.Vector2 {
	return {
		clamp(pos.x, r.x + radius, r.x + r.width - radius),
		clamp(pos.y, r.y + radius, r.y + r.height - radius),
	}
}
