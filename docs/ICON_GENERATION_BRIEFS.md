# BlenderUI toolbar icon generation briefs

Updated 2026-08-03. This is the stable, action-oriented prompt catalog for
the shared `BlenderToolDefinition` shelves. It is intentionally separate from
the runtime renderer: small application icons must remain editable, scalable,
theme-tintable vectors. A generator may be used to explore a silhouette, then
the accepted result should be redrawn as a `BlenderGlyph` vector rather than
shipped as a bitmap.

## Common prompt prefix

Prepend this text to every item brief below:

> Create exactly one application toolbar icon for a dark professional 3D
> creation tool. Center it in a square 64 by 64 artboard with at least 8 px of
> empty padding. Use a single off-white stroke and a restrained single muted
> accent only where it communicates the active action. Flat vector-like
> geometry, consistent 5 px stroke, rounded caps and joins, simple strong
> silhouette, legible at 16 px and 32 px. No text, letters, numbers, gradient,
> drop shadow, UI button background, photographic rendering, watermark, or
> brand logo. Match the compact visual language of desktop 3D-editor tools
> without copying any proprietary icon artwork.

## Viewport and selection shelf

| Action | Add this precise subject brief after the common prefix |
| --- | --- |
| Select / Tweak | `A white arrow cursor inside an incomplete dashed square selection boundary; arrow points up-right.` |
| Box Select | `A dashed rectangular marquee with four square corner gaps; no cursor.` |
| Circle Select | `A thin circular marquee with a small centered plus sign.` |
| Lasso Select | `A loose angular dashed lasso loop with a small arrow cursor at its open end.` |
| 3D Cursor | `A circular red-and-white crosshair target, one fine horizontal and vertical axis, clean concentric ring.` |
| Move | `Four white arrows radiating up, down, left, and right from a compact central square.` |
| Rotate | `A circular orbit arrow around a central diamond, two opposing arrowheads.` |
| Scale | `Two diagonal corner squares connected by a diagonal arrow expanding outwards.` |
| Transform | `A central square with small square handles at all four corners and a surrounding transform frame.` |
| Annotate | `A diagonal pencil drawing one short mint-green curved line.` |
| Measure | `A vertical ruler paired with a right-angle measuring baseline, evenly spaced ticks.` |
| Add Cube | `A mint-green wireframe cube with a small plus in its upper-left corner.` |

## Node, Image, UV, and paint shelves

| Action | Add this precise subject brief after the common prefix |
| --- | --- |
| Move View | `A compact hand/pan mark with four tiny directional arrows around it.` |
| Cut Links | `Two node sockets joined by a diagonal wire, with a clean diagonal cutting slash through the wire.` |
| Mute Links | `Two node sockets joined by a wire with a small crossed-out eye overlay.` |
| Add Node | `A small rounded node block with one input and one output socket plus a small plus sign.` |
| Sample / Eyedropper | `A diagonal eyedropper with one clean droplet at its tip.` |
| Rip Region | `A rectangular mesh patch split by a jagged tear line, halves subtly separating.` |
| Grab | `A simple grasping hand pulling a small square point.` |
| Relax | `Three wavy horizontal mesh lines easing toward a centered smooth line.` |
| Pinch | `Two arrows pushing opposing sides of a square mesh toward its center.` |
| Brush | `A diagonal paint brush with one short curved paint stroke.` |
| Blur | `Three concentric soft-edged rings simplified as thin nested circles.` |
| Smear | `A short brush dragging three tapering parallel strokes to the right.` |
| Clone | `Two overlapping stamped circles, the rear one offset down-left.` |

## Grease Pencil shelf

| Action | Add this precise subject brief after the common prefix |
| --- | --- |
| Draw | `A diagonal pencil leaving a single confident curved ink stroke.` |
| Erase | `A tilted rectangular eraser removing the end of a curved ink stroke; tiny clean break in the line.` |
| Fill | `A tipped paint bucket pouring one small accent-colored drop into an outlined shape.` |
| Tint | `An eyedropper over a small palette swatch, one muted accent droplet.` |
| Primitives | `A small plus beside a square and circle outline, both equal visual weight.` |
| Box primitive | `A simple square outline with four subtly emphasized corners.` |
| Circle primitive | `A single perfect circle outline with a tiny center point.` |
| Line primitive | `A straight diagonal line with round endpoint handles.` |
| Polyline primitive | `Three straight connected segments with round vertex handles.` |
| Arc primitive | `A smooth quarter-circle arc with endpoint handles.` |
| Curve primitive | `A Bézier curve with two control handles and a smooth S-shaped segment.` |
| Interpolate | `Two offset key dots with a smooth curved arrow transitioning from the first to the second.` |
| Trim | `A short ink stroke with a scissor-like cut mark near one end.` |

## View-menu and editor-context icons

