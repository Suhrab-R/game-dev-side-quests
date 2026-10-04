---
# ---- Fill every field. Use `unavailable` (with a reason in tokens_source) rather than guessing. ----
game_title: "ARENA: Escape Rooms"
twist_one_liner: ARENA, but a roguelike run through 5 timed rooms, each harder than the last with new twists.            # "ARENA, but ..."
twist_category: rule-bender, enemies, other/go further              # rule-bender | enemies | player-progression | world | other
twist_from_ideas_list: yes and adapted some      # yes | adapted | no
how_far_from_arena: substantial         # small-twist | substantial | barely-recognizable

# Tools and models (lists; exact names as the tool shows them)
tools: [claude-code]                      # e.g. [claude-code, chatgpt-web]
models: [claude-opus-5.5]                     # e.g. [claude-sonnet-5, gpt-5-mini]
primary_model: claude-opus-5.5              # the one that did most of the work
plan: paid-personal                       # free | student | paid-personal | api | none
agent_instructions_file: yes    # yes | no  (CLAUDE.md, AGENTS.md, .cursorrules, ...)

# Totals (must match jam-log.csv)
sessions: 2
total_minutes: 45
total_prompts: 13
total_tokens_in: 10104446             # or unavailable
total_tokens_out: 99339            # or unavailable
tokens_source: ccusage (incl. cache)              # ccusage | cost-command | dashboard | cli-summary | estimated | unavailable (+ why)

# Your estimate of who wrote the code in the final build (should add to 100)
code_share_llm_pct: 100          # accepted from an LLM with little or no change
code_share_mixed_pct: 0        # LLM-generated then substantially edited by you
code_share_hand_pct: 0         # written by you

# Before this jam
odin_experience_before: none     # none | under-10h | 10-50h | over-50h
llm_coding_before: weekly          # never | occasional | weekly | daily
gamedev_experience_before: a tutorial  # none | a-tutorial | a-few-small-games | shipped-something

transcripts_shared: no         # yes | no  (optional, ungraded)
---

# Postmortem — ARENA: Escape Rooms

> Your own words. Grammar and spelling help from a tool is fine; the argument
> and the evidence are yours. Aim for 1-2 pages plus the table.

## 1. The game

*One paragraph: what your game is and how to play it. Then what you **kept**,
**changed**, **removed** and **added** compared with ARENA.*
```
My game jumps from the provided Arena template and turns it from a simple 1 room shooter with only 1 enemy and a time limit, to a 5 room shooter where the player has to survive in each room for 30s before being able to move to the next room, with each room having its own new twist and enemies, with the difficulty ramping up the further the player gets.

What I kept: I kept most of the base gameplay of and style of Arena
Changed: Gameplay tweaks such as: enemy speed, spawn rate, background colour
Removed: Didn't really remove much just built on top of what already existed
Added: A bunch of features such as: room mechanics, new twists in each room, different enemies, health pickups
```
**Where is the depth?** Answer the three questions from the README: the new
**decision** the twist creates, the **trade-off** behind it, and what an
**expert** does differently from a beginner. Use what you saw players do at
the Monday showcase as evidence.
```
1. The decision
In this version of the game, the player chooses how they want to strategize for each level. For example in the second room, the walls shrink and they player needs to avoid the red enemies and shoot the green ones to re-expand the arena. If a player gets cornered, they need to decide if they want to risk losing hp and running through the red enemies or risk the arena size by killing a few red enemies but keeping there hp. Another example in the 3rd room with the darkness, they can strategize how they see if they want to spam their shoot the entire time to get as much visibility as they can, or just rely on the light around their player

2. The trade-offs
Similar to what I mentioned previously, if the player is in a tough spot on room 2, they can either kill the red enemies to get out of the corner, keeping their hp but shrinking the arena, or they can risk an hp loss but not lose as much arena size

3. The mastery
For room 2, an expert would probably manage their movement and be able to dodge all the red enemies and make the most of their kills waiting for a certain amount of green enemies to be on the map before choosing to kill some red enemies. In room 4, expert players might avoid entering room 5 right after the timer ends and instead wait for the health drops to spawn, allowing them to fully heal up back to 5 hp before entering the hardest room, etc.
```
## 2. Your setup

