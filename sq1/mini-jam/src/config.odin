package arena

// Every tuning value in the game lives here.
// Odin syntax: `NAME :: value` declares a compile-time constant (it can never change).

import rl "vendor:raylib"

SCREEN_W :: 1280
SCREEN_H :: 720

// A cool slate grey (red, green, blue, alpha). Lighter than black so the lit
// circles in dark rooms stand out clearly against the black darkness.
BACKGROUND_COLOR :: rl.Color{70, 77, 92, 255}

// The full-size playable area of every room, inset from the window so the HUD
// has room at the top. Shrinking rooms scale this down around its centre.
ARENA :: rl.Rectangle{40, 80, SCREEN_W - 80, SCREEN_H - 120}

// ---------------------------------------------------------------------------
// Rooms
// ---------------------------------------------------------------------------

ROOM_COUNT       :: 5
ROOM_LENGTH      :: 30.0 // seconds to survive in each room
ROOM_BANNER_TIME :: 2.5  // seconds the room name stays on screen when a room starts

// Each room turns on a different set of mechanics. Room 5 turns on everything.
// Spawn gaps shrink from spawn_interval_start to spawn_interval_end over
// spawn_ramp_time seconds: rooms 1-3 ramp up fast so they don't start slow
// (room 1 fastest of all, 6 s). Enemies also get faster by enemy_speed_growth
// every second; room 1 ramps its speed up faster than the others too.
// (Room_Config is defined in types.odin.)
ROOMS :: [ROOM_COUNT]Room_Config {
	{
		name                 = "Room 1: The Arena",
		hint                 = "Survive 30 seconds",
		spawn_interval_start = 1.1,
		spawn_interval_end   = 0.6,
		spawn_ramp_time      = 6.0,
		enemy_speed_growth   = 2.0,
	},
	{
		name                 = "Room 2: Closing In",
		hint                 = "The walls will crush you! Green kills push them back, red kills pull them in",
		shrinking            = true,
		expander_chance      = 0.25, // greens are rare, so each one matters
		shrink_rate          = ARENA_SHRINK_RATE,
		kill_shrink_amount   = 0.05, // a red kill costs 5% of the room (~1.4 s of squeeze): shoot the wrong one and you pay for it
		spawn_interval_start = 1.0,
		spawn_interval_end   = 0.5,
		spawn_ramp_time      = 12.0,
		enemy_speed_bonus    = 5,
		enemy_speed_growth   = ENEMY_SPEED_GROWTH,
	},
	{
		name                 = "Room 3: Lights Out",
		hint                 = "It's dark. Your shots light the way",
		dark                 = true,
		player_light_radius  = PLAYER_LIGHT_RADIUS,
		spawn_interval_start = 1.0,
		spawn_interval_end   = 0.55,
		spawn_ramp_time      = 12.0,
		enemy_speed_bonus    = 5,
		enemy_speed_growth   = ENEMY_SPEED_GROWTH,
	},
	{
		name                 = "Room 4: New Blood",
		hint                 = "Chargers, shooters and splitters. Grab the health packs",
		special_enemies      = true,
		health_pickups       = true,
		spawn_interval_start = 0.95,
		spawn_interval_end   = 0.5,
		spawn_ramp_time      = ROOM_LENGTH,
		enemy_speed_bonus    = 10,
		enemy_speed_growth   = ENEMY_SPEED_GROWTH,
	},
	{
		name                 = "Room 5: Everything",
		hint                 = "All of it at once. Survive",
		shrinking            = true,
		expander_chance      = 0.15, // greens are scarce here too
		kill_shrink_amount   = KILL_SHRINK_AMOUNT,
		shrink_rate          = 0.031, // a bit slower than room 2 (room 5 is hectic enough): crushes at ~29 s with no green kills
		dark                 = true,
		player_light_radius  = 200.0, // bigger than room 3: you also have to see which colour you're shooting
		special_enemies      = true,
		health_pickups       = true,
		spawn_interval_start = 0.9,
		spawn_interval_end   = 0.45,
		spawn_ramp_time      = ROOM_LENGTH,
		enemy_speed_bonus    = 15,
		enemy_speed_growth   = ENEMY_SPEED_GROWTH,
	},
}

// The red door that opens when a room is cleared.
DOOR_WIDTH     :: 110.0 // pixels along the wall
DOOR_THICKNESS :: 12.0  // pixels
DOOR_OPEN_TIME :: 1.0   // seconds for the door to slide fully open

// ---------------------------------------------------------------------------
// Player
// ---------------------------------------------------------------------------

PLAYER_RADIUS :: 14.0  // pixels
PLAYER_SPEED  :: 260.0 // pixels/sec
PLAYER_MAX_HP :: 5     // HP (carries over between rooms)
PLAYER_INVULN :: 1.0   // seconds of invulnerability after a hit
FIRE_COOLDOWN :: 0.15  // seconds between shots

BULLET_RADIUS :: 4.0   // pixels
BULLET_SPEED  :: 700.0 // pixels/sec

