---
title: Cookbook
nav_order: 2
has_children: true
---

# OCCTSwiftAIS Cookbook

Task-oriented, **example-rich** recipes for the OCCTSwiftAIS interactive-services layer — one page
per task, each a short bit of prose followed by runnable Swift snippets using the real current API.

## Conventions

- **Every example is runnable Swift** in a ```` ```swift ```` block, against the shipped public API.
  Fallible OCCTSwift factories return optionals — examples unwrap with `guard` / `if let`.
- `import OCCTSwiftAIS` (plus `OCCTSwift` / `OCCTSwiftViewport` / `SwiftUI` where shown).
- The full layered architecture is OCCTSwift / OCCTSwiftViewport (kernels) → OCCTSwiftTools (bridge)
  → **OCCTSwiftAIS** (this package). All examples assume an `InteractiveContext` over a
  `ViewportController`.

## Recipes

- [Selecting sub-shapes](selecting-subshapes.md) — `selectionMode`, `Selection`, the derived
  face / edge / vertex accessors, and remapping a selection across a `Shape` mutation.
- [Transform manipulators](manipulators.md) — install a translate / rotate `ManipulatorWidget`, drive
  it manually, or wire the SwiftUI `.attachManipulator(_:)` modifier.
- [Dimensions](dimensions.md) — `LinearDimension`, `AngularDimension`, `RadialDimension`, and the
  optional `WorkPlane` projection.
- [Standard objects](standard-objects.md) — `Trihedron`, `WorkPlane`, `Axis`, `PointCloudPresentation`.
- [Presentation styling](presentation-styling.md) — `PresentationStyle`, `DisplayMode`,
  `HighlightStyle`, and the built-in presets.
