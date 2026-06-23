---
title: Dimensions
parent: API Reference
---

# Dimensions

A `Dimension` is a labeled measurement anchored on `SubShape`s. Concrete types: `LinearDimension`,
`AngularDimension`, `RadialDimension`. Each emits a `ViewportMeasurement` consumed by
OCCTSwiftViewport's `MeasurementOverlay`. Add / remove them via `InteractiveContext.add(_:)` /
`remove(_:)`.

## Topics

- [Dimension](#dimension) · [LinearDimension](#lineardimension) · [AngularDimension](#angulardimension) · [RadialDimension](#radialdimension)

---

## Dimension

The protocol all dimension types conform to.

```swift
public protocol Dimension: AnyObject, Sendable {
    var id: String { get }
    var label: String { get }
    var anchorPoints: [SIMD3<Float>] { get }
    var viewportMeasurement: ViewportMeasurement { get }
}
```

- `id` — stable id tracked across add / remove cycles.
- `label` — human-readable text (e.g. `"5.32"`); customise via the initialiser's `customLabel`.
- `anchorPoints` — world-space anchors in the order the concrete type expects.
- `viewportMeasurement` — the renderer-overlay form.

---

## LinearDimension

Distance between two anchors. An optional `WorkPlane` projects both anchors orthogonally before
measuring, giving the in-plane length.

```swift
public final class LinearDimension: Dimension, @unchecked Sendable {
    public let id: String
    public let from: SubShape
    public let to: SubShape
    public let plane: WorkPlane?
    public var customLabel: String?

    public init(from: SubShape, to: SubShape,
                plane: WorkPlane? = nil, customLabel: String? = nil, id: String? = nil)

    public var anchorPoints: [SIMD3<Float>] { get }   // [from, to] (after optional projection)
    public var distance: Float { get }                // nan if an anchor fails to resolve
    public var label: String { get }                  // customLabel, else formatted distance
}
```

- **Parameters:** `from` / `to` — the two anchor sub-shapes; `plane` — optional projection plane;
  `customLabel` — overrides the formatted distance; `id` — defaults to a generated id.
- **Example:**

```swift
let lin = LinearDimension(from: .vertex(part, vertexIndex: 0),
                          to:   .vertex(part, vertexIndex: 6))
ais.add(lin)
print(lin.distance, lin.label)
```

---

## AngularDimension

Angle at the apex. Anchor order is `[armA, apex, armB]` (vertex in the middle).

```swift
public final class AngularDimension: Dimension, @unchecked Sendable {
    public let id: String
    public let armA: SubShape
    public let apex: SubShape
    public let armB: SubShape
    public var customLabel: String?

    public init(arms: (SubShape, SubShape), apex: SubShape,
                customLabel: String? = nil, id: String? = nil)

    public var anchorPoints: [SIMD3<Float>] { get }   // [armA, apex, armB]
    public var degrees: Float { get }                 // angle at apex; nan if an arm coincides
    public var label: String { get }                  // customLabel, else "%.1f°"
}
```

- **Parameters:** `arms` — the two arm anchors as a tuple; `apex` — the vertex anchor.
- **Example:**

```swift
let ang = AngularDimension(
    arms: (.vertex(part, vertexIndex: 1), .vertex(part, vertexIndex: 3)),
    apex: .vertex(part, vertexIndex: 0)
)
ais.add(ang)
print(ang.degrees)   // e.g. 90.0
```

---

## RadialDimension

Radius (or diameter) of a circular edge.

```swift
public final class RadialDimension: Dimension, @unchecked Sendable {
    public let id: String
    public let circularEdge: SubShape
    public var showDiameter: Bool
    public var customLabel: String?

    public init(circularEdge: SubShape, showDiameter: Bool = false,
                customLabel: String? = nil, id: String? = nil)

    public var anchorPoints: [SIMD3<Float>] { get }   // [center, pointOnEdge]
    public var radius: Float { get }                  // nan if the edge isn't circular
    public var diameter: Float { get }                // radius * 2
    public var label: String { get }                  // "R<r>" or "⌀<d>" (showDiameter)
}
```

- **Parameters:** `circularEdge` — an `.edge(...)` sub-shape with a circular 3D curve; `showDiameter`
  — label and value as diameter rather than radius.
- **Example:**

```swift
for i in 0..<cyl.shape.edgeCount where cyl.shape.edge(at: i)?.isCircle == true {
    let rad = RadialDimension(circularEdge: .edge(cyl, edgeIndex: i), showDiameter: false)
    ais.add(rad)
    print(rad.radius, rad.label)   // 4.0  "R4.00"
    break
}
```
