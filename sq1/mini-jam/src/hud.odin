package arena

// Text on screen: the in-game HUD, room banners, the title screen and the win/lose screen.

import "core:fmt"
import rl "vendor:raylib"

// HP on the left, room + time left in the middle, score on the right.
// fmt.ctprintf builds a temporary C string; it is freed once per frame in main.
draw_hud :: proc(g: ^Game) {
	rl.DrawText(fmt.ctprintf("HP: %d / %d", g.player.hp, PLAYER_MAX_HP), 40, 25, 30, rl.RAYWHITE)

	draw_centered_text(fmt.ctprintf("ROOM %d / %d", g.room_index + 1, ROOM_COUNT), 8, 20, rl.LIGHTGRAY)
	draw_centered_text(fmt.ctprintf("%.0f", max(0, ROOM_LENGTH - g.room_time)), 34, 34, rl.RAYWHITE)

	score_text := fmt.ctprintf("Score: %d", g.score)
	rl.DrawText(score_text, SCREEN_W - 40 - rl.MeasureText(score_text, 30), 25, 30, rl.RAYWHITE)

	draw_room_messages(g)
}

// The room's name and hint fade out over the first seconds of a room, and once
// the room is cleared a message points the player at the door.
draw_room_messages :: proc(g: ^Game) {
	if g.state != .Playing do return
	room := current_room(g)

	if g.banner_timer > 0 {
		fade := g.banner_timer / ROOM_BANNER_TIME // 1 when the room starts, 0 when the banner is gone
		draw_centered_text(room.name, 150, 44, rl.Fade(rl.RAYWHITE, fade))
		draw_centered_text(room.hint, 205, 24, rl.Fade(rl.LIGHTGRAY, fade))
	}

	if g.room_cleared {
		draw_centered_text("ROOM CLEARED! Go through the red door", 150, 32, rl.GREEN)
	}
}

draw_title_screen :: proc() {
	draw_centered_text("ARENA", 200, 80, rl.RAYWHITE)
	draw_centered_text(fmt.ctprintf("Survive %d rooms, %.0f seconds each", ROOM_COUNT, ROOM_LENGTH), 310, 30, rl.LIGHTGRAY)
	draw_centered_text("When a room's timer runs out, its red door opens. Walk through it.", 355, 22, rl.LIGHTGRAY)
	draw_centered_text("WASD to move  -  Mouse to aim  -  Hold left click to shoot", 400, 24, rl.LIGHTGRAY)
	draw_centered_text("Press ENTER to start", 480, 30, rl.YELLOW)
}

// Darkens the frozen game and shows whether the player escaped or died.
draw_end_screen :: proc(g: ^Game) {
	rl.DrawRectangle(0, 0, SCREEN_W, SCREEN_H, rl.Fade(rl.BLACK, 0.6))
	if g.state == .Won {
		draw_centered_text(fmt.ctprintf("YOU ESCAPED ALL %d ROOMS", ROOM_COUNT), 250, 60, rl.GREEN)
	} else {
		draw_centered_text(fmt.ctprintf("YOU DIED IN ROOM %d", g.room_index + 1), 250, 60, rl.RED)
		if arena_is_crushed(g) {
			draw_centered_text("The walls crushed you. Shoot the green enemies to push them back!", 315, 24, rl.LIGHTGRAY)
		}
	}
	draw_centered_text(fmt.ctprintf("Score: %d", g.score), 350, 36, rl.RAYWHITE)
	draw_centered_text("Press ENTER or R to play again from room 1", 420, 28, rl.YELLOW)
}
