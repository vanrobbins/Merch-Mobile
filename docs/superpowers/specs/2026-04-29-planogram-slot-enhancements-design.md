# Planogram Slot Enhancements Design

**Goal:** Replace the current single-product planogram grid with a free-placement fixture system. Users place physical fixtures (shoulder hook, face-out hook, u-bar, shelf) anywhere in a column, then press a fixture to assign products. Fixtures auto-size vertically based on the tallest assigned product's hang length.

**Interaction model:** EFT-style grid. The wall is divided into columns × quarter-slots. Each row = 4 quarter-slots. Fixtures are blocks that occupy N quarter-slots and stack freely within a column.

**Architecture:** Replace `PgSlot`'s single-product fields with `nodeType`, `items` list, `subRow` (quarter-slot index from top), `spanQuarters`. Extend `PgRow` with `heightIn`. Add `SlotItem` inline model. Auto-size logic in a pure helper.

**Tech Stack:** Flutter/Dart, Riverpod, Firestore (planogram `slotsJson`/`rowsJson` in JSON blobs)

---

## Interaction Flow

### Step 1 — Place fixtures

A **"+ Add Fixture" FAB** (bottom-right, consistent with the rest of the app) opens a bottom sheet with four fixture type tiles:

| Tile | Label | Default quarter-span |
|---|---|---|
| Shoulder hook | SHOULDER | `ceil(hangLength / (rowHeight/4))` |
| Face-out hook | FACE-OUT | 1 quarter min (grows with tallest item) |
| U-bar | U-BAR | 1 quarter min (grows with tallest item) |
| Shelf plank | SHELF | 1 quarter (fixed) |

Tapping a tile places an empty fixture in the next available position in the selected column.

### Step 2 — Assign products

**Pressing a placed fixture** opens a product picker bottom sheet. User selects products from the catalogue. On each assignment, auto-size fires and adjusts `spanQuarters`. For face-out/u-bar: press again or tap "+ Add" to add more (up to capacity). The fixture type label is shown read-only at the top of the sheet.

---

## Data Model

### `SlotItem` (new inline class in `planogram_slot.dart`)

```dart
class SlotItem {
  final String productId;
  final String productName;
  final String productSku;
  final String? colorHex;
}
```

### `PgSlot` changes

| Field | Type | Notes |
|---|---|---|
| `nodeType` | `String` | `'shoulder'` \| `'faceout'` \| `'ubar'` \| `'shelf'`. Set at placement. Null/absent → `'shoulder'` (backward compat). |
| `items` | `List<SlotItem>` | Replaces `productId`/`productName`/`productSku`/`colorHex`. May be empty. Back-compat: if absent but `productId` present, wrap into one-item list on deserialise. |
| `subRow` | `int` | Quarter-slot index from the top of the planogram (0-based). Replaces row-only positioning. |
| `spanQuarters` | `int` | How many quarter-slots this fixture occupies vertically. |

`row` and `col` are kept for backward compat but `subRow` is the authoritative vertical position going forward. `spanRows` is deprecated (computed as `ceil(spanQuarters / 4)`).

**Fixture capacity:**
- `shoulder` — exactly 1 item
- `faceout` — 1–6 items (different SKUs stacked face-out on same hook)
- `ubar` — 2–6 items (different SKUs shoulder-hung on a cross-bar)
- `shelf` — 1+ items (folded/stacked; uses `spanCols` for width)

**Empty fixture state:** `items` is an empty list. The cell renders a fixture-type illustration with a dashed "+ Add product" hint.

### `PgRow` changes

| Field | Type | Notes |
|---|---|---|
| `heightIn` | `double` | Physical row height in inches. Default: `24.0`. |

`rowType` ('bar' \| 'shelf') is kept as the default fixture type when placing via FAB on that row region.

---

## Quarter-Slot Grid

Each row is divided into **4 quarter-slots** vertically.

- **Quarter height in px:** `rowHeightPx / 4`
- **Shelf** always occupies exactly **1 quarter-slot** (fixed).
- **Shoulder, Face-out, U-bar** occupy `ceil(hangLength / (rowHeightIn / 4))` quarter-slots, minimum 1.
- **Free column placement:** fixtures stack in any order within a column. A shelf at the top leaves 3 free quarter-slots below for hanging fixtures. No restrictions on mixing types in a column.

