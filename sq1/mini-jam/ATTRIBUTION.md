# Attribution

Every asset you did not make. Delete the example row.

## AI-generated assets
| asset (file) | source (URL) | author | licence | changes you made |
|---|---|---|---|---|

## Code

| asset (file) | tool + model | prompt (short) | hand edits |
|---|---|---|---|
| `src/main.odin` | claude-code, claude-opus-5-5 | Build the base ARENA game per README.md: top-down survival shooter, WASD movement, mouse-aimed shooting, enemies spawning from edges and chasing the player, HP/damage/invulnerability, difficulty ramp over time, title/win/lose states with restart | |
| `src/main.odin`, `src/config.odin`, `src/types.odin`, `src/rooms.odin`, `src/player.odin`, `src/enemies.odin`, `src/bullets.odin`, `src/collision.odin`, `src/shrinking.odin`, `src/darkness.odin`, `src/pickups.odin`, `src/draw.odin`, `src/hud.odin` | claude-code, claude-opus-5-5 | Turn ARENA into a run of 5 timed 30 s rooms with a red exit door that slides open (never on the wall you entered from): room 1 plain, room 2 shrinking walls with green enemies that push them back, room 3 darkness, room 4 charger/shooter/splitter enemies plus health pickups, room 5 all combined; win after room 5, restart from room 1 (session 1) | |
| `src/config.odin`, `src/main.odin`, `src/types.odin`, `src/shrinking.odin`, `src/enemies.odin`, `src/hud.odin` | claude-code, claude-opus-5-5 | Lighter background so dark rooms are easier to see; in rooms 2 and 5 the walls shrink fast enough to crush the player (a loss) within 30 s unless green enemies are shot; enemy spawns in rooms 1-3 ramp up faster (session 2) | |
| `src/config.odin`, `src/hud.odin`, `src/draw.odin` | claude-code, claude-opus-5-5 | Make the background light grey, with darker text and game colours so everything stays visible (session 2) | |
| `src/config.odin`, `src/hud.odin`, `src/draw.odin`, `src/types.odin`, `src/enemies.odin` | claude-code, claude-opus-5-5 | Undo the light grey: background back to the earlier grey but slightly lighter; bigger light around bullets in the dark; faster spawn and enemy speed ramp in room 1 only (session 2) | |
| `src/config.odin`, `src/types.odin`, `src/shrinking.odin` | claude-code, claude-opus-5-5 | Room 2 only: far fewer green enemies and a much bigger shrink penalty for killing red ones (session 2) | |
| `src/config.odin` | claude-code, claude-opus-5-5 | Set room 2's green spawn chance to 0.25 (session 2) | |
| `src/main.odin` | claude-code, claude-opus-5-5 | Debug keys 1-5 that jump straight to that room for testing, to be removed before submission (session 2) | |
| `src/config.odin`, `src/types.odin`, `src/shrinking.odin` | claude-code, claude-opus-5-5 | Room 5 walls shrink a bit slower (session 2) | |
| `src/config.odin`, `src/types.odin`, `src/rooms.odin`, `src/hud.odin` | claude-code, claude-opus-5-5 | Make room 5 last only 20 seconds (session 2) | |
| `src/config.odin`, `src/types.odin`, `src/darkness.odin` | claude-code, claude-opus-5-5 | Bigger light around the player in room 5 (session 2) | |
| `src/config.odin` | claude-code, claude-opus-5-5 | Make room 5 last 25 seconds (session 2) | |
| `src/config.odin`, `src/types.odin`, `src/rooms.odin`, `src/hud.odin` | claude-code, claude-opus-5-5 | Put room 5 back to 30 seconds (per-room length setting removed again) (session 2) | |
| `src/config.odin` | claude-code, claude-opus-5-5 | Fewer green enemies in room 5 (session 2) | |


Any code copied or adapted from somewhere other than an LLM (tutorials,
examples, templates), with the link.
