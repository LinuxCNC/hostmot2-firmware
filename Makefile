ifeq ($(shell which xst 2>/dev/null),)
$(error 'xst' is not on your PATH.  Make sure that the Xilinx ISE is available)
endif

VERSION := $(shell git describe --dirty)

COMMON_VHDL := IDROMConst.vhd \
    atrans.vhd boutreg.vhd bufferedspi.vhd \
    PinExists.vhd CountPinsInRange.vhd d8o8.vhd dpll.vhd hostmotid.vhd \
    idrom.vhd irqlogic.vhd kubstepgenz.vhd MaxPinsPerModule.vhd \
    NumberOfModules.vhd pwmpdmgenh.vhd pwmrefh.vhd qcounterate.vhd qcountersfp.vhd \
    qcountersf.vhd simplespi8.vhd simplespix.vhd simplessi.vhd testram.vhd \
    testrom.vhd threephasepwm.vhd timestamp.vhd uartr8.vhd uartr.vhd uartx8.vhd \
    uartx.vhd ubrategen.vhd usbram.vhd usbrom.vhd watchdog.vhd wordpr.vhd \
    wordrb.vhd \
    hostmot2.vhd

TOP_i20 := 9030
TOP_i22_1500 := 9054
TOP_i22_1000 := 9054
TOP_i23 := 9054
TOP_i43_200 := epp
TOP_i43_400 := epp
TOP_i65 := 9030
TOP_i68 := 9054
TOP_x20_1000 := 9054
TOP_x20_1500 := 9054
TOP_x20_2000 := 9054

.PHONY: dist default clean tarfiles bitfiles pinfiles
default: tarfiles bitfiles pinfiles

dist:
ifeq ($(filter %-dirty,$(VERSION)),)
	@mkdir -p dist
	git archive --format=tar --prefix=hostmot2-firmware-$(VERSION)/ HEAD \
		| gzip -9 > dist/hostmot2-firmware-$(VERSION).tar.gz 
else
	$(error Cannot make a distribution from a dirty tree)
endif

clean:
	rm -rf fw
# No whitespace is acceptable in args to FIRMWARE_template
define FIRMWARE_template
$(1).BIT: $(TOP_$(2)).vhd.in
	@mkdir -p $(dir $(1))
	python build.py $(2) $(3) $(1).BIT
$(1).PIN: PIN_$(3).vhd IDROMConst.vhd pinmaker.vhd.in pin.py
	@mkdir -p $(dir $(1))
	python pin.py $(3) $(2) > $(1).PIN.tmp
	mv $(1).PIN.tmp $(1).PIN
bitfiles: $(1).BIT
pinfiles: $(1).PIN
dist/hostmot2-firmware-bin-$(2)-$(VERSION).tar.gz: $(1).BIT $(1).PIN
endef

define CHIP_template
tarfiles: dist/hostmot2-firmware-bin-$(1)-$(VERSION).tar.gz
dist/hostmot2-firmware-bin-$(1)-$(VERSION).tar.gz:
	@mkdir -p $$(dir $$@)
	@rm -f $$@
	python mktar.py $$@ fw/ hostmot2-firmware-bin-$(1)-$(VERSION)/ $$^
endef

-include firmwares.mk
Makefile: firmwares.mk
firmwares.mk: firmwares.py firmwares.txt
	python firmwares.py > firmwares.mk