| Command | Add this precise subject brief after the common prefix |
| --- | --- |
| Toolbar | `A narrow vertical rail with three evenly stacked tool marks.` |
| Sidebar / Region UI | `A right-side panel divided into three compact horizontal controls.` |
| Tool Header | `A thin horizontal header strip containing three tiny control marks.` |
| Asset Shelf | `A shallow tray containing three small asset tiles.` |
| HUD | `A small floating information panel with an “i” symbol represented as dot and stem only.` |
| Channels | `Three staggered horizontal hierarchy rows with small leading dots.` |
| Camera / Viewpoint | `A compact movie camera silhouette with a circular lens and one view cone.` |
| Navigation | `A hand/pan glyph with four surrounding direction arrows.` |
| Align View | `A square view frame snapping onto a vertical and horizontal axis cross.` |
| Frame Selected | `A dashed focus rectangle tightly surrounding one solid square.` |
| Frame All / View All | `A four-by-four grid contained by a single framing rectangle.` |
| Local View | `An eye outline with one isolated solid square in its center.` |
| View Regions / Area | `A window rectangle divided into two editor regions by one vertical splitter.` |
| Playback | `A right-facing triangular play mark beside two tiny timeline ticks.` |

## CWords puzzle-type icons

Use the exact same common prompt prefix, palette, stroke, and exclusions for
this set. These glyphs are intentionally geometry-only: letters and digits
make an icon set locale-specific and unreadable at toolbar scale.

| Puzzle type | Add this precise subject brief after the common prefix |
| --- | --- |
| Arroword / Çengel bulmaca | `A compact crossword grid with several clue cells containing small directional arrows pointing into adjacent answer cells.` |
| WPCW crossword | `A traditional symmetrical blocked crossword grid with one clearly highlighted crossing intersection.` |
| Sudoku | `Nine small square regions arranged in a clean three-by-three Sudoku grid; use no digits.` |
| Samurai Sudoku / 5li Sudoku | `Five overlapping Sudoku grid clusters: one central grid and four corner grids, simplified for 16-pixel recognition.` |
| Number Hunt / Rakam bulmaca | `A rectangular grid with circular targets connected by one continuous searching path; use no numerals.` |
| Letter Hunt / Harf bulmaca | `A square grid with selected cells connected by a diagonal search line; use no letters.` |
| Jigsaw Crossword / Mozaik bulmaca | `A crossword grid divided by bold irregular jigsaw-piece boundaries with one clear interlocking tab and socket.` |
| Chain of Words / Zincir bulmaca | `Three compact word-slot blocks linked end-to-end with curved chain links; use no text.` |
| Surplus Words / Artan sözcük bulmaca | `Four word-slot bars with one detached extra tile marked by a subtle muted-red removal cross; use no text.` |
| Nonogram | `A square pixel grid whose filled cells form one simple pixel-art shape, with tiny clue bars on top and left but no digits.` |
| Idiomogram / Deyimogram | `Two simple pictogram fragments joined by a curved connector, suggesting a visual phrase assembled from clues.` |
| Spiral Crossword / Sarmal bulmaca | `A square spiral made from connected crossword-style cells curling inward to one centre cell.` |
| Honeycomb Crossword / Petek bulmaca | `A compact honeycomb of six-sided cells with a highlighted central hexagon and crossing entry directions.` |
| Kakuro | `A cross-sums grid with dark diagonally split clue cells and adjacent light answer cells; use no numbers.` |
| Slitherlink / Çit bulmaca | `A rectangular dot grid with one clean closed loop travelling around selected cells.` |
| Hashi / Köprü bulmaca | `Several circular islands joined by one and two straight bridge lines; use no numbers.` |
| Ciphered Crossword / Şifreli bulmaca | `A blocked crossword grid with abstract code-token dots in several cells and a small key-like cipher motif; use no letters or digits.` |

## Consolidated generation sequence

Do not ask an image model to make all 69 glyphs in one image. That usually
causes duplicated, omitted, or merged cells. Reuse the common prompt exactly
and generate three compatible sheets in this order:

1. Viewport, Node/Image/UV, and Grease Pencil shelves: 38 icons in a 2x19
   grid.
2. View-menu/editor-context commands: 14 icons in a 2x7 grid.
3. CWords puzzle types: 17 icons in a 1x17 grid.

For every sheet: request transparent background, equal square cells, no
labels, and the ordered actions from the matching table. Keep a single seed,
model, palette, and common prefix across all three sheets. Redraw accepted
results as vector `BlenderGlyph` artwork before runtime use.

## Acceptance checks

- Test monochrome rendering at 16 px and 32 px before adding a glyph.
- A selected toolbar item provides the blue button background; do not bake a
  background into the icon.
- Do not encode labels or shortcuts in the artwork.
- Keep semantic names stable in `BlenderGlyph`; applications should consume
  those names, never an asset filename.
