

# BGA Escape Topology Rules

## 1. Purpose

The topology planner determines the logical escape strategy for each pad.

The topology planner does not generate:
- coordinates
- cline geometry
- nodes
- endpoints
- database objects

The topology planner produces an ordered list of routing operations which the compiler resolves into physical geometry.

Flow:

```
Pad Context
    |
    v
Breakout Strategy Selection
    |
    v
Channel Selection
    |
    v
Escape Operation Plan
    |
    v
Geometry Compiler
```

---

# 2. Escape Plan Structure

Every pad produces an ordered escape plan.

Example:

```
PAD
 |
NECK
 |
JOG
 |
ESCAPE
 |
JOG
 |
ESCAPE
```

Rules:

- Every pad has exactly one neck.
- A neck always exists, even if its length is zero.
- A pad may contain zero or more jog operations.
- A pad may contain one or more escape operations.
- The final operation must always be an escape.
- The complete operation sequence must form a continuous copper path.
- The compiled result must not violate clearance rules.

---

# 3. Routing Channels

## Definition

A channel is the geometric routing corridor available between obstacles.

For the initial BGA implementation, channels are defined between adjacent BGA pads.

Future channel definitions may include:
- via-to-via corridors
- layer transition corridors
- mixed pad/via channels

## Initial Channel Types

Only orthogonal channels are considered initially:

```
        NORTH
          |
          |
WEST ---- PAD ---- EAST
          |
          |
        SOUTH
```

The initial planner considers:

- North channel
- South channel
- East channel
- West channel

Diagonal channels are not initially considered.

## Valid Channel

A channel is valid when:

1. The channel is empty.

Meaning:
- no pad obstruction
- no via obstruction
- no existing routing obstruction

2. The planned escape can fit within the channel.

3. The resulting route does not violate clearance requirements.

Clearance must be checked against:
- pads
- vias
- neck segments
- jog segments
- escape segments

---

# 4. Segment Types

The topology planner has three primary segment types:

- NECK
- JOG
- ESCAPE

---

# 5. Neck Segment

## Purpose

The neck is the initial breakout from a pad.

Purpose:

> Move away from the pad according to the selected breakout topology.

## Rules

### Creation

Every pad must generate exactly one neck.

A neck may have:

```
length = 0
```

but still exists as the defined starting operation.

### Origin

A neck always starts from:

```
PAD
```

### Direction

The neck direction is determined by the selected breakout topology.

Examples:

Nearest edge:

```
      |
      |
     PAD
```

Quadrant:

```
\
 \
  PAD
```

### Behaviour

A neck may directly enter an escape channel:

```
PAD
 |
NECK
 |
ESCAPE
```

A neck may also perform a channel transition:

```
PAD
 |
NECK
  \
   \
    ESCAPE
```

In this case the neck behaves as the transition segment. A separate jog is not required.

### Connectivity

Valid:

```
PAD -> NECK -> ESCAPE
PAD -> NECK -> JOG
PAD -> NECK -> VIA
```

Future.

Invalid:

```
ESCAPE -> NECK
JOG -> NECK
```

---

# 6. Jog Segment

## Purpose

A jog is a channel transition operation.

Purpose:

> Move a route from its current routing channel into an adjacent valid routing channel.

## Rules

A jog:

- cannot originate from a pad.
- must connect to an existing route.
- must terminate at a channel entry point.
- must connect two valid routing states.

## Connectivity

Valid:

```
NECK
 |
JOG
 |
ESCAPE
```

```
ESCAPE
 |
JOG
 |
ESCAPE
```

Multiple transitions are allowed.

## Restrictions

A jog:

- cannot be the first segment.
- cannot be the final segment.
- cannot exist without a valid destination channel.

---

# 7. Escape Segment

## Purpose

An escape segment propagates through a routing channel.

Purpose:

> Continue routing while remaining inside a valid channel.

## Rules

An escape:

- must be contained within a valid channel.
- must maintain channel clearance.
- cannot directly start from a pad.
- must not intersect existing routing.

## Connectivity

Valid:

```
NECK -> ESCAPE
JOG -> ESCAPE
ESCAPE -> ESCAPE
```

## Initial Limitations

For the first implementation:

- escapes are orthogonal only.
- escapes follow the selected channel direction.
- escapes maintain constant width.

Future:

- diagonal channels
- curved transitions
- length optimisation

---

# 8. Via Operations (Future)

A via is a topology operation that changes routing layer.

Example:

```
PAD
 |
NECK
 |
VIA
 |
ESCAPE
```

A via may terminate an escape on one layer and begin a new channel on another layer.

Layer transition rules will be defined separately.

---

# 9. Operation Planning Rules

The topology planner determines:

1. Breakout direction
2. Available channels
3. Preferred channel
4. Required transitions
5. Ordered segment sequence

The topology planner does not determine:

- exact coordinates
- segment endpoints
- cline vertices
- database IDs

---

# 10. Design Principle

The topology layer answers:

> What routing intent is required?

The compiler answers:

> How do we physically draw it?