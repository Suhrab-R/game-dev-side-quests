package arena

// Collisions between bullets, enemies and the player.
// All loops go backwards so unordered_remove doesn't skip elements.

import rl "vendor:raylib"

// A bullet touching an enemy is used up and does 1 damage; at 0 HP the enemy dies.
handle_bullet_enemy_collisions :: proc(g: ^Game) {
	for ei := len(g.enemies) - 1; ei >= 0; ei -= 1 {
		for bi := len(g.bullets) - 1; bi >= 0; bi -= 1 {
			e := &g.enemies[ei]
			if rl.CheckCollisionCircles(e.pos, enemy_radius(e.kind), g.bullets[bi].pos, BULLET_RADIUS) {
				unordered_remove(&g.bullets, bi)
				e.hp -= 1
				if e.hp <= 0 {
					// kill_enemy may add splitter children to the END of the list;
					// we've already passed those indices, so they aren't hit this frame.
					kill_enemy(g, ei)
				}
				break // one bullet per enemy per frame; move on to the next enemy
			}
		}
	}
}

// An enemy touching the player is consumed and costs 1 HP (unless invulnerable).
handle_enemy_player_collisions :: proc(g: ^Game, dt: f32) {
	g.player.invuln_timer -= dt
	for ei := len(g.enemies) - 1; ei >= 0; ei -= 1 {
		e := g.enemies[ei]
		if rl.CheckCollisionCircles(e.pos, enemy_radius(e.kind), g.player.pos, PLAYER_RADIUS) {
			unordered_remove(&g.enemies, ei) // the enemy that hit you is consumed
			damage_player(g)
		}
	}
}

// A shooter's bullet touching the player is used up and costs 1 HP (unless invulnerable).
handle_enemy_bullet_player_collisions :: proc(g: ^Game) {
	for i := len(g.enemy_bullets) - 1; i >= 0; i -= 1 {
		if rl.CheckCollisionCircles(g.enemy_bullets[i].pos, ENEMY_BULLET_RADIUS, g.player.pos, PLAYER_RADIUS) {
			unordered_remove(&g.enemy_bullets, i)
			damage_player(g)
		}
	}
}
