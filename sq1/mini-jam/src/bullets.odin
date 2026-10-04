package arena

// Moving bullets (the player's and the shooters') and removing the ones that
// leave the arena.

import rl "vendor:raylib"

update_bullets :: proc(g: ^Game, dt: f32) {
	move_bullets_and_remove_outside(&g.bullets, g.arena, dt)
	move_bullets_and_remove_outside(&g.enemy_bullets, g.arena, dt)
}

// Moves every bullet in the list and deletes the ones outside the walls.
// We loop backwards because unordered_remove moves the last element into the
// removed slot; going backwards means we never skip that moved element.
move_bullets_and_remove_outside :: proc(bullets: ^[dynamic]Bullet, walls: rl.Rectangle, dt: f32) {
	for i := len(bullets) - 1; i >= 0; i -= 1 {
		b := &bullets[i] // `&` takes a pointer so we change the bullet in the array, not a copy
		b.pos += b.vel * dt
		if !rl.CheckCollisionPointRec(b.pos, walls) {
			unordered_remove(bullets, i)
		}
	}
}
