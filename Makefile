PROJ=blink

all: ${PROJ}.dfu

%.json: %.v
	yosys -p "read_verilog $<; synth_ecp5 -json $@"

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --85k --package CSFBGA285 --lpf orangecrab_r0.2.pcf

%.bit: %_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

%.dfu : %.bit
	cp $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

prog: ${PROJ}.dfu
	dfu-util --alt 0 -D $(PROJ).dfu

clean:
	rm -f ${PROJ}.bit ${PROJ}_out.config ${PROJ}.json ${PROJ}.dfu

.PHONY: clean
