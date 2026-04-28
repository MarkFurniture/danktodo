# Dank Bar Todo (DankMaterialShell plugin)

A bar plugin for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) that opens a **todo panel** anchored to the bar pill (same popout mechanism as other bar plugins such as those in [dms-plugins](https://github.com/AvengeMedia/dms-plugins)).

## Features

- Outstanding count badge on the checklist icon (counts everything that is not **Complete**).
- Status cycles on the leading icon: **Incomplete** → **Active** → **Complete** → … (icon colour: default / blue when **Active** / green when **Complete**; icon stays vertically centred with the text block).
- Per-todo **notes**, **Edit** / **Delete** from a **⋮** menu.
- **Show completed** toggle (persisted).
- **Add**: tap **Add todo** to reveal title and notes fields on the bottom row (title field is focused); **Add** / **Cancel**; **Enter** in the title or notes field saves when the title is non-empty.
- **Reorder**: drag the handle on the left edge of a row to move it in the filtered list (order is persisted in the full todo list).
- **Expand**: header **open in full** / **fullscreen exit** icon toggles the list area between the normal capped height and `min(content height, available screen height)`.
- **Row colour**: open the **⋮** menu on a row to show **colour swatches** (plus clear) across the full row width; they set an optional per-todo tint (persisted as `tint`). Completed todos keep that tint but the card is **dimmed** toward the surface.
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
