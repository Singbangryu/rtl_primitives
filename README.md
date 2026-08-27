# rtl_primitives

`rtl_primitives` is a study repository for implementing fundamental RTL building blocks from first principles.

The goal is not to collect large IP blocks, but to understand the small mechanisms that larger RTL designs repeatedly depend on: handshake rules, buffering, backpressure, arbitration, queues, state updates, and safe data movement.

Each block should eventually include:

- small synthesizable RTL,
- a short design note explaining the invariant behind the circuit,
- a block diagram when useful,
- a self-checking testbench with corner cases,
- and, when appropriate, assertions or simple formal properties.

## Current block

### 01. Ready/Valid 1-entry buffer

A one-entry elastic buffer using the ready/valid handshake.

The first implementation focuses on:

- transaction acceptance with `valid && ready`,
- downstream backpressure,
- holding valid/data during a stall,
- simultaneous pop + push,
- and sustaining one transaction per cycle once the buffer is full.

See [`docs/01_ready_valid_buffer.md`](docs/01_ready_valid_buffer.md).

## Roadmap

1. Ready/Valid 1-entry buffer
2. Ready/Valid pipeline stage
3. Skid buffer / registered backpressure
4. Synchronous FIFO
5. Fixed-priority arbiter
6. Round-robin arbiter
7. Counters, pulse generators, and edge detectors
8. Width conversion / serializer / deserializer
9. Basic CDC primitives

The order may change as the study progresses. The emphasis is on understanding why each block works before treating it as a reusable primitive.

## Repository layout

```text
rtl_primitives/
├── README.md
├── rtl/
│   └── handshake/
│       └── rv_buffer.v
└── docs/
    ├── 01_ready_valid_buffer.md
    └── assets/
        └── rv_buffer_block.png
```
