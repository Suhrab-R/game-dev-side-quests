package arena

// Window, game loop, and the state machine (title -> playing -> won/lost).
// Every .odin file in src/ is part of this one package, so they all share
// their procs and types without imports.

import rl "vendor:raylib"

// One frame of gameplay, as a list of steps.
update_playing :: proc(g: ^Game, dt: f32) {
	update_room_timer(g, dt)
	if g.state != .Playing do return // the last room's timer just ran out: we won

	update_player_movement(g, dt)
	update_player_shooting(g, dt)
	update_bullets(g, dt)
	update_arena_shrink(g, dt)
	update_enemy_spawning(g, dt)
	update_pickup_spawning(g, dt)
	update_enemies(g, dt)

	handle_bullet_enemy_collisions(g)
	handle_enemy_player_collisions(g, dt)
	handle_enemy_bullet_player_collisions(g)
	update_pickups(g)

	// Two ways to lose: out of HP, or the shrinking walls closed all the way in.
	if g.player.hp <= 0 || arena_is_crushed(g) {
		g.state = .Lost
		return
	}

	update_door(g, dt)
	check_door_exit(g)
}

// Decides what happens this frame based on which screen we're on.
update :: proc(g: ^Game, dt: f32) {
	switch g.state {
	case .Title:
		if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
			start_run(g)
			g.state = .Playing
		}
	case .Playing:
		update_playing(g, dt)
	case .Won, .Lost:
		if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.R) {
			start_run(g) // always back to room 1
			g.state = .Playing
		}
	}
}

main :: proc() {
	rl.InitWindow(SCREEN_W, SCREEN_H, "ARENA")
	defer rl.CloseWindow() // `defer` runs this line when main exits
	rl.SetTargetFPS(60)

	g: Game
	defer delete(g.bullets)
	defer delete(g.enemy_bullets)
	defer delete(g.enemies)
	defer delete(g.pickups)

	for !rl.WindowShouldClose() {
		// Cap dt so a stalled frame (e.g. dragging the window) doesn't teleport everything.
		dt := min(rl.GetFrameTime(), 1.0 / 30.0)
		update(&g, dt)
		draw(&g)
		free_all(context.temp_allocator) // ctprintf allocates HUD strings here each frame
	}
}
