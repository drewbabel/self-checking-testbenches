# self-checking-testbenches

[![CI](https://github.com/drewbabel/self-checking-testbenches/actions/workflows/ci.yml/badge.svg)](https://github.com/drewbabel/self-checking-testbenches/actions/workflows/ci.yml)

A set of small RTL modules, each with a self-checking testbench. Every testbench runs an independent reference model alongside the design, compares the two on every clock, and fails the build if they  disagree. CI runs all of them on each push.

## Modules

| Module | Description | Verification |
|--------|-------------|--------------|
| `tff` | A T flip-flop that toggles on enable | Self-checking testbench |
| `count_clock` | A 12-hour BCD clock with seconds, minutes, hours, and AM/PM | Self-checking testbench and a formal proof |
| `fsm_hdlc` | An HDLC bit-pattern recognizer | Self-checking testbench |

The `count_clock` formal proof uses SymbiYosys to prove that its seconds digit can never hold an illegal BCD value, for any possible input.

## Synthesis cost

Resource usage when synthesized for the Basys 3 (Xilinx 7-series):

| Module | LUTs | Flip-flops | Carry cells | I/O buffers |
|--------|------|------------|-------------|-------------|
| `tff` | 0 | 1 | 0 | 4 |
| `count_clock` | 41 | 25 | 6 | 28 |
| `fsm_hdlc` | 7 | 7 | 1 | 6 |

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

The module specs come from [HDLBits](https://hdlbits.01xz.net), a great set of RTL practice problems. The implementations, testbenches, formal proof, and CI were written from scratch.
