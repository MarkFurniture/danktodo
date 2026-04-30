# Dank Bar Todo (DankMaterialShell plugin)

A bar plugin for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) that opens a **todo panel** anchored to the bar pill (same popout mechanism as other bar plugins such as those in [dms-plugins](https://github.com/AvengeMedia/dms-plugins)).

## Features

- Outstanding count badge on the checklist icon (counts everything that is not **Complete**).
- Status cycles on the leading icon: **Incomplete** → **Active** → **Complete** → … (icon colour: default / blue when **Active** / green when **Complete**; icon stays vertically centred with the text block).
- Per-todo **notes**, **Edit** / **Delete** from a **⋮** menu. **Edit** hides the row chrome and shows **DankTextField** title/notes (length limits enforced in `onTextChanged`, not `maximumLength`, for compatibility with the shell’s Qt Quick `TextEdit` backend), colour strip, then **Save** / **Cancel**.
- **Show completed** toggle (persisted).
- **Add**: tap **Add todo** for title, notes, then a labelled **Colour & urgent** strip (full width), then **Add** / **Cancel**; the bottom card previews the chosen tint; **Enter** in the title or notes saves when the title is non-empty. Double-click a **colour** or **clear** swatch while composing cancels compose.
- **Reorder**: drag the handle on the left edge of a row to move it in the filtered list (order is persisted in the full todo list).
- **Expand**: header **open in full** / **fullscreen exit** icon toggles the list area between the normal capped height and `min(content height, available screen height)`.
- **Undo / redo**: header **undo** and **redo** icons sit to the **left** of the expand control; they step through JSON snapshots of the **todo list** (add, edit, delete, reorder, status, tint, urgent). Stacks reset when todos are reloaded from storage; up to **50** undo steps. If reload misbehaves after a bad QML compile, run **`dms restart`** once.
- **Row colour & urgent**: one shared **QML `Component`** (`tintUrgentStripComponent`) is loaded in three places — **⋮** (when the row menu is open), **Edit** (between notes and Save/Cancel, **no** “Colour & urgent” label), and **Add todo** (with that label above the strip). Each strip is the same layout: equal cells for palette + clear + **urgent last** (`priority_high`). Todo rows use `applyTodosPreserveMenu` so **⋮** and **Edit** can update tint/urgent without closing the menu or leaving edit; double-click a colour or clear swatch exits **compose** or **edit** (not used in **⋮**). Urgent todos use a **red border** (`urgent` in saved data). Completed todos keep their tint but the fill is **dimmed** toward the surface.
- Data stored with `pluginService.savePluginState` / `loadPluginState` under plugin id `dankBarTodo`.

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
