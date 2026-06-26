# self-checking-testbenches

[![CI](https://github.com/drewbabel/self-checking-testbenches/actions/workflows/ci.yml/badge.svg)](https://github.com/drewbabel/self-checking-testbenches/actions/workflows/ci.yml)

A set of small RTL modules, each with a self-checking testbench. Every testbench runs an independent reference model alongside the design, compares the two on every clock, and fails the build if they  disagree. CI runs all of them on each push.

## Modules

| Module | Description | Verification |
|--------|-------------|--------------|
| `tff` | A T flip-flop that toggles on enable | Self-checking testbench |
| `count_clock` | A 12-hour BCD clock with seconds, minutes, hours, and AM/PM | Self-checking testbench and a formal proof |
| `fsm_hdlc` | An HDLC bit-pattern recognizer | Self-checking testbench |
| `debounce_counter` | A pushbutton debouncer and press counter: 2-FF synchronizer, contact debounce, and edge-detect | Self-checking testbench and verified on real hardware (Basys 3) |

The `count_clock` formal proof uses SymbiYosys to prove that its seconds digit can never hold an illegal BCD value, for any possible input.

## Synthesis cost

Resource usage when synthesized for the Basys 3 (Xilinx 7-series):

| Module | LUTs | Flip-flops | Carry cells | I/O buffers |
|--------|------|------------|-------------|-------------|
| `tff` | 0 | 1 | 0 | 4 |
| `count_clock` | 41 | 25 | 6 | 28 |
| `fsm_hdlc` | 7 | 7 | 1 | 6 |
| `debounce_counter` | 8 | 44 | 10 | 19 |

## Running

Each module has a Makefile. To build and run a testbench, or to open its waveform in Surfer:

```
make -C count_clock
make -C count_clock wave
```

To run the formal proof:

```
sby -f count_clock/count_clock.sby
```

## Acknowledgements

Module specs for `count_clock`, `fsm_hdlc`, and `tff` come from [HDLBits](https://hdlbits.01xz.net), a great set of RTL practice problems; all other modules are original designs. Every implementation, testbench, the formal proof, and CI was written from scratch.
