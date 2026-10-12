# Bestiary+

A hunting log for **Ys Origin** on CleriaCore, kept with each save: every kind of monster you have killed, how
many, the EXP and SP they gave you, and the room where you first met them.

- A card announces each **new kind** the first time you kill one ("New in the bestiary: Selnarg (level 3)").
- **F1 > Mods > Bestiary+** lists them, sorted by first met, most killed or level:

  ```
  Selnarg  (lv 3)      12 killed  -  611 EXP  -  48 SP        First met in S_1002.
  Baocar  (lv 4)        7 killed  -  406 EXP  -  35 SP        First met in S_1002.
  ```
- **Export** writes the list to a text file.

Each save has its own log: a new game starts empty, a load brings its own back. Bosses are not monsters for the
game and are not listed.

## Install

1. Download `4rtefakt.bestiary-1.0.0.cleriamod` from the [releases](../../releases).
2. Double-click it (or use F1 > Mods > *Install a mod file...*).
3. Turn **Bestiary+** on in F1 > Mods and restart CleriaCore.

Needs a CleriaCore with mod API 6.

## How it works

Two files: [main.lua](main.lua) (80 lines) and [names.lua](names.lua), the monsters' names as the game's own data
spells them. One event does the work:

```lua
cleria.events.on("enemy_killed", function(e)        -- e.cast, e.level, e.exp, e.sp, e.room
    local r = log[tostring(e.cast)]
    if not r then
        r = {n = 0, exp = 0, sp = 0, level = e.level, room = e.room, seq = kinds + 1}
        log[tostring(e.cast)] = r
        cleria.notice(name_of(e.cast) .. " (level " .. e.level .. ")", "New in the bestiary")
    end
    r.n, r.exp, r.sp = r.n + 1, r.exp + e.exp, r.sp + e.sp
    cleria.save.set("log", log)                     -- a whole table, stored with the game's save
end)
```

| Part | API |
|---|---|
| The log | the `enemy_killed` event |
| Kept with the save | `cleria.save.get` / `set` with a table value |
| A second file | `require("names")`, resolved inside the mod's folder |
| The list, the export | `cleria.ui.page` (`info` rows, a `choice`, a `button`), `cleria.data.write` |

## Tests

`python .dev/run.py` runs one case through CleriaCore's headless harness: a Selnarg is killed (the entry appears
with the engine's level, EXP and SP, and the card is shown), then a Baocar (a second entry), then the game is saved
and loaded and the log is the same.

Not covered: the page's look and the export button are not exercised by a test.

## About

Written with AI assistance (Claude Code) as a showcase of the CleriaCore mod API, and tested as described above.
MIT license.