Which tools and models, and **why** those (cost, familiarity, a friend's
advice...). Did you give the agent a project instruction file, the Raylib
binding, docs, example code? Paste the instruction file, or its key lines, if
you used one.
```
I used Claude code with Claude Opus 5.5 as the model because I use claude fairly regularly and it is what I am the most used to and am able to be the most efficient with using. I know how to make comprehensive prompts that the AI is able to get correct on the first try using only a single prompt most of the time because I know how to give the model the proper context it needs. I did have claude generate a Claude.md file that it constantly updated throughout the sessions so it would always know the context of the assignment throughout sessions without having to waste a bunch of tokens in 1 session.
```
Here are the key lines:
```
**Build and verify**
- After every code change, at minimum run `odin build src` (or `odin check src`)
  and fix all errors before reporting done. Say whether it was actually run.
- The exact Raylib API as Odin sees it: `<odin root>/vendor/raylib/raylib.odin`.
  Check a proc's real name and signature there before using it. Don't guess from
  C names or memory.

**Code style: readable by a programmer who doesn't know Odin**
- The user isn't an Odin expert and must be able to explain every line. The target
  reader is someone who can program (C, Java, Python...) but has never seen Odin.
- Small, single-purpose procs with descriptive names. If a proc does several
  things or grows past ~40 lines, split it.
- Keep all game state in the `Game` struct, passed as `g: ^Game`. No global
  mutable variables.
- No magic numbers. Every tuning value is a named constant in the config
  section/file, with a comment giving its unit (seconds, pixels/sec, HP...).
- Prefer plain, obvious features: structs, enums, `switch`, `[dynamic]` arrays,
  `for` loops. Avoid `using`, parametric polymorphism (`$T`), `#soa`, operator
  tricks, and `or_return` chains unless there's a clear win.
- A short comment above every proc saying what it does and why. Explain
  Odin-specific syntax the first time it shows up in each file.

**How to work with the user**
- Keep the game playable at all times. Build the smallest version of a feature
  first, compile, then extend.
- Depth over complexity. When suggesting features, check them against the three
  depth questions. Prefer one rule that changes decisions over more content.
- Don't commit or push unless asked.

**Session logging**
- The user marks each jam session with two one-line prompts: `session start` and
  `session end`. These two prompts are the only triggers. Never log a session,
  edit `jam-log.csv`, or edit `ATTRIBUTION.md` at any other time.
- On `session end`: run `jam_session_stats.py`, append one row to `jam-log.csv`
  (leave `llm_helpfulness` and `notes` empty for the user), and add one
  ATTRIBUTION row per prompt.
- POSTMORTEM.md: don't write its prose; it must be the user's own voice.

