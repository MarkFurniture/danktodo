# Changelog

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
