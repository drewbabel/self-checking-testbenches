#!/usr/bin/env bash
# Synthesize a module for the Basys 3 (Xilinx 7-series, xc7a35t) and report resource usage.
# Usage: ./synth_stats.sh <file.sv> <top_module>
# fmax is NOT reported here: it needs place-and-route timing (nextpnr/Vivado).
set -e
FILE="$1"; TOP="$2"
echo "$TOP (synth_xilinx, 7-series):"
yosys -p "read_verilog -sv $FILE; synth_xilinx -top $TOP; stat" 2>/dev/null \
| awk '
    /^=== /                                { lut=0; ff=0; carry=0; io=0 }  # reset each stat block; keep only the last
    /^[[:space:]]+[0-9]+[[:space:]]+LUT/   { lut  += $1 }
    /^[[:space:]]+[0-9]+[[:space:]]+FD/    { ff   += $1 }
    /^[[:space:]]+[0-9]+[[:space:]]+CARRY/ { carry+= $1 }
    /^[[:space:]]+[0-9]+[[:space:]]+(I|O)BUF/ { io += $1 }
    END {
      printf "  LUTs:        %d\n", lut+0
      printf "  Flip-flops:  %d\n", ff+0
      printf "  Carry cells: %d\n", carry+0
      printf "  I/O buffers: %d\n", io+0
    }'
