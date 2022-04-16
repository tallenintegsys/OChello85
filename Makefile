PROJ=blink

# We don't actually need to do anything to verilog files.
# This explicitly empty recipe is merely referenced from
# the %.ys recipe below. Since it depends on those files,
# make will check them for modifications to know if it needs to rebuild.
%.v: ;
# Build the yosys script.
# This recipe depends on the actual verilog files (defined in $(VERILOG_FILES))
# Also, this recipe will generate the whole script as an intermediate file.
# The script will call read_verilog for each file listed in $(VERILOG_FILES),
# Then, the script will execute synth_ecp5, looking for the top module named $(TOP_MODULE)
# Lastly, it will write the json output for nextpnr-ecp5 to use as input.
TOP_MODULE=top
VERILOG_FILES=$(wildcard *.sv)
%.ys: $(VERILOG_FILES)
	$(file >$@)
	$(foreach V,$(VERILOG_FILES),$(file >>$@,read_verilog -sv $V))
		$(file >>$@,synth_ecp5 -top $(TOP_MODULE)) \
		$(file >>$@,write_json "$(basename $@).json") \

all: ${PROJ}.dfu

%.json: %.ys
	yosys -s "$<"

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