### Hang length lookup (by `Product.category` keywords, case-insensitive)

| Keywords | Hang length |
|---|---|
| pants, jeans, trousers, shorts | 36" |
| dress, coat, gown | 48" |
| jacket, blazer, hoodie, sweater | 30" |
| shirt, blouse, top, tee, tank | 30" |
| bra, bralette, underwear, lingerie | 12" |
| everything else | 18" |

### Auto-size algorithm

Pure function: `int autoSpanQuarters(String longestCategory, double rowHeightIn)`

1. `hangIn = hangLength(longestCategory)`
2. `quarterIn = rowHeightIn / 4`
3. `return max(1, (hangIn / quarterIn).ceil())`

For **shoulder**: called with the single item's category.  
For **face-out / u-bar**: called with the category of the tallest item in `items`. Recalculated on every add/remove.

**Fit warning:** if the total hang length exceeds the available column height, the slot cell shows a red `!` badge. The assignment is still saved.

---

## UI

### Planogram wall — no row dividers

The wall is a continuous grid of columns. No row header labels or rods. Tier boundaries are not visually marked — fixtures flow edge-to-edge. Row heights are configurable via a settings panel (not inline headers).

### Cell visual (`SlotCellWidget`)

Fixture type communicated by a **2px coloured top stripe** + **small pill label** (top-right):

| Fixture | Stripe colour | Pill |
|---|---|---|
| shoulder | `rgba(26,25,23,0.22)` | SHOULDER |
| faceout | `#2E6DA4` (blue) | FACE-OUT |
| ubar | `#BF5534` (accent orange) | U-BAR |
| shelf | `#6B6660` (grey-brown) | SHELF |

Background: `#F2EFE8` (warm off-white). 2 cu ft volume badge bottom-right on filled cells.

**Shoulder:** product icon + name + mode label.  
**Face-out:** "N products · Xinch" subhead + colour-dot chips per item.  
**U-bar:** cross-rod illustration + hanger + product chip rows; empty arms show dashed `＋`.  
**Shelf:** product icon + name + brown plank at bottom edge.  
**Empty fixture:** fixture illustration (hook/rod/plank) + dashed "+ Add product" hint.  
**Fit warning:** red `!` badge top-left when `slotFitWarning = true`.

### FAB + fixture picker sheet

"+ Add Fixture" FAB bottom-right. Tapping opens a bottom sheet with four fixture tiles (one per type, styled with type accent colour).

### Product assignment sheet (press any fixture)

- **Fixture type** — read-only pill (e.g. "FACE-OUT HOOK")
- **Assigned products** — list with ✕ remove buttons
- **+ Add product** — opens product catalogue picker
- **Capacity indicator** — "3 / 6" for faceout/ubar
- **Fit indicator** — green "✓ fits" or red "✗ won't fully fit"
- **Remove fixture** — removes slot from grid

### `PlanogramEditorNotifier` new methods

- `placeFixture(col, subRow, nodeType)` — creates empty `PgSlot`
- `removeFixture(col, subRow)` — removes slot
- `addItemToSlot(col, subRow, SlotItem)` — appends item; triggers auto-size; capped at capacity
- `removeItemFromSlot(col, subRow, int itemIndex)` — removes item; re-runs auto-size
- `setRowHeight(rowIndex, double heightIn)` — updates `PgRow.heightIn`; re-runs auto-size for all slots in that row region

Existing `assignSlot(row, col, productId, name, sku, {colorHex})` kept for backward compat — internally calls `placeFixture` then `addItemToSlot`.

---

## Backward Compatibility

Old planograms with `productId`/`productName`/`productSku` top-level fields on slots load fine. `PgSlot.fromJson` checks `items` first; if absent and `productId` present, synthesises a one-item list. `nodeType` absent → `'shoulder'`. `subRow` absent → derived from `row * 4`. No Firestore migration needed — additive changes only.

---

## Out of Scope

- Planogram-level row/col count changes (existing create flow unchanged)
- Product catalogue changes (no new fields on `Product`)
- Table-type planogram (`_GridView`) — only `_BayView` gets these enhancements
