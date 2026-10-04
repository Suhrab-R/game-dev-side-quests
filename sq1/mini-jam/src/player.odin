package arena

// Player movement and shooting.

import "core:math/linalg"
import rl "vendor:raylib"

// Moves the player with WASD / arrow keys and keeps them inside the room.
// `g: ^Game` is a pointer to the game, so changes here change the real game state.
update_player_movement :: proc(g: ^Game, dt: f32) {
	move: rl.Vector2
	// `do` puts a one-line body on the same line as the `if`.
	if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)    do move.y -= 1
	if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)  do move.y += 1
	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)  do move.x -= 1
	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do move.x += 1
	// normalize0 keeps diagonal movement the same speed and returns 0 for no input.
	g.player.pos += linalg.normalize0(move) * PLAYER_SPEED * dt
	keep_player_in_room(g)
}

// Keeps the player circle inside the walls. Once the door is fully open and the
// player is lined up with it, the wall on that side lets them through, so they
// can walk out (check_door_exit then moves them to the next room).
keep_player_in_room :: proc(g: ^Game) {
	a := g.arena
	r: f32 = PLAYER_RADIUS // `name: type = value`; without `f32` a float constant would become a 64-bit f64
	min_x, max_x := a.x + r, a.x + a.width - r // Odin can declare two variables at once
	min_y, max_y := a.y + r, a.y + a.height - r

	if door_is_fully_open(g) && player_lined_up_with_door(g) {
		switch g.door_side {
		case .Top:    min_y = a.y - r
		case .Bottom: max_y = a.y + a.height + r
		case .Left:   min_x = a.x - r
		case .Right:  max_x = a.x + a.width + r
		}
	}

	g.player.pos.x = clamp(g.player.pos.x, min_x, max_x)
	g.player.pos.y = clamp(g.player.pos.y, min_y, max_y)
}

// Fires a bullet toward the mouse while the left button is held, limited by a cooldown.
update_player_shooting :: proc(g: ^Game, dt: f32) {
	g.player.fire_cooldown -= dt
	if rl.IsMouseButtonDown(.LEFT) && g.player.fire_cooldown <= 0 {
		dir := linalg.normalize0(rl.GetMousePosition() - g.player.pos)
		if dir != {0, 0} {
			append(&g.bullets, Bullet{pos = g.player.pos, vel = dir * BULLET_SPEED})
			g.player.fire_cooldown = FIRE_COOLDOWN
		}
	}
}

// Costs 1 HP unless the player is still invulnerable from a recent hit.
damage_player :: proc(g: ^Game) {
	if g.player.invuln_timer <= 0 {
		g.player.hp -= 1
		g.player.invuln_timer = PLAYER_INVULN
	}
}
