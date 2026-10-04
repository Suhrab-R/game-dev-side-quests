package arena

// Darkness (rooms 3 and 5): the arena is covered in black except for a circle of
// light around the player and a smaller one around each of the player's bullets.
//
// How it's drawn: the arena is split into a grid of small squares. For each
// square we work out how lit it is (0 = dark, 1 = fully lit) from the nearest
// light, and draw a black square over it that is more see-through the brighter
// it is. Simple, and it supports any number of lights.

import "core:math/linalg"
import rl "vendor:raylib"

// The lights go back on once the room is cleared, so the player can find the door.
room_is_dark :: proc(g: ^Game) -> bool {
	return current_room(g).dark && !g.room_cleared
}

draw_darkness :: proc(g: ^Game) {
	cols := int(ARENA.width) / DARK_CELL_SIZE
	rows := int(ARENA.height) / DARK_CELL_SIZE
	for row in 0 ..< rows { // `0 ..< rows` counts 0, 1, ..., rows - 1
		for col in 0 ..< cols {
			cell := rl.Rectangle {
				ARENA.x + f32(col * DARK_CELL_SIZE),
				ARENA.y + f32(row * DARK_CELL_SIZE),
				DARK_CELL_SIZE,
				DARK_CELL_SIZE,
			}
			light := light_at(g, rect_center(cell))
			if light < 1 {
				rl.DrawRectangleRec(cell, rl.Fade(rl.BLACK, 1 - light))
			}
		}
	}
}

// How lit a point is: the brightest of all the lights that reach it.
light_at :: proc(g: ^Game, point: rl.Vector2) -> f32 {
	light := light_from(g.player.pos, current_room(g).player_light_radius, point)
	for b in g.bullets {
		light = max(light, light_from(b.pos, BULLET_LIGHT_RADIUS, point))
	}
	return light
}

// One light's brightness at a point: 1 near the centre, fading to 0 over the
// last LIGHT_FALLOFF pixels before `radius`.
light_from :: proc(source: rl.Vector2, radius: f32, point: rl.Vector2) -> f32 {
	dist := linalg.distance(source, point)
	return clamp((radius - dist) / LIGHT_FALLOFF, 0, 1)
}
