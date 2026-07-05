# CLAUDE.md

## What this is

Fork of the Factorio 2.0 mod **Compakt circuits** (`compaktcircuit`, upstream:
https://github.com/Telkine2018/compaktcircuit). The mod packs a whole circuit
network (combinators, wires, displays) into a single 2x2 or 1x1 "processor"
entity. Internally each processor owns a hidden editor surface (named
`proc_<N>`) where the player builds the circuit; on "packing", the circuit is
serialized into the processor and executed via invisible packed entities.

Pure Lua, no build step, no unit tests — correctness is verified by static
checks plus loading the mod in Factorio.

## Layout / Factorio load stages

Factorio loads mods in three stages; entry points at the repo root:

- `settings.lua` — settings stage: mod settings prototypes.
- `data.lua` → `data/*.lua` — data stage: entity/item/recipe/sprite/signal
  prototypes (`data/data.lua` main prototypes, `data/combinators.lua` packed
  combinator variants, `data/input_display.lua`, `data/sprites.lua`,
  `data/signals.lua`). `data-final-fixes.lua` runs last (collision boxes,
  Space Age planet signals).
- `control.lua` → `scripts/` — control (runtime) stage.

Control-stage modules (`scripts/`):

- `processor.lua` — top-level runtime wiring: event handlers, entity
  lifecycle (build/destroy/clone/blueprint), migrations (flib), remote
  interface `compaktcircuit_move` for mods that move entities.
- `editor.lua` — the internal editor surface: opening/closing a processor,
  GUI, remote interface `compaktcircuit` (add_combinator etc.).
- `build.lua` — packing/unpacking circuits, blueprint (de)serialization,
  `get_procinfo`; sets the cross-module global `IsProcessorRebuilding`.
- `display.lua`, `input.lua` — display panels and external inputs of a
  processor.
- `comm.lua` — communication/channels between processors.
- `runtime.lua` — generic per-tick scheduler (`Runtime.register`): batches
  entity updates across ticks, state lives in `storage[global_name]`.
- `tools.lua` — shared helpers (event dispatch wrappers `tools.on_event`,
  `tools.on_init`, debug, GUI utils). Prefer these over raw `script.on_event`
  — modules must not overwrite each other's handlers.
- `ccutils.lua`, `commons.lua` — constants: entity names built from the
  `compaktcircuit-` prefix, IO constants. Always take entity names from
  `commons`, never hardcode strings.
- `_defs.lua` — LuaLS `---@class` annotations for the mod's data structures
  (ProcInfo etc.). Keep annotations up to date when changing structures.
- `models_lib.lua`, `inspect.lua` — saved circuit models, inspection UI.

Other: `graphics/`, `locale/en/base.cfg` + `locale/ru/base.cfg`,
`changelog.txt`, `info.json` (mod metadata, version, dependencies — required:
`flib`; optional: Space Age, even-pickier-dollies, DisplayPlatesForked).

## Conventions

- Factorio 2.0 API: persisted state is `storage` (not `global` — that's 1.1).
  `prototypes`/`helpers` replace parts of old `game.*`.
- Cross-module mutable globals (intentional): `procinfos` (processor
  registry), `IsProcessorRebuilding` (control stage), `SignalOrder`
  (data-stage signal order counter). Declared in `.luacheckrc`.
- Extensive LuaLS annotations (`---@param`, `---@type`, `---@class`) —
  follow suit in new code.
- Optional-mod code paths are guarded by `mods["space-age"]` (data stage) or
  `script.active_mods` / remote interface checks (control stage).
- Locale keys live under the `compaktcircuit.` section; update **both**
  `locale/en/base.cfg` and `locale/ru/base.cfg`.

## Checks and workflow

- **Lint (run before committing):** `luacheck .` — config in `.luacheckrc`,
  tuned to 0 warnings on the current codebase; it catches syntax errors and
  misspelled globals. On Debian/Ubuntu the package is `lua-check` (a
  SessionStart hook in `.claude/` installs it in web sessions). New
  legitimate globals must be added to `.luacheckrc` (and `.vscode/settings.json`).
- **No automated tests.** Runtime behavior can only be verified inside
  Factorio (see README for symlink/debugger setup) — say so honestly instead
  of claiming a change is tested.
- **Release:** bump `version` in `info.json`, add a `changelog.txt` entry
  (strict Factorio changelog format: 99-dash separator line,
  `Version:`/`Date:`, two-space indented categories), merge to `main`.
  CI (`.github/workflows/release.yml`) then tags the commit `v<version>`
  and publishes a GitHub release with the built zip; release notes are the
  version's `changelog.txt` section. The job is idempotent — it skips when
  the tag already exists. `./package.sh` stays for local builds
  (→ `dist/compaktcircuit_<version>.zip`).
- Multiplayer safety: control-stage code must stay deterministic; never key
  behavior off `game.player`, avoid non-serializable values in `storage`.
