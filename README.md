# Dank Bar Todo (DankMaterialShell plugin)

A bar plugin for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) that opens a **todo panel** anchored to the bar pill (same popout mechanism as other bar plugins such as those in [dms-plugins](https://github.com/AvengeMedia/dms-plugins)).

## Features

- Outstanding count badge on the checklist icon (counts everything that is not **Complete**).
- Status cycles on the leading icon: **Incomplete** → **Active** → **Complete** → … (icon colour: default / blue when **Active** / green when **Complete**; icon stays vertically centred with the text block).
- Per-todo **notes**, **Edit** / **Delete** from a **⋮** menu. **Delete** is two-step: first tap shows a **check** on green (confirm); second tap removes the todo. **Edit** keeps the same row (drag handle, status, ⋮) and swaps the title/notes area for **plain `TextEdit`** controls with **zero padding** and the **same font sizes** as the read-only labels so editing stays visually in place; length limits are enforced in `onTextChanged` (no `maximumLength`). The colour strip and **Save** / **Cancel** stay in a block below the row. **Add todo** still uses **DankTextField** in the bottom card.
- **Show completed** toggle (persisted).
- **Add**: tap **Add todo** for title, notes, then the colour strip (full width), then **Add** / **Cancel**; the bottom card previews the chosen tint; **Enter** in the title or notes saves when the title is non-empty. Double-click a **colour** or **clear** swatch while composing cancels compose.
- **Reorder**: drag the handle on the left edge of a row to move it in the filtered list (order is persisted in the full todo list).
- **Expand**: header **open in full** / **fullscreen exit** icon toggles the list area between the normal capped height and `min(content height, available screen height)`.
- **Header**: **undo** → **redo** → **sort** → **expand** (fullscreen). **Sort** opens a **`Popup`** that is a **sibling of the todo panel** under the popout root (`mapToItem` from the sort button), with **`modal: false`** so it does not attach to the shell overlay (which broke rendering on the bar). **`popoutRoot.clip`** is **false** so the menu can extend outside the header strip when needed. Each criterion cycles on repeat taps: **1st** → ascending sort (**arrow_upward**); **2nd** → descending (**arrow_downward**); **3rd** → restore the list order from **before** that criterion’s first tap (no arrow). **Colour** ascending: palette order → other hexes → untinted last. **Created date** ascending: **oldest first** by `t{timestamp}_` in `id` (descending = newest first). **Urgency** ascending: non-urgent before urgent. **Status** ascending: Incomplete → Active → Complete. Choosing a **different** criterion starts a new cycle (snapshot is the current order). Sort steps use **`setTodosCopy`** (undoable); **undo / redo / reload** clear the sort arrows. **Undo / redo** cap **50** steps; reload clears undo stacks. If reload misbehaves after a bad QML compile, run **`dms restart`** once.
- **Row colour & urgent**: one shared **QML `Component`** (`tintUrgentStripComponent`) is loaded in three places — **⋮** (when the row menu is open), **Edit** (between notes and Save/Cancel), and **Add todo** (below the compose fields, **no** label above the strip). Each strip is the same layout: equal cells for palette + clear + **urgent last** (`priority_high`). Todo rows use `applyTodosPreserveMenu` so **⋮** and **Edit** can update tint/urgent without closing the menu or leaving edit; double-click a colour or clear swatch exits **compose** or **edit** (not used in **⋮**). Urgent todos use a **vibrant border and urgent swatch** derived from the row tint (saturation boost from the swatch colour); with **no** tint, urgent still uses **`Theme.error`** (`urgent` in saved data). With a row tint set, **title** and **notes** use a **lighter blend of that tint** toward white (notes a bit more washed than title); **Complete** rows blend those colours back toward the default text colours as the card fill dims. Untinted rows keep the normal theme text colours.
- Data stored with `pluginService.savePluginState` / `loadPluginState` under plugin id `dankBarTodo` (**todos**, **showCompleted**).

## Install

1. Copy the `DankBarTodo` folder into your DankMaterialShell plugins directory (the same place you install other [dms-plugins](https://github.com/AvengeMedia/dms-plugins) bundles).
2. Enable the plugin in DMS settings and add **Dank Bar Todo** to the bar layout if prompted.

Reload after changes:

```bash
dms ipc call plugins reload dankBarTodo
```

## Files

| File | Purpose |
|------|---------|
| `plugin.json` | Plugin manifest |
| `DankBarTodoWidget.qml` | Bar pill + popout UI |
| `DankBarTodoSettings.qml` | Settings stub (plugin is mostly self-contained in the popout) |

## License

MIT (see `LICENSE`).
