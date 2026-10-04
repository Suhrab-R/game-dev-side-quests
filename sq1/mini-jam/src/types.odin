package arena

// All the data types the game uses. Every piece of game state lives in `Game`.

import rl "vendor:raylib"

// Which screen the game is on. Odin enum values are written `.Title`, `.Playing`
// etc.; the enum type is inferred from where they are used.
State :: enum {
	Title,
	Playing,
	Won,
	Lost,
}

// Which mechanics a room turns on. Fields left out of a struct literal are zero
// (false / 0), so in config.odin each room only lists what it changes.
Room_Config :: struct {
	name:                 cstring,
	hint:                 cstring, // one-line explanation shown when the room starts
	shrinking:            bool,    // walls close in; kills change the size
	expander_chance:      f32,     // chance (0-1) that a spawn is a green expander
	kill_shrink_amount:   f32,     // scale the walls lose per non-green kill (shrinking rooms only)
	shrink_rate:          f32,     // scale the walls lose per second (shrinking rooms only)
	dark:                 bool,    // only lights around the player and bullets are visible
	player_light_radius:  f32,     // pixels of light around the player (dark rooms only)
	special_enemies:      bool,    // chargers, shooters and splitters can spawn
	health_pickups:       bool,    // health packs appear on the floor
	spawn_interval_start: f32,     // seconds between spawns when the room starts
	spawn_interval_end:   f32,     // seconds between spawns once the ramp is finished
	spawn_ramp_time:      f32,     // seconds it takes to go from the start interval to the end interval
	enemy_speed_bonus:    f32,     // extra pixels/sec added to every enemy in this room
	enemy_speed_growth:   f32,     // extra pixels/sec enemies gain per second spent in this room
}

// A wall of the arena (used for where the door is).
Side :: enum {
	Top,
	Bottom,
	Left,
	Right,
}

Player :: struct {
	pos:           rl.Vector2,
	hp:            int,
	invuln_timer:  f32, // seconds left of invulnerability after a hit
	fire_cooldown: f32, // seconds until the next shot is allowed
}

Bullet :: struct {
	pos: rl.Vector2,
	vel: rl.Vector2, // pixels/sec
}

Enemy_Kind :: enum {
	Regular,        // red: chases you
	Expander,       // green: chases you; killing it pushes the walls back out
	Charger,        // orange: flashes, then dashes
	Shooter,        // violet: keeps its distance and shoots
	Splitter,       // pink, big: splits into two children when killed
	Splitter_Child, // pink, small and fast
}

// What a charger is currently doing.
Charger_Phase :: enum {
	Chasing,
	Telegraph,  // standing still and flashing: the warning before a dash
	Dashing,
	Recovering, // standing still after a dash (the moment to shoot it)
}

Enemy :: struct {
	kind:     Enemy_Kind,
	pos:      rl.Vector2,
	hp:       int,
	timer:    f32,           // charger: seconds left in its phase; shooter: seconds until next shot
	phase:    Charger_Phase, // only used by chargers
	dash_dir: rl.Vector2,    // only used by chargers: direction locked in when the warning starts
}

Pickup :: struct {
	pos: rl.Vector2,
}

// `[dynamic]T` is a growable array (like std::vector / ArrayList).
Game :: struct {
	state:         State,
	player:        Player,
	bullets:       [dynamic]Bullet, // the player's bullets
	enemy_bullets: [dynamic]Bullet, // shooters' bullets
	enemies:       [dynamic]Enemy,
	pickups:       [dynamic]Pickup,
	score:         int,

	// The current room
	room_index:    int,          // 0 to ROOM_COUNT - 1
	room_time:     f32,          // seconds survived in this room
	room_cleared:  bool,         // timer ran out: enemies gone, door opening
	arena:         rl.Rectangle, // current walls (smaller than ARENA in shrinking rooms)
	arena_scale:   f32,          // 1.0 = full size, down to ARENA_CRUSH_SCALE (= lost)
	door_side:     Side,         // which wall this room's exit door is on
	door_open:     f32,          // 0 = closed, 1 = fully open
	spawn_timer:   f32,          // seconds until the next enemy spawns
	pickup_timer:  f32,          // seconds until the next health pickup appears
	banner_timer:  f32,          // seconds left to show the room name
}
