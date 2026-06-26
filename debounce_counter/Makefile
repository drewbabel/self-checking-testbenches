#   make        compile + run; a test FAIL exits nonzero
#   make wave   compile + run + open waveform in surfer; opens waveform even if tests FAIL
#   make clean  delete build artifacts (sim, *.vcd)

SRCS := $(wildcard *.sv)
SIM  := sim

run: $(SRCS)
	iverilog -g2012 -o $(SIM) $(SRCS)
	vvp $(SIM)

wave: $(SRCS)
	iverilog -g2012 -o $(SIM) $(SRCS)
	-vvp $(SIM)
	surfer $$(ls *.vcd 2>/dev/null | head -1) &

clean:
	rm -f $(SIM) *.vcd

.PHONY: run wave clean
