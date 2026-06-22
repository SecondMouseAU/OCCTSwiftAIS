---
title: Selection
parent: API Reference
---

# Selection

The selection model: `InteractiveObject` (an erased scene handle), `SubShape` (a body or one of its
TopoDS sub-shapes), `SelectionMode` (what kinds of pick count), `Selection` (a snapshot of picked
sub-shapes), and `RemapStrategy` (how `remap` handles unmentioned nodes).

## Topics

- [SelectionMode](#selectionmode) · [InteractiveObject](#interactiveobject) · [SubShape](#subshape) · [Selection](#selection) · [RemapStrategy](#remapstrategy)

---

## SelectionMode

Categories of sub-shape that can be selected. Used as a `Set<SelectionMode>` on
`InteractiveContext.selectionMode`.

```swift
public enum SelectionMode: Hashable, Sendable {
    case body
    case face
    case edge
    case vertex
}
```

- **Example:**

```swift
ais.selectionMode = [.face, .edge]   // face and edge picks both produce a selection
```

---

## InteractiveObject

An erased reference to something currently displayed in an `InteractiveContext`. Equality and hashing
are by `id` only — two `InteractiveObject`s with the same id refer to the same logical scene entry
even if their `Shape` was rebuilt.

```swift
public struct InteractiveObject: Hashable, Sendable {
    public let id: UUID
    public let shape: Shape

    public init(id: UUID = UUID(), shape: Shape)
}
```

- **Parameters:** `id` — stable identity (defaults to a fresh UUID); `shape` — the source OCCTSwift `Shape`.
- **Example:** you usually get one back from `InteractiveContext.display(_:)` rather than constructing it:

```swift
let part: InteractiveObject = ais.display(Shape.box(width: 4, height: 4, depth: 4)!)
print(part.shape.faceCount)
```

---

## SubShape

A specific TopoDS sub-shape inside a displayed `InteractiveObject`, or the whole body. Sub-shape
indices are valid only while the underlying `Shape` is unchanged.

```swift
public enum SubShape: Hashable, Sendable {
    case body(InteractiveObject)
    case face(InteractiveObject, faceIndex: Int)
    case edge(InteractiveObject, edgeIndex: Int)
    case vertex(InteractiveObject, vertexIndex: Int)

    public var object: InteractiveObject { get }
}
```

- **`object`:** the `InteractiveObject` this sub-shape belongs to, regardless of case.
- **Example:**

```swift
let face = SubShape.face(part, faceIndex: 0)
ais.select(face)
print(face.object.id)   // the owning InteractiveObject
```

---

## Selection

An immutable snapshot of selected sub-shapes, with derived accessors that resolve each entry back to
OCCTSwift handles.

```swift
public struct Selection: Hashable, Sendable {
    public let subshapes: Set<SubShape>
    public init(_ subshapes: Set<SubShape> = [])

    public var isEmpty: Bool { get }
    public var count: Int { get }

    public var bodies: Set<InteractiveObject> { get }
    public var faces: [Face] { get }
    public var edges: [Edge] { get }
    public var vertices: [SIMD3<Double>] { get }
}
```

- **`bodies`:** the distinct interactive objects represented in this selection.
- **`faces` / `edges`:** concrete OCCTSwift `Face` / `Edge` handles for any `.face(...)` / `.edge(...)`
  entries; order unspecified. Entries whose index no longer resolves on the source `Shape` are omitted.
- **`vertices`:** world-space `SIMD3<Double>` positions for any `.vertex(...)` entries (OCCTSwift
  exposes vertices positionally, not as a `Vertex` class).
- **Example:**

```swift
let sel = ais.selection
print("\(sel.count) selected,  \(sel.bodies.count) bodies")
for face in sel.faces { print("area:", face.area()) }
for p in sel.vertices { print("vertex:", p) }
```

---

## RemapStrategy

How `InteractiveContext.remap` handles sub-shapes whose original node has no derivatives in the
post-mutation `TopologyGraph`.

```swift
public enum RemapStrategy: Sendable {
    case dropMissing
    case keepUnchanged
}
```

- **`.dropMissing`:** drop the sub-shape. Correct for deletions, conservative for unmentioned nodes.
  The default for `remap`.
- **`.keepUnchanged`:** keep the original index. Correct for unmentioned-but-unchanged nodes,
  **incorrect** for explicitly-deleted ones — use only when you know the operation deleted nothing
  (attribute-only edits, in-place transforms).
- **Example:**

```swift
let remapped = ais.remap(ais.selection, using: graph,
                         rebindingTo: newObj, strategy: .keepUnchanged)
```
