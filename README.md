# Dank Bar Todo

[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) bar plugin: checklist pill opens a **todo panel** (same popout pattern as other [dms-plugins](https://github.com/AvengeMedia/dms-plugins) bar widgets).

## Features

- **Todos**: title, optional notes, optional row colour and **urgent** flag. **Add todo** at the bottom; **Enter** saves when the title is non-empty.
- **Status** (leading icon): **cancelled**, **new**, **in progress**, or **complete**. Switch with **left** and **right** click. The bar badge counts items that still need doing (**new** and **in progress** only).
- **⋮ menu**: edit or delete. **Delete** needs two taps (confirm then remove).
- **Reorder**: drag the handle on the left of a row.
- **Show completed & cancelled**: when off, **completed** and **cancelled** rows are hidden; when on, every todo is listed (saved with your data).
- **Sort** (header): pick **colour**, **created**, **urgent**, or **status**. Tap the same option repeatedly: sort up, sort down, then restore the previous order. Picking a different option starts a new three-step cycle.
- **Undo / redo** (header): up to **50** steps; reloading the list clears the stacks.
- **Expand** (header): toggles a taller list area when you have many todos.

Data is stored in DMS **plugin state** (`dankBarTodo`). Multiple bars stay aligned when another instance updates the saved list.

## Install

1. Copy the `DankBarTodo` folder into your DMS plugins directory.
2. Enable the plugin and add **Dank Bar Todo** to the bar layout if prompted.

Reload after plugin changes:

```bash
dms ipc call plugins reload dankBarTodo
```

## Troubleshooting

- If the panel acts odd after editing QML, try **`dms restart`** once, then reload the plugin as above.

## Files

| File | Purpose |
|------|---------|
| `plugin.json` | Plugin manifest |
| `DankBarTodoWidget.qml` | Bar pill and popout UI |
| `DankBarTodoSettings.qml` | Settings stub |

## License

MIT (see `LICENSE`).
