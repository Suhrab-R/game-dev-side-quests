package arena

// Drawing the game world and choosing what to draw for each screen.

import "core:math"
import rl "vendor:raylib"

// Draws text horizontally centred on the screen at height y.
draw_centered_text :: proc(text: cstring, y: i32, size: i32, color: rl.Color) {
	w := rl.MeasureText(text, size)
	rl.DrawText(text, SCREEN_W / 2 - w / 2, y, size, color)
}

// Draws one full frame. `defer` runs EndDrawing when this proc returns.
draw :: proc(g: ^Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()
	rl.ClearBackground(BACKGROUND_COLOR)

	switch g.state {
	case .Title:
		draw_title_screen()
	case .Playing:
		draw_world(g)
		draw_hud(g)
	case .Won, .Lost:
		draw_world(g)
		draw_hud(g)
		draw_end_screen(g)
	}
}

// Draws the room. The order matters in dark rooms: everything drawn before
// draw_darkness can be hidden by it; everything after it "glows" and is always
// visible (walls, the door, enemy bullets, health packs, a charger's warning flash).
draw_world :: proc(g: ^Game) {
	draw_enemies(g)
	for b in g.bullets {
		rl.DrawCircleV(b.pos, BULLET_RADIUS, rl.YELLOW)
	}
	draw_player(g)

	if room_is_dark(g) {
		draw_darkness(g)
		draw_charger_warnings(g) // the warning is always visible, so the dash is always fair
	}

	draw_pickups(g)
	for b in g.enemy_bullets {
		rl.DrawCircleV(b.pos, ENEMY_BULLET_RADIUS, rl.MAGENTA)
	}
	rl.DrawRectangleLinesEx(g.arena, 2, rl.GRAY)
	draw_door(g)
}

draw_player :: proc(g: ^Game) {
	// Blink the player while invulnerable (visible for half of every 0.2 s).
	blinking := g.player.invuln_timer > 0 && math.mod(g.player.invuln_timer, 0.2) < 0.1
	if !blinking {
		rl.DrawCircleV(g.player.pos, PLAYER_RADIUS, rl.SKYBLUE)
	}
}

draw_enemies :: proc(g: ^Game) {
	for e in g.enemies {
		rl.DrawCircleV(e.pos, enemy_radius(e.kind), enemy_color(e))
		// Enemies that take more than one hit get a white ring while they still have extra HP.
		if e.hp > 1 {
			rl.DrawCircleLinesV(e.pos, enemy_radius(e.kind) + 3, rl.RAYWHITE)
		}
	}
}

enemy_color :: proc(e: Enemy) -> rl.Color {
	switch e.kind {
	case .Regular:                  return rl.RED
	case .Expander:                 return rl.LIME
	case .Charger:                  return charger_is_flashing(e) ? rl.WHITE : rl.ORANGE
	case .Shooter:                  return rl.VIOLET
	case .Splitter, .Splitter_Child: return rl.PINK
	}
	return rl.RED
}

// During its warning a charger flickers between white and orange (4 swaps a second).
charger_is_flashing :: proc(e: Enemy) -> bool {
	return e.kind == .Charger && e.phase == .Telegraph && math.mod(e.timer, 0.25) < 0.125
}

// In the dark, chargers that are mid-warning are drawn again on top of the
// darkness so their flash can always be seen.
draw_charger_warnings :: proc(g: ^Game) {
	for e in g.enemies {
		if e.kind == .Charger && e.phase == .Telegraph {
			rl.DrawCircleV(e.pos, CHARGER_RADIUS, enemy_color(e))
		}
	}
}

draw_pickups :: proc(g: ^Game) {
	for p in g.pickups {
		// A white circle with a red plus sign.
		rl.DrawCircleV(p.pos, PICKUP_RADIUS, rl.RAYWHITE)
		bar_long: f32 = PICKUP_RADIUS * 1.2 // explicit f32: Raylib uses 32-bit floats
		bar_thin: f32 = PICKUP_RADIUS * 0.4
		rl.DrawRectangleV({p.pos.x - bar_long / 2, p.pos.y - bar_thin / 2}, {bar_long, bar_thin}, rl.RED)
		rl.DrawRectangleV({p.pos.x - bar_thin / 2, p.pos.y - bar_long / 2}, {bar_thin, bar_long}, rl.RED)
	}
}

// The door is a red panel in the wall. As it opens it slides sideways into the
// wall (the panel gets shorter from one end), revealing a lit gap behind it.
draw_door :: proc(g: ^Game) {
	if g.room_index == ROOM_COUNT - 1 do return // the last room has no exit

	gap := door_rect(g)
	if g.door_open > 0 {
		rl.DrawRectangleRec(gap, rl.LIGHTGRAY) // the opening, erasing the wall line behind the door
	}

	panel := gap
	remaining := 1 - g.door_open // fraction of the door still closed
	switch g.door_side {
	case .Top, .Bottom: panel.width *= remaining  // slides to the left
	case .Left, .Right: panel.height *= remaining // slides upward
	}
	rl.DrawRectangleRec(panel, rl.RED)
}
