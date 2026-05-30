Below is a concise knowledge-base Markdown file focused on the design rules, formulas, and heuristics that a BGA fanout automation tool could use.

# BGA Fanout Design Knowledge Base

## Purpose

This document captures the core geometric rules, calculations, and routing heuristics for BGA (Ball Grid Array) fanout generation.

---

# Terminology

## Ball Diameter (BD)

Diameter of the solder ball on the BGA package.

Units:

* mm
* mil

## Pitch (P)

Center-to-center spacing between adjacent BGA balls.

Typically identical in X and Y directions.

Units:

* mm
* mil

## Pad Diameter (PD)

Diameter of the PCB landing pad.

### NSMD Pads

For Non-Solder Mask Defined (NSMD) pads:

```text
PD = 0.8 × BD
```

Typical reduction:

* 20% smaller than ball diameter

Example:

```text
Ball Diameter = 0.40 mm
Pad Diameter = 0.32 mm
```

---

# Routing Layer Estimation

## Rule of Thumb

Each pair of BGA rows/columns generally requires one signal layer for breakout routing.

### Example

8×8 BGA:

```text
Rows 1-2 + Columns 1-2 → Layer 1

Rows 3-4 + Columns 3-4 → Layer 2
```

Estimated signal layers:

```text
Signal Layers ≈ ceil(Number_of_Row_Pairs)
```

Where:

```text
Number_of_Row_Pairs = Floor(Row_Count / 2)
```

This is a heuristic only and does not account for:

* Power planes
* Ground planes
* Differential pairs
* Escape optimization

---

# Outer Row Fanout

## Routing Strategy

Outer row and column pads route directly away from the package.

Characteristics:

* No vias required
* Lowest routing complexity
* Uses package perimeter

### Recommended Defaults

```text
Trace Width = 0.1 mm
Clearance = 0.1 mm
```

These values are commonly manufacturable.

---

# Between-Pad Routing

## Available Channel Width

The routing channel between adjacent pads is:

```text
Channel Width = Pitch - Pad Diameter
```

Example:

```text
Pitch = 0.80 mm
Pad Diameter = 0.32 mm

Channel Width = 0.48 mm
```

or

```text
18.9 mil
```

---

## Single Trace Fit Check

For a trace routed between two pads:

```text
Clearance =
(Channel Width - Trace Width) / 2
```

Example:

```text
Channel Width = 18.9 mil
Trace Width = 5 mil

Clearance = 6.95 mil
```

Manufacturing target:

```text
Clearance ≥ 6 mil
```

---

## Between-Pad Routing Rule

A trace may pass between two pads if:

```text
(Channel Width - Trace Width) / 2
>= Minimum_Clearance
```

Equivalent:

```text
Trace Width
<= Channel Width - 2 × Minimum_Clearance
```

---

# Inner Row Fanout

## Dog-Bone Fanout

Inner pads are escaped using:

1. Short trace from pad
2. Via placed between four adjacent pads
3. Route on another layer

Structure:

```text
Pad → Trace → Via
```

This is called a "dog-bone" fanout.

---

# Via Placement Geometry

## Diagonal Pitch Distance

For a via centered among four pads:

```text
H = sqrt(Px² + Py²)
```

For equal pitch:

```text
H = sqrt(2 × P²)
```

Example:

```text
Pitch = 0.80 mm

H = 1.13 mm
```

---

## Available Diagonal Space

Subtract one pad diameter:

```text
H' = H - Pad_Diameter
```

Example:

```text
H = 1.13 mm
PD = 0.32 mm

H' = 0.81 mm
```

or

```text
31.9 mil
```

---

# Via Fit Rule

The complete via structure must fit within H'.

Required space:

```text
Via_Total_Diameter
+ 2 × Clearance
```

Constraint:

```text
Via_Total_Diameter
+ 2 × Clearance
<= H'
```

---

## Via Total Diameter

```text
Via_Total_Diameter =
Hole_Diameter +
2 × Annular_Ring
```

Example:

```text
Hole = 8 mil
Annular Ring = 6 mil

Via Total Diameter = 20 mil
```

---

# Standard Manufacturing Assumptions

Unless overridden by fab capability:

```text
Trace Width = 5 mil
Trace Clearance = 6 mil
Annular Ring = 6 mil
```

These values should be treated as conservative defaults.

---

# Fanout Decision Flow

## Step 1

Determine:

```text
Pitch
Ball Diameter
Pad Diameter
```

For NSMD:

```text
Pad Diameter = 0.8 × Ball Diameter
```

---

## Step 2

Check outer-row escape.

Outer rows route directly outward.

---

## Step 3

Check between-pad routing.

Compute:

```text
Channel Width = Pitch - Pad Diameter
```

Verify:

```text
(Channel Width - Trace Width)/2
>= Clearance
```

---

## Step 4

For remaining pads:

Generate dog-bone fanout.

Compute:

```text
H = sqrt(Px² + Py²)
H' = H - Pad Diameter
```

Verify:

```text
Via_Total_Diameter + 2×Clearance <= H'
```

---

## Step 5

Assign escape layers.

Heuristic:

```text
One signal layer per two BGA rows/columns.
```

---

# Key Design Constraints

## Between-Pad Escape

```text
Pitch - Pad_Diameter
>= Trace_Width + 2×Clearance
```

## Dog-Bone Via Escape

```text
sqrt(Px² + Py²)
- Pad_Diameter
>= Via_Total_Diameter + 2×Clearance
```

## NSMD Pad Size

```text
Pad_Diameter = 0.8 × Ball_Diameter
```

---

# Example (0.8 mm Pitch BGA)

Inputs:

```text
Pitch = 0.80 mm
Ball Diameter = 0.40 mm
Pad Diameter = 0.32 mm
Trace Width = 5 mil
Clearance = 6 mil
```

Results:

```text
Channel Width = 0.48 mm
             = 18.9 mil

Routing Clearance = 6.95 mil

Diagonal Distance H = 1.13 mm

Available Diagonal Space H' = 0.81 mm
                            = 31.9 mil
```

Outcome:

* Outer rows route directly.
* Second rows can route between pads.
* Inner rows require dog-bone fanout and additional signal layers.
* Standard 5/6 mil design rules are sufficient.

```
```
