# Dank Bar Todo (DankMaterialShell plugin)

A bar plugin for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) that opens a **todo panel** anchored to the bar pill (same popout mechanism as other bar plugins such as those in [dms-plugins](https://github.com/AvengeMedia/dms-plugins)).

## Features

- Outstanding count badge on the checklist icon (counts everything that is not **Complete**).
- Status cycles on the leading icon: **Incomplete** → **Active** → **Complete** → …
- Per-todo **notes**, **Edit** / **Delete** from a **⋮** menu.
- **Show completed** toggle (persisted).
- **Add**: tap `+` to reveal title and notes fields on the bottom row; **Add** / **Cancel** (or Enter in the title field to save).
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
