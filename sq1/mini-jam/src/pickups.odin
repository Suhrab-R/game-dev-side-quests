package arena

// Health pickups (rooms 4 and 5): appear on a timer at random spots, heal 1 HP.

import "core:math/rand"
import rl "vendor:raylib"

// Drops a new pickup every PICKUP_SPAWN_INTERVAL seconds, unless the floor
// already has PICKUP_MAX_ON_FLOOR of them waiting.
update_pickup_spawning :: proc(g: ^Game, dt: f32) {
	if !current_room(g).health_pickups || g.room_cleared do return

	g.pickup_timer -= dt
	if g.pickup_timer <= 0 {
		g.pickup_timer = PICKUP_SPAWN_INTERVAL
		if len(g.pickups) < PICKUP_MAX_ON_FLOOR {
			append(&g.pickups, Pickup{pos = random_point_inside(g.arena, PICKUP_RADIUS * 3)})
		}
	}
}

// Keeps pickups inside the walls (they can close in), and heals the player when
// they touch one. At full HP the pickup stays on the floor for later.
update_pickups :: proc(g: ^Game) {
	for i := len(g.pickups) - 1; i >= 0; i -= 1 {
		p := &g.pickups[i]
		p.pos = clamp_circle_to_rect(p.pos, PICKUP_RADIUS, g.arena)

		touching := rl.CheckCollisionCircles(p.pos, PICKUP_RADIUS, g.player.pos, PLAYER_RADIUS)
		if touching && g.player.hp < PLAYER_MAX_HP {
			g.player.hp = min(PLAYER_MAX_HP, g.player.hp + PICKUP_HEAL)
			unordered_remove(&g.pickups, i)
		}
	}
}

// A random point at least `margin` pixels away from every wall.
random_point_inside :: proc(r: rl.Rectangle, margin: f32) -> rl.Vector2 {
	return {
		rand.float32_range(r.x + margin, r.x + r.width - margin),
		rand.float32_range(r.y + margin, r.y + r.height - margin),
	}
}
