# Changelog

## 2026-04-28

- [Fixed]: ListView todo delegate used `model.todoId` etc., which resolved to the list’s `model` object instead of row roles—every row matched empty `editingId` and showed edit UI; delegate now declares `required property` roles (`todoId`, `todoTitle`, `todoNotes`, `todoStatus`) (Mike Thomas, 2026-04-28)
- [Changed]: Status icon vertically centred with text block; removed status-based card green/blue; per-todo optional `tint` (palette + clear in ⋮ menu); active status icon uses info/blue, complete uses success/green; completed rows dim user tint toward surface; status/tint preserved on reorder and status cycle (Mike Thomas, 2026-04-28)
- [Changed]: README describes status icon colours, vertical alignment, and row tint swatches via the ⋮ menu (full-width strip) (Mike Thomas, 2026-04-28)
- [Fixed]: Row tint applied `Theme.withAlpha` to hex strings (collapsed to grey); tint now blends `Theme.surfaceContainerHigh` with `Qt.color(hex)` using `Qt.rgba` lerp; completed state dims with lerp toward `Theme.surface` (Mike Thomas, 2026-04-28)
- [Changed]: Tint swatches moved from the edit form to the row ⋮ menu (below Edit/Delete) (Mike Thomas, 2026-04-28)
- [Changed]: ⋮ menu tint swatches use a single `Row` so palette + clear split the full todo row width evenly (Mike Thomas, 2026-04-28)
- [Fixed]: Compose title field regains focus after **Add todo** using a short `Timer` plus `onVisibleChanged` (visible items could not focus on the old `Qt.callLater` pass) (Mike Thomas, 2026-04-28)

## 2026-04-24

- [Added]: DankMaterialShell bar plugin `DankBarTodo` — dropdown todo list with status cycle, notes, completion filter, persistence via plugin state, count badge, and settings stub; repository `README.md`, `LICENSE`, `docs/overview.md`, and this changelog (Mike Thomas, 2026-04-24)
- [Fixed]: Popout close (X) forwards `PluginPopout`’s injected `closePopout`; add control is a centered icon square; spacing above the compose bar; Edit/Delete moved into in-flow rows so list reflows instead of overlapping z-stacked menus (Mike Thomas, 2026-04-24)
- [Fixed]: Declare `closePopout` on popout root so `PluginPopout` assigns the closer (`"closePopout" in item`); bind header `closePopout` to that property; match + hover to `DankButton` overlay; show Add/Cancel at 48px height only while composing (replace +) (Mike Thomas, 2026-04-24)
- [Changed]: Bar pill count badge beside icon; todo ⋮ opens inline icon-only edit/delete (delete on red); edit save/cancel centred with `Theme.success` / `Theme.error`; full-width “Add todo” primary action (Mike Thomas, 2026-04-24)
- [Changed]: Edit mode save/cancel use full row width (split 50/50); ⋮ menu dismisses on outside taps (other rows, title strip, show-completed row, compose bar overlay, or status icon before cycling); status icon right-click cycles backward; fixed stray brace in bottom `StyledRect` (Mike Thomas, 2026-04-24)
- [Changed]: Bar outstanding-count badge uses smaller pixel font and tighter pill (Mike Thomas, 2026-04-24)
- [Changed]: Count badge font and pill height scale from `barThickness` so scaled-down bars get proportionally smaller type (Mike Thomas, 2026-04-24)
- [Changed]: Bar count badge font `barThickness × 0.238`, pill height `barThickness × 0.315` (Mike Thomas, 2026-04-24)
- [Changed]: Todo rows use a light green card tint when active and a light blue tint when complete (`Qt.tint` with `Theme.success` / `Theme.info`) (Mike Thomas, 2026-04-24)
- [Added]: Drag handle on each todo row to reorder; header icon toggles expanded list height (`min` of content height and screen cap); focus title after Add todo; Enter in compose notes submits like title (Mike Thomas, 2026-04-24)
- [Changed]: README documents reorder, expand toggle, compose focus, and Enter in notes (Mike Thomas, 2026-04-24)
