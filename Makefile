XIL_PAR_DESIGN_CHECK_VERBOSE=1
export XIL_PAR_DESIGN_CHECK_VERBOSE

VERSION := $(shell ./DESCRIBE)

COMMON_VHDL := IDROMConst.vhd \
    atrans.vhd boutreg.vhd bufferedspi.vhd \
    PinExists.vhd CountPinsInRange.vhd d8o8.vhd dpll.vhd hostmotid.vhd \
    idrom.vhd irqlogic.vhd kubstepgenz.vhd MaxPinsPerModule.vhd \
    NumberOfModules.vhd pwmpdmgenh.vhd pwmrefh.vhd qcounterate.vhd qcountersfp.vhd \
    qcountersf.vhd simplespi8.vhd simplespix.vhd simplessi.vhd testram.vhd \
    testrom.vhd threephasepwm.vhd timestamp.vhd uartr8.vhd uartr.vhd uartx8.vhd \
    uartx.vhd ubrategen.vhd usbram.vhd usbrom.vhd watchdog.vhd wordpr.vhd \
    wordrb.vhd fixicap.vhd d16w.vhd etherhm2.vhd \
    parity.vhd decodedstrobe2.vhd \
    hostmot2.vhd

TOP_i20 := Top9030HostMot2.vhd
TOP_i22_1500 := Top9054HostMot2.vhd
TOP_i22_1000 := Top9054HostMot2.vhd
TOP_i23 := Top9054HostMot2.vhd
TOP_i43_200 := TopEPPHostMot2.vhd
TOP_i43_400 := TopEPPHostMot2.vhd
TOP_i65 := Top9030HostMot2.vhd
TOP_i68 := Top9054HostMot2.vhd
TOP_x20_1000 := Top9054HostMot2.vhd
TOP_x20_1500 := Top9054HostMot2.vhd
TOP_x20_2000 := Top9054HostMot2.vhd
TOP_i24 := TopPCIHostMot2.vhd
TOP_i25 := TopPCIHostMot2.vhd

.PHONY: dist dist-src dist-src-force dist-bin dist-bin-force default clean bitfiles pinfiles
default: bitfiles pinfiles

dist-force: dist-src-force dist-bin-force
ifneq ($(filter %-dirty,$(VERSION)),)
dist:
	$(error Use make dist-force to make a distribution from a dirty tree)
dist-src:
ifeq ($(wildcard .git),)
	$(error Use a git repository to make dist-src or dist-src-force)
endif
	$(error Use make dist-src-force to make a distribution from a dirty tree)
dist-src-force:
ifeq ($(wildcard .git),)
	$(error Use a git repository to make dist-src or dist-src-force)
endif
	@mkdir -p dist
	(git archive --format=tar --prefix=hostmot2-firmware-$(VERSION)/ $(shell git stash create) | \
		./mkvertar.py hostmot2-firmware-$(VERSION)/ $(VERSION) ) \
		| gzip -9 > dist/hostmot2-firmware-$(VERSION).tar.gz
dist-bin:
	$(error Use make dist-bin-force to make a distribution from a dirty tree)
else
dist: dist-force
dist-src: dist-src-force
ifeq ($(wildcard .git),)
	$(error Use a git repository to make dist-src or dist-src-force)
endif
dist-src-force:
ifeq ($(wildcard .git),)
	$(error Use a git repository to make dist-src or dist-src-force)
endif
	@mkdir -p dist
	(git archive --format=tar --prefix=hostmot2-firmware-$(VERSION)/ HEAD | \
		./mkvertar.py hostmot2-firmware-$(VERSION)/ $(VERSION) ) \
		| gzip -9 > dist/hostmot2-firmware-$(VERSION).tar.gz
dist-bin: dist-bin-force
endif

clean:
	rm -rf fw
# No whitespace is acceptable in args to FIRMWARE_template
define FIRMWARE_template
$(1).BIT: $(TOP_$(2)) PIN_$(3).vhd $(COMMON_VHDL) build.py cards.py
	@mkdir -p $(dir $(1))
	./build.py $(2) $(3) $(1).BIT
$(1).PIN: PIN_$(3).vhd IDROMConst.vhd pinmaker.vhd.in idrom_tools.vhd pin.py
	@mkdir -p $(dir $(1))
	./pin.py $(2) $(3) pinmaker.vhd.in $(1).PIN.tmp
	mv $(1).PIN.tmp $(1).PIN
$(1).xml: PIN_$(3).vhd IDROMConst.vhd xmlrom.vhd.in idrom_tools.vhd pin.py
	@mkdir -p $(dir $(1))
	./pin.py $(2) $(3) xmlrom.vhd.in $(1).xml.tmp
	mv $(1).xml.tmp $(1).xml
bitfiles: $(1).BIT
pinfiles: $(1).PIN $(1).xml
dist/hostmot2-firmware-bin-$(4)-$(VERSION).tar.gz: $(1).BIT $(1).PIN $(1).xml
endef

define CARD_template
dist-bin-force: dist/hostmot2-firmware-bin-$(1)-$(VERSION).tar.gz
dist/hostmot2-firmware-bin-$(1)-$(VERSION).tar.gz:
	@mkdir -p $$(dir $$@)
	@rm -f $$@
	./mktar.py $$@ fw/ hostmot2-firmware-bin-$(1)-$(VERSION)/ $$^
dist-force-$(1): dist/hostmot2-firmware-bin-$(1)-$(VERSION).tar.gz
endef

FIRMWARES_TXT := $(word 1,$(wildcard firmwares-local.txt) firmwares.txt)
FIRMWARES_MK := ${FIRMWARES_TXT:.txt=.mk}
ifneq ($(FIRMWARES_TXT),firmwares.txt)
$(warning Note: Using firmwares listed in $(FIRMWARES_TXT))
endif
-include $(FIRMWARES_MK)
Makefile: $(FIRMWARES_MK)
$(FIRMWARES_MK): $(FIRMWARES_TXT) firmwares.py cards.py
	./firmwares.py $< > $(FIRMWARES_MK).tmp
	mv -f $(FIRMWARES_MK).tmp $(FIRMWARES_MK)
