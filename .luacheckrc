-- Luacheck config for the compaktcircuit Factorio 2.0 mod.
-- Goal: syntax errors + undefined/misspelled globals. Style warnings are
-- disabled because the fork inherits upstream formatting.
-- Run with: luacheck .

std = "lua52"
max_line_length = false

-- Factorio engine globals (read-only), both data and control stage
read_globals = {
    "script",
    "game",
    "defines",
    "remote",
    "rendering",
    "prototypes",
    "settings",
    "commands",
    "helpers",
    "serpent",
    "log",
    "table_size",
    "util",
    "mods",
    "__Profiler",
}

-- Writable globals: Factorio data/save state + this mod's cross-module globals
globals = {
    "data",                   -- data stage prototype table (data:extend)
    "storage",                -- control stage persisted state (Factorio 2.0)
    "procinfos",              -- mod global: processor registry
    "IsProcessorRebuilding",  -- mod global set during processor rebuild
    "SignalOrder",            -- mod global: data-stage signal order counter
}

ignore = {
    "143/table",  -- table.deepcopy is added by Factorio's lualib
    "122/game",   -- game.players[i].opened = ... is a valid Factorio API write
    "2..",        -- unused variables/arguments
    "3..",        -- unused/overwritten values
    "4..",        -- shadowing
    "5..",        -- control flow smells (empty branches etc.)
    "6..",        -- whitespace/formatting
}
