# 01. Ready/Valid 1-entry Buffer

## Goal

Implement a one-entry buffer while learning the ready/valid handshake as a protocol invariant rather than as a memorized RTL pattern.

![Ready/Valid buffer block diagram](docs/images/rv_buffer_block.PNG)

The block diagram is intentionally conceptual. Signal names in the drawing are not meant to be the final RTL port naming convention.

## Handshake rule

A transaction is completed only on a clock edge where both `valid` and `ready` are high.

Inside the buffer, it is convenient to give those conditions names:

```verilog
input_fire  = in_valid_i  && in_ready_o;
output_fire = out_valid_o && out_ready_i;
```

`input_fire` and `output_fire` are internal derived events. They do not add new signals to the ready/valid protocol.

## Internal state

A one-entry buffer only needs two pieces of state:

- `buffer_r`: the stored data item
- `valid_r`: whether the stored item is currently valid

`valid_r = 0` means the entry is empty, and `valid_r = 1` means it is occupied.

## Input ready condition

The buffer can accept a new item when either:

1. it is currently empty, or
2. the current item is being accepted by the consumer in the same cycle.

Therefore:

```verilog
in_ready_o = ~valid_r || out_ready_i;
```

The second term allows simultaneous pop + push and therefore permits one transaction per cycle after the buffer is filled.

## Valid-state truth table

The next value of `valid_r` can be derived from the two handshake events.

| `input_fire` | `output_fire` | Meaning | Next `valid_r` |
|---:|---:|---|---|
| 0 | 0 | No transaction completes | keep current `valid_r` |
| 1 | 0 | New item enters | `1` |
| 0 | 1 | Current item leaves, no replacement | `0` |
| 1 | 1 | Current item leaves and a new item enters | `1` |

This reduces to:

```verilog
valid_next = (valid_r && !output_fire) || input_fire;
```

The two terms have a direct interpretation:

- `valid_r && !output_fire`: keep the current valid item while it has not left.
- `input_fire`: the buffer is valid after accepting a new item.

## Data-register update

The data register only changes when a new input transaction is actually accepted:

```verilog
if (input_fire)
    buffer_r <= in_data_i;
```

When `valid_r = 0`, the value stored in `buffer_r` is irrelevant, so the data register does not need to be reset for protocol correctness.

## Stall invariant

When the buffer is presenting valid data but the consumer is not ready:

```text
out_valid_o = 1
out_ready_i = 0
```

no output transaction completes. During this stall, the buffer must keep both the valid indication and the associated data stable until the consumer accepts them.

## Next verification targets

The testbench should cover at least:

1. reset and empty state,
2. push into an empty buffer,
3. output stall with stable valid/data,
4. pop without a replacement input,
5. simultaneous pop + push,
6. continuous one-item-per-cycle throughput,
7. randomized downstream backpressure with no drop, duplication, or reordering.
