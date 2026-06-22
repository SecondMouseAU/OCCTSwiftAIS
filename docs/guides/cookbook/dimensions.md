---
title: Dimensions
parent: Cookbook
nav_order: 3
---

# Dimensions

A `Dimension` is a labeled measurement anchored on `SubShape`s. AIS owns the topology-aware anchor
resolution (sub-shape → world point) and pushes a `ViewportMeasurement` into `viewport.measurements`,
where OCCTSwiftViewport's `MeasurementOverlay` draws leader lines and a billboarded label.

Add a dimension with `InteractiveContext.add(_:)`; remove it with `remove(_:)`.

## Linear dimension

`LinearDimension(from:to:plane:customLabel:id:)` measures the straight-line distance between two
anchors. The optional `plane: WorkPlane?` projects both anchors onto the plane first, giving an
in-plane length.

```swift
import OCCTSwift
import OCCTSwiftAIS

let ais = InteractiveContext(viewport: ViewportController())
let part = ais.display(Shape.box(width: 10, height: 5, depth: 3)!)

let lin = LinearDimension(
    from: .vertex(part, vertexIndex: 0),
    to:   .vertex(part, vertexIndex: 6)
)
ais.add(lin)
print(lin.distance)   // raw Float
print(lin.label)      // formatted, e.g. "11.6"
```

In-plane variant:

```swift
let plane = WorkPlane(origin: .zero, normal: SIMD3<Float>(0, 0, 1))
let inPlane = LinearDimension(from: .vertex(part, vertexIndex: 0),
                             to:   .vertex(part, vertexIndex: 6),
                             plane: plane,
                             customLabel: "datum span")
ais.add(inPlane)
```

## Angular dimension

`AngularDimension(arms:apex:customLabel:id:)` measures the angle at the apex; `arms` is a tuple of the
two arm anchors. Anchor order is `[armA, apex, armB]`.

```swift
let ang = AngularDimension(
    arms: (.vertex(part, vertexIndex: 1), .vertex(part, vertexIndex: 3)),
    apex: .vertex(part, vertexIndex: 0)
)
ais.add(ang)
print(ang.degrees)   // angle at the apex in degrees
print(ang.label)     // e.g. "90.0°"
```

## Radial dimension

`RadialDimension(circularEdge:showDiameter:customLabel:id:)` measures the radius (or diameter, when
`showDiameter` is true) of a circular edge. The `circularEdge` must be a `.edge(...)` sub-shape whose
underlying curve is circular.

```swift
let cyl = ais.display(Shape.cylinder(radius: 4, height: 8)!)
for i in 0..<cyl.shape.edgeCount {
    if let edge = cyl.shape.edge(at: i), edge.isCircle {
        let rad = RadialDimension(circularEdge: .edge(cyl, edgeIndex: i), showDiameter: false)
        ais.add(rad)
        print(rad.radius)   // 4.0
        print(rad.label)    // "R4.00"  (⌀ + diameter when showDiameter: true)
        break
    }
}
```

## Refreshing and removing

If the underlying anchors moved (you mutated a `Shape`), re-evaluate the measurement in place:

```swift
ais.refreshDimensionMeasurement(lin)   // re-fetches anchorPoints, replaces in viewport.measurements
```

`ais.remove(lin)` drops a single dimension. `ais.dimensions` lists every dimension currently in the
context. `ais.removeAll()` clears every body, selection, and dimension at once.

### Anchor resolution

| `SubShape` | World anchor |
| --- | --- |
| `.body(_)` | bbox center of `Shape.bounds` |
| `.face(_, idx)` | bbox center of `Face.bounds` |
| `.edge(_, idx)` | midpoint of `Edge.endpoints` |
| `.vertex(_, idx)` | `Shape.vertex(at: idx)` |

A `RadialDimension` additionally resolves the circle's center and radius from the edge's 3D curve.