// ---------------------------------------------------------------------------
// Enemies
// ---------------------------------------------------------------------------

// Regular chasers. Speed = base + the room's bonus + the room's growth * seconds spent in the room.
ENEMY_RADIUS       :: 12.0 // pixels
ENEMY_BASE_SPEED   :: 90.0 // pixels/sec
ENEMY_SPEED_GROWTH :: 1.2  // extra pixels/sec per second spent in the room (rooms 2-5; room 1 sets its own)

// Expanders (green): shooting one pushes the walls back out in shrinking rooms.
EXPANDER_SPEED_MULT :: 0.85 // fraction of the regular chase speed

// Charger: walks slowly, stops and flashes (the warning), then dashes in a straight line.
CHARGER_RADIUS         :: 14.0  // pixels
CHARGER_HP             :: 2     // hits to kill
CHARGER_SPEED_MULT     :: 0.7   // fraction of the regular chase speed while walking
CHARGER_TRIGGER_RANGE  :: 280.0 // pixels; it starts its warning when this close to the player
CHARGER_TELEGRAPH_TIME :: 0.6   // seconds of flashing before the dash
CHARGER_DASH_SPEED     :: 560.0 // pixels/sec
CHARGER_DASH_TIME      :: 0.45  // seconds the dash lasts
CHARGER_RECOVER_TIME   :: 0.8   // seconds it stands still after a dash

// Shooter: keeps its distance and fires slow bullets.
SHOOTER_RADIUS         :: 13.0  // pixels
SHOOTER_HP             :: 2     // hits to kill
SHOOTER_SPEED_MULT     :: 0.8   // fraction of the regular chase speed
SHOOTER_PREFERRED_DIST :: 300.0 // pixels it tries to stay away from the player
SHOOTER_DIST_TOLERANCE :: 40.0  // pixels of slack before it moves closer/further
SHOOTER_FIRE_INTERVAL  :: 1.8   // seconds between shots
ENEMY_BULLET_RADIUS    :: 6.0   // pixels
ENEMY_BULLET_SPEED     :: 260.0 // pixels/sec

// Splitter: big and slow; when killed it splits into two small, fast enemies.
SPLITTER_RADIUS        :: 18.0 // pixels
SPLITTER_SPEED_MULT    :: 0.75 // fraction of the regular chase speed
SPLIT_CHILD_RADIUS     :: 8.0  // pixels
SPLIT_CHILD_SPEED_MULT :: 1.5  // fraction of the regular chase speed
SPLIT_CHILD_OFFSET     :: 16.0 // pixels each child appears to the side of the dead splitter

// In rooms with special enemies, the chance that any one spawn is each special kind.
// Whatever is left over spawns a regular enemy.
CHARGER_SPAWN_CHANCE  :: 0.12
SHOOTER_SPAWN_CHANCE  :: 0.10
SPLITTER_SPAWN_CHANCE :: 0.12

// ---------------------------------------------------------------------------
// Shrinking arena (rooms 2 and 5). Scale 1.0 = full size.
// ---------------------------------------------------------------------------

// If the walls reach ARENA_CRUSH_SCALE the player is crushed and loses.
// With no green kills at all, the constant squeeze alone gets there in
// (1 - 0.1) / 0.035 = about 26 seconds in room 2 (room 5 squeezes a bit slower),
// before the 30 s timer runs out, so the player has to shoot green enemies to survive.
ARENA_CRUSH_SCALE    :: 0.1   // scale at which the walls crush the player (10% of full size)
ARENA_SHRINK_RATE    :: 0.035 // scale lost per second (constant squeeze) in room 2 (room 5 sets its own)
KILL_SHRINK_AMOUNT   :: 0.015 // scale lost per non-green kill in room 5 (room 2 sets its own, harsher value)
EXPANDER_GROW_AMOUNT :: 0.06  // scale gained per green (expander) kill (about 1.7 s of squeeze undone)

// ---------------------------------------------------------------------------
// Darkness (rooms 3 and 5)
// ---------------------------------------------------------------------------

DARK_CELL_SIZE      :: 15    // pixels; the darkness is drawn as a grid of squares this size (divides the arena evenly)
PLAYER_LIGHT_RADIUS :: 140.0 // pixels the player can see around themselves in room 3 (room 5 sets its own)
BULLET_LIGHT_RADIUS :: 85.0  // pixels each of your bullets lights up as it flies
LIGHT_FALLOFF       :: 45.0  // pixels over which light fades from full to dark at its edge

// ---------------------------------------------------------------------------
// Health pickups (rooms 4 and 5)
// ---------------------------------------------------------------------------

PICKUP_RADIUS         :: 10.0 // pixels
PICKUP_SPAWN_INTERVAL :: 7.0  // seconds between pickups appearing
PICKUP_MAX_ON_FLOOR   :: 2    // no more pickups appear while this many are waiting
PICKUP_HEAL           :: 1    // HP restored per pickup
