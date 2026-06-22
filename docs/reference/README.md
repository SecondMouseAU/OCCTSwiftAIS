---
title: API Reference
nav_order: 3
has_children: true
---

# API Reference

Every public type and member of OCCTSwiftAIS, with real signatures and a runnable example per symbol.
The package is `import OCCTSwiftAIS` and depends transitively on `OCCTSwift`, `OCCTSwiftViewport`, and
`OCCTSwiftTools`.

## Pages

- [Selection](Selection.md) — `SelectionMode`, `Selection`, `SubShape`, `InteractiveObject`,
  `RemapStrategy`.
- [InteractiveContext](InteractiveContext.md) — the per-scene state object: display, selection
  mutation, styling, dimensions, and remap.
- [Manipulators](Manipulators.md) — `ManipulatorWidget` (translate / rotate gizmo) and its SwiftUI
  `.attachManipulator(_:)` modifier.
- [Dimensions](Dimensions.md) — the `Dimension` protocol and `LinearDimension`, `AngularDimension`,
  `RadialDimension`.
- [Standard Objects](StandardObjects.md) — `Trihedron`, `WorkPlane`, `Axis`, `PointCloudPresentation`.
- [Presentation](Presentation.md) — `PresentationStyle`, `DisplayMode`, `HighlightStyle`.
