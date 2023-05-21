TARGET          = pantalla_degrade
IVERILOG        = iverilog
RAM 			= ram
SRC             = \
     $(TARGET).v  \
	   $(RAM)/ram.v $(RAM)/Decoder_3to7.v\

	 

SIM_SRC = $(TARGET)_TB.v   \
		
all: $(TARGET).bit

iversim: 
	$(IVERILOG) -gno-io-range-error -o $(TARGET)_TB.vvp $(VINCDIR) $(SRC) $(SIM_SRC) -s $(TARGET)_TB
	vvp $(TARGET)_TB.vvp; 
	gtkwave $(TARGET)_TB.vcd&
#
# Synthesis
#

$(TARGET).json: $(SRC)
	yosys -q -p "synth_ice40 -json $(TARGET).json" ${SRC}


$(TARGET)_out.config: $(TARGET).json
	nextpnr-ice40 --freq 25 --hx8k --package tq144:4k --json $(TARGET).json --pcf $(TARGET).pcf --asc $(TARGET).asc --opt-timing --placer heap

$(TARGET).bit: $(TARGET)_out.config
	icepack $(TARGET).asc $(TARGET).bin


${TARGET}.svf : ${TARGET}.bit

svg: $(SRC)
	yosys -p "prep -top ${TARGET}; write_json ${TARGET}.json" ${SRC}
	netlistsvg ${TARGET}.json -o ${TARGET}.svg  #--skin default.svg

.PHONY: upload
upload:
	stty -F /dev/ttyACM0 raw
	cat  ${TARGET}.bin >/dev/ttyACM0

.PHONY: clean
clean:
	rm -rf *~ */*~ a.out *.log *.key *.edf *.json *.config *.vvp  *.svg *rpt
	rm -rf *.bit *.bin *.asc 
cleansim:
	rm -rf *.vcd *.vvp 

#clean:
#	$(RM) -f chip.blif chip.txt chip.ex chip.bin
