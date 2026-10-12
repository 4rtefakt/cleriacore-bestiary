-- Bestiary+: a hunting log, kept with the save.
-- One event does the work: enemy_killed gives the monster's cast id, its level, and the EXP and SP it paid.

local S = cleria.settings
local NAMES = require("names")                 -- cast id -> name (the game's CASTINFO)

local announce = S.get("Announce", true)       -- a card for each new kind
local order = S.get("Order", 1)                -- 1 first met, 2 most killed, 3 level

-- log[tostring(cast)] = {n = kills, exp = , sp = , level = , room = first met, seq = order met}
local log, kinds = {}, 0
local function restore()
    local t = cleria.save.get("log")
    log, kinds = type(t) == "table" and t or {}, 0
    for _ in pairs(log) do kinds = kinds + 1 end
end
cleria.events.on("new_game", restore)
cleria.events.on("load", restore)

local function name_of(cast) return NAMES[cast] or ("Monster #" .. cast) end

cleria.events.on("enemy_killed", function(e)
    local key = tostring(e.cast)
    local r = log[key]
    if not r then
        kinds = kinds + 1
        r = {n = 0, exp = 0, sp = 0, level = e.level, room = e.room, seq = kinds}
        log[key] = r
        if announce then cleria.notice(name_of(e.cast) .. " (level " .. e.level .. ")", "New in the bestiary") end
        cleria.log("new kind: " .. name_of(e.cast) .. " level " .. e.level .. " in " .. e.room)
    end
    r.n, r.exp, r.sp = r.n + 1, r.exp + e.exp, r.sp + e.sp
    if cleria.save.ready() then cleria.save.set("log", log) end
end)

local function sorted()
    local t = {}
    for key, r in pairs(log) do t[#t + 1] = {cast = tonumber(key), r = r} end
    table.sort(t, function(a, b)
        if order == 2 and a.r.n ~= b.r.n then return a.r.n > b.r.n end
        if order == 3 and a.r.level ~= b.r.level then return a.r.level < b.r.level end
        return a.r.seq < b.r.seq
    end)
    return t
end
local function line(e)
    return string.format("%d killed  -  %d EXP  -  %d SP", e.r.n, math.floor(e.r.exp + 0.5), e.r.sp)
end

cleria.ui.page("Bestiary+", function(p)
    p:section("Bestiary+")
    local total = 0
    for _, r in pairs(log) do total = total + r.n end
    p:info("Kinds met", tostring(kinds), total .. " monsters killed in this save.")
    local v, ch = p:choice("Order", order, {"First met", "Most killed", "Level"}, "How the list below is sorted.")
    if ch then order = v S.set("Order", v) end
    v, ch = p:toggle("Announce new kinds", announce, "A card when you kill a kind of monster for the first time in this save.")
    if ch then announce = v S.set("Announce", v) end
    if p:button("Export", "Writes the list to a text file in the mod's data folder (modsdata).") then
        local out = {}
        for _, e in ipairs(sorted()) do out[#out + 1] = string.format("%-18s lv %2d  %s  first met in %s", name_of(e.cast), e.r.level, line(e), e.r.room) end
        cleria.data.write("bestiary.txt", table.concat(out, "\n") .. "\n")
        cleria.notice("Written to modsdata/4rtefakt.bestiary/bestiary.txt", "Bestiary+")
    end
    p:section("Monsters")
    if kinds == 0 then p:info("Nothing yet", "", "Kill something.") end
    for _, e in ipairs(sorted()) do
        p:info(name_of(e.cast) .. "  (lv " .. e.r.level .. ")", line(e), "First met in " .. e.r.room .. ".")
    end
end)

cleria.command("best", function()
    for _, e in ipairs(sorted()) do cleria.log(name_of(e.cast) .. " lv " .. e.r.level .. ": " .. line(e) .. ", first met in " .. e.r.room) end
    cleria.log(kinds .. " kinds")
end)
cleria.log("Bestiary+ loaded")