```

## 3. Feature by feature

One row per feature you built. The first rows are ARENA's parts; drop the ones
you removed, and add a row for each feature of your own.
`who` = `llm`, `mixed` or `me`. `first try` = did the first LLM answer work
without changes? `help` = 1 (got in the way) - 5 (did it well).

| feature | who | prompts | first try? | minutes | help 1-5 | note |
|---|---|--:|---|--:|:--:|---|
| window, loop, game states, restart | | | | | | |
| player movement | | | | | | |
| shooting | | | | | | |
| enemies and spawning | | | | | | |
| health, damage, hit feedback | | | | | | |
| difficulty over time | | | | | | |
| HUD | | | | | | |
| (optional) sprites / sound | | | | | | |
| split code into files (refactor) | llm | 1 | yes | 16 |5 | |
| 5-room run with 30 s room timer | llm | 1 | yes | 16 |5 | |
| exit door (slides open, never on the wall you came in) | llm | 1 | yes | 16 |5 | |
| shrinking walls + crush = lose (rooms 2, 5) | llm | 1 | yes | 16 |5 | |
| green expander enemies (push walls back) | llm | 1 | yes | 16 |5 | |
| darkness + light around player and bullets (rooms 3, 5) | llm | 1 | yes | 16 |5 | |
| charger enemy (warning flash, then dash) | llm | 1 | yes | 16 |5 | |
| shooter enemy + enemy bullets | llm | 1 | yes | 16 |5 | |
| splitter enemy + children | llm | 1 | yes | 16 |5 | |
| health pickups (rooms 4, 5) | llm | 1 | yes | 16 |5 | |
| room banners, hints, "room cleared" message | llm | 1 | yes | 16 |5 | |
| per-room balance tuning | llm | 10 | yes | 17 |5 | |
| background colour | llm | 3 | yes | 6 |5 | |
| debug keys 1-5 (jump to room) | llm | 1 | yes | 3 |5 | |

## 4. Where the LLM sped you up

The easy parts. Name the features, the session number from `jam-log.csv` or
the commit, and estimate how long it would have taken you without it.
```
Opus 5.5 is a very good model and made pretty much the entire thing extremely easy, as seen from the logs, the entire idea I wanted for the game was essentially completed correctly from 1 long, comprehensive, descriptive prompt that I gave it, and during session 2 only had a lot more prompts because that was the playtesting. Session 1 I was pretty much able to create the entire twists I wanted to implement from 1 good prompt.
Without using Opus 5.5, I believe this entire project would have definitely taken me at least, a minimum of a week of constant work. From having to learn a whole new programming language and library with Odin and Raylib, all the features would have taken an extremely long time without this tool
```
## 5. Where it did not help

The hard parts. What was the problem, what did you try (prompts, other models,
docs, a classmate, doing it by hand), and what finally worked? Was the
difficulty Odin, Raylib, game design, tuning the feel, or the tool itself?

```
There was pretty much no place in this project where the LLM did not help or do its job incorrectly. The LLM was extremely helpful and accurate and listened to exactly what I asked for in every prompt I gave. I can't really answer this properly because the LLM was very helpful throughout the entire process
```

## 6. One LLM-introduced bug: found, fixed, verified

- **The bug**: what it did wrong, and the code (a short excerpt or a commit link).
- **How you noticed**.
- **The fix**: the code after.
- **How you know it is fixed**: the evidence (debug draw, printed values, a
  test, a before/after clip or screenshot in the repo).
```
The LLM did not introduce any bugs that were not very small, and that they weren't able to fix themselves in that same response. There was not a single time where the LLM had given me an output where there was a bug that I had to prompt the LLM to fix again. Any small bug that it had noticed, it had fixed it in that same response.
```
## 7. Pitch vs. delivered

Paste your Wednesday pitch. What survived, what was cut, what was added, and why.
What did you change after the Monday showcase, based on how people played it?

Wednesdays pitch:
```
ARENA, but a roguelike run through 5 timed rooms, each harder than the last with new enemies, hazards or power-ups.
```

```
Pretty much nothing was cut. My pitch matches pretty well to my final product. Unfortunately I was not able to attend the Monday class due to an illness that I had contacted the professor about, so I was not able to have classmates play my game and receive feedback that way.
```
## 8. Improving the pipeline

If you did another jam next week with the same tools, what would you change?
Be concrete: setup, instruction files, prompting habits, when to use the LLM
and when not, commit rhythm, how you verify, which model for which job.
What would you want **from the tools** that they do not do today?
```
I don't think I would change anything about the way I went about this game jam. I feel I was able to see the results that I wanted as efficiently as possible and was able to use the LLM and its instruction file to the best of its ability. Most of the background grunt work was already handles by the LLM due to my prompts and the context I gave it of the assignment. All that I really had to do was tell it my ideas that I wanted to create and I very rarely if at all had to repeat a request. If I did another game jam I would have the same setup, with a similar instruction file, and prompting habits. 
```

## 9. Anything else

Optional: what surprised you, what you learned about Odin, Raylib or game
development, what you would tell next year's class.
