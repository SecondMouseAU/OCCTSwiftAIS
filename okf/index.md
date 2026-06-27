---
type: repo
title: OCCTSwiftAIS
resource: https://github.com/SecondMouseAU/OCCTSwiftAIS
tags: [cad, occt, ais, selection, manipulator, dimension, swift, kernel]
description: High-level Application Interactive Services — selection, manipulators, and dimensions over the OCCTSwift Metal stack.
timestamp: 2026-06-22
---

# OCCTSwiftAIS

> High-level **Application Interactive Services** for the OCCTSwift / OCCTSwiftViewport stack:
> selection-from-topology, manipulator widgets, dimension annotations, and standard scene objects,
> in pure Swift. It adds the scene-management semantics an OCCT-style API expects as a thin layer
> on top of OCCTSwiftViewport's native Metal renderer (it is **not** a port of OCCT's TKV3d/TKOpenGl).

## Role in the ecosystem

- **Cluster:** kernel
- **Depends on:** [OCCTSwiftTools](https://github.com/SecondMouseAU/OCCTSwiftTools) — the Shape ↔ ViewportBody bridge, which transitively brings in [OCCTSwift](https://github.com/SecondMouseAU/OCCTSwift) (B-Rep kernel) and [OCCTSwiftViewport](https://github.com/SecondMouseAU/OCCTSwiftViewport) (Metal renderer).
- **Feeds:** higher CAD layers and products — the shared interface paradigm (OCCTSwiftUX), CAD viewport kits (OCCTSwiftCADKit), and headless tooling (OCCTSwiftScripts) all build on its interactive surface.

## Components

See [`components/`](components/index.md) for the public surface.

## References

See [`references/`](references/index.md) for docs, the Swift Package Index page, and OpenCASCADE upstream.

## Policies

- [Query `context` first for OCCT / OCCTSwift docs](policies/context-first.md)
- [Documentation updates are mandatory](policies/docs-current.md)
