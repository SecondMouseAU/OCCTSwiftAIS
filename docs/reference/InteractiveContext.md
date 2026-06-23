---
title: InteractiveContext
parent: API Reference
---

# InteractiveContext

The per-scene interactive state object — one `InteractiveContext` to one `ViewportController`. It owns
the array of `ViewportBody`s rendered by `MetalViewportView`, the current selection / hover, the
presentation styles, and the dimension registry. `@MainActor`, `ObservableObject`.

```swift
@MainActor
public final class InteractiveContext: ObservableObject {
    public init(viewport: ViewportController)
}
```

Bind it via `MetalViewportView(controller: ctx.viewport, bodies: $ctx.bodies)` when `ctx` is a
`@StateObject`.

## Topics

- [Published properties](#published-properties) · [display(_:style:)](#display_style) · [remove(_:)](#remove_) · [removeAll()](#removeall) · [Selection mutation](#selection-mutation) · [setStyle(_:for:)](#setstyle_for) · [setHighlightStyle(_:)](#sethighlightstyle_) · [add(_:)](#add_) · [remove(_:)-dimension](#remove_-dimension) · [dimensions](#dimensions) · [refreshDimensionMeasurement(_:)](#refreshdimensionmeasurement_) · [remap(_:using:rebindingTo:strategy:)](#remap_usingrebindingtostrategy)

---

## Published properties

```swift
public let viewport: ViewportController
@Published public var bodies: [ViewportBody]
@Published public var selectionMode: Set<SelectionMode>          // default [.body]
@Published public private(set) var selection: Selection
@Published public private(set) var hover: SubShape?
public var highlightStyle: HighlightStyle                        // default .default
```

- `bodies` — the bodies fed to `MetalViewportView`; bind via `$bodies`.
- `selectionMode` — what kinds of pick produce a selection. **Changing it clears the current
  selection.**
- `selection` — the current selection (read-only; mutate via `select` / `deselect` / `clearSelection`
  or a pick). Observable.
- `hover` — the currently hovered sub-shape (body granularity today), or `nil`.
- **Example:**

```swift
ais.selectionMode = [.face]
// SwiftUI:
// .onChange(of: ais.selection) { _, sel in ... }
```

---

## display(_:style:)

Display a shape with topology-aware selection enabled. Tessellates the `Shape`, appends a
`ViewportBody`, and registers a selectable `InteractiveObject`.

```swift
@discardableResult
public func display(_ shape: Shape, style: PresentationStyle = .default) -> InteractiveObject
```

- **Parameters:** `shape` — the OCCTSwift `Shape`; `style` — initial presentation style.
- **Returns:** the `InteractiveObject` scene handle.
- **Example:**

```swift
let part = ais.display(Shape.box(width: 10, height: 5, depth: 3)!,
                       style: .highlighted)
```

---

## remove(_:)

Remove a displayed object, its body, and any selection / hover entries that referenced it.

```swift
public func remove(_ object: InteractiveObject)
```

- **Example:**

```swift
ais.remove(part)
```

---

## removeAll()

Clear every body, selection, hover, dimension, and viewport measurement in one go.

```swift
public func removeAll()
```

- **Example:**

```swift
ais.removeAll()
```

---

## Selection mutation

Add, remove, or clear sub-shapes. `select` / `deselect` use `Set` semantics (idempotent).

```swift
public func select(_ subshape: SubShape)
public func deselect(_ subshape: SubShape)
public func clearSelection()
```

- **Example:**

```swift
ais.select(.face(part, faceIndex: 0))   // additive
ais.select(.face(part, faceIndex: 2))
ais.deselect(.face(part, faceIndex: 0))
ais.clearSelection()
```

---

## setStyle(_:for:)

Restyle a displayed object in place — updates the underlying `ViewportBody`'s color and visibility.

```swift
public func setStyle(_ style: PresentationStyle, for object: InteractiveObject)
```

- **Example:**

```swift
ais.setStyle(.ghosted, for: part)
```

---

## setHighlightStyle(_:)

Set the colors used by the highlight overlay and refresh the current selection visuals immediately.

```swift
public func setHighlightStyle(_ style: HighlightStyle)
```

- **Example:**

```swift
ais.setHighlightStyle(HighlightStyle(selectionColor: SIMD3<Float>(1, 0.65, 0)))
```

---

## add(_:)

Add a dimension to the scene. Pushes its `viewportMeasurement` to `viewport.measurements`, where the
renderer's overlay picks it up. Idempotent for the same instance (re-adding refreshes its anchors).

```swift
@discardableResult
public func add<D: Dimension>(_ dimension: D) -> D
```

- **Returns:** the same dimension, for chaining.
- **Example:**

```swift
let lin = ais.add(LinearDimension(from: .vertex(part, vertexIndex: 0),
                                  to:   .vertex(part, vertexIndex: 6)))
```

---

## remove(_:)-dimension

Remove a previously-added dimension.

```swift
public func remove(_ dimension: any Dimension)
```

- **Example:**

```swift
ais.remove(lin)
```

---

## dimensions

All dimensions currently displayed in this context.

```swift
public var dimensions: [any Dimension] { get }
```

- **Example:**

```swift
print(ais.dimensions.count)
```

---

## refreshDimensionMeasurement(_:)

Re-fetch a dimension's `viewportMeasurement` and replace it in place in `viewport.measurements`. Call
after the underlying anchors moved (e.g. a target `Shape` mutated).

```swift
public func refreshDimensionMeasurement(_ dimension: any Dimension)
```

- **Example:**

```swift
ais.refreshDimensionMeasurement(lin)
```

---

## remap(_:using:rebindingTo:strategy:)

Remap a `Selection` captured against an earlier shape state to a post-mutation shape's indices, using
the history records on a `TopologyGraph` built from the post-mutation shape.

```swift
public func remap(
    _ selection: Selection,
    using graph: TopologyGraph,
    rebindingTo newObject: InteractiveObject,
    strategy: RemapStrategy = .dropMissing
) -> Selection
```

- **Parameters:** `selection` — the pre-mutation selection; `graph` — a `TopologyGraph` from the
  post-mutation shape with history recorded; `newObject` — the post-mutation scene object the result
  references; `strategy` — how to handle sub-shapes the history doesn't mention.
- **Returns:** a `Selection` against `newObject`. `1 → 1` keeps the new index, `1 → N` (e.g. a split
  edge) expands into N entries, `1 → 0` (deleted) is handled per `strategy`; `.body(_)` always rebinds.
- **Example:**

```swift
ais.remove(oldObj)
let newObj = ais.display(newShape)
let remapped = ais.remap(oldSelection, using: graph, rebindingTo: newObj)
for sub in remapped.subshapes { ais.select(sub) }
```
