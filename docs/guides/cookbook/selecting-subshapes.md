---
title: Selecting sub-shapes
parent: Cookbook
nav_order: 1
---

# Selecting sub-shapes

`InteractiveContext` turns GPU picks into typed `SubShape` selections. You choose which kinds of
pick count via `selectionMode`, observe the result via the `@Published` `selection`, and read back
concrete OCCTSwift `Face` / `Edge` handles from the `Selection`.

## Choosing what's pickable

`selectionMode` is a `Set<SelectionMode>` — any combination of `.body`, `.face`, `.edge`, `.vertex`.
Changing it clears the current selection.

```swift
import OCCTSwift
import OCCTSwiftViewport
import OCCTSwiftAIS

let ais = InteractiveContext(viewport: ViewportController())
if let part = Shape.box(width: 10, height: 5, depth: 3) {
    ais.display(part)
}
ais.selectionMode = [.face, .edge, .vertex]   // face + edge + vertex picks all count
```

## Reading the selection

A pick from the viewport **replaces** the selection with the picked sub-shape; empty-space picks
leave it untouched. The derived accessors resolve each entry back to OCCTSwift handles:

```swift
// In SwiftUI: .onChange(of: ais.selection) { _, sel in ... }
let sel = ais.selection
print("\(sel.count) sub-shapes,  \(sel.bodies.count) distinct bodies")

for face in sel.faces {            // [Face]
    print("face area:", face.area())
}
for edge in sel.edges {            // [Edge]
    print("edge length:", edge.length())
}
for p in sel.vertices {            // [SIMD3<Double>]
    print("vertex at:", p)
}
```

`Selection.faces` / `.edges` resolve via `shape.subShape(type:index:)` then wrap in `Face` / `Edge`;
entries whose index no longer resolves are silently omitted. `Selection.vertices` returns world-space
`SIMD3<Double>` coordinates (OCCTSwift exposes vertices positionally, not as a `Vertex` class).

## Programmatic, additive selection

`select(_:)` / `deselect(_:)` mutate the selection as a `Set` — adding the same `SubShape` twice is
idempotent. `clearSelection()` empties it.

```swift
let obj = ais.display(Shape.box(width: 4, height: 4, depth: 4)!)
ais.select(.face(obj, faceIndex: 0))
ais.select(.face(obj, faceIndex: 2))   // now two faces selected
ais.deselect(.face(obj, faceIndex: 0)) // back to one
ais.clearSelection()
```

## Remapping a selection across a `Shape` mutation

A `SubShape.face(_, faceIndex: 5)` only means "face 5" while the underlying `Shape` is unchanged.
After a boolean or fillet, indices renumber. `remap(_:using:rebindingTo:strategy:)` carries the
selection forward using OCCTSwift history records on a `TopologyGraph`:

```swift
let oldObj = ais.display(oldShape)
ais.select(.face(oldObj, faceIndex: 0))

// Build a TopologyGraph from the post-mutation shape, with history recorded:
let graph = TopologyGraph(shape: newShape, parallel: false)!
graph.isHistoryEnabled = true

ais.remove(oldObj)
let newObj = ais.display(newShape)

let remapped = ais.remap(ais.selection, using: graph,
                         rebindingTo: newObj, strategy: .dropMissing)
ais.clearSelection()
for sub in remapped.subshapes { ais.select(sub) }
```

`.dropMissing` (the default) drops sub-shapes the history doesn't mention; `.keepUnchanged` keeps
their original index — only safe when the operation didn't shift ordering. A `1 → N` split (an edge
divided by a fillet) automatically expands into N entries; `.body(_)` always rebinds to `newObject`.
