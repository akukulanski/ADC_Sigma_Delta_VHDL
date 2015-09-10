# The top level module should define the variables below then include
# this file.  The files listed should be in the same directory as the
# Makefile.  
#
#   variable	description
#   ----------  -------------
#   project	project name (top level module should match this name)
#   top_module  top level module of the project
#   libdir	path to library directory
#   libs	library modules used
#   hdlfiles	all local .v files
#   xilinx_cores  all local .xco files
#   vendor      vendor of FPGA (xilinx, altera, etc.)
#   family      FPGA device family (spartan3e) 
#   part        FPGA part name (xc4vfx12-10-sf363)
#   flashsize   size of flash for mcs file (16384)
#   optfile     (optional) xst extra opttions file to put in .scr
#   map_opts    (optional) options to give to map
#   par_opts    (optional) options to give to par
#   intstyle    (optional) intstyle option to all tools
#
#   files 		description
#   ----------  	------------
#   $(project).ucf	ucf file
#
# Library modules should have a modules.mk in their root directory,
# namely $(libdir)/<libname>/module.mk, that simply adds to the hdlfiles
# and xilinx_cores variable.
#
# all the .xco files listed in xilinx_cores will be generated with core, with
# the resulting .v and .ngc files placed back in the same directory as
# the .xco file.
#
# TODO: .xco files are device dependant, should use a template based system

coregen_work_dir ?= ./coregen-tmp
isedir ?= /opt/Xilinx/14.4/ISE_DS 


map_opts ?= -timing -ol high -detail -pr b -register_duplication -w
par_opts ?= -ol high

xil_env ?= . $(isedir)/settings64.sh
flashsize ?= 8192

verilog_files = $(filter %.v,$(hdlfiles))
vhdl_files = $(filter %.vhd,$(hdlfiles))


libmks = $(patsubst %,$(libdir)/%/module.mk,$(libs)) 
mkfiles = Makefile $(libmks) xilinx.mk
include $(libmks)

corengcs = $(foreach core,$(xilinx_cores),$(core:.xco=.ngc))
local_corengcs = $(foreach ngc,$(corengcs),$(notdir $(ngc)))
hdlfiles += $(foreach core,$(xilinx_cores),$(core:.xco=.v))


.PHONY: default xilinx_cores clean twr etwr
default: $(project).bit $(project).mcs
xilinx_cores: $(corengcs)
twr: $(project).twr
etwr: $(project)_err.twr

define cp_template
$(2): $(1)
	cp $(1) $(2)
endef
$(foreach ngc,$(corengcs),$(eval $(call cp_template,$(ngc),$(notdir $(ngc)))))

# Rebuilding Cores. 
%.ngc %.v: %.xco
	@echo "=== rebuilding $@"
	if [ -d $(coregen_work_dir) ]; then \
		rm -rf $(coregen_work_dir)/*; \
	else \
		mkdir -p $(coregen_work_dir); \
	fi
	cd $(coregen_work_dir); \
	coregen -b $$OLDPWD/$<; \
	cd -
	xcodir=`dirname $<`; \
	basename=`basename $< .xco`; \
	if [ ! -r $(coregen_work_dir/$$basename.ngc) ]; then \
		echo "'$@' wasn't created."; \
		exit 1; \
	else \
		cp $(coregen_work_dir)/$$basename.v $(coregen_work_dir)/$$basename.ngc $$xcodir; \
	fi

date = $(shell date +%F-%H-%M)

programming_files: $(project).bit $(project).mcs
	mkdir -p $@/$(date)
	mkdir -p $@/latest
	for x in .bit .mcs .cfi _bd.bmm; do cp $(project)$$x $@/$(date)/$(project)$$x; cp $(project)$$x $@/latest/$(project)$$x; done
	xst -help | head -1 | sed 's/^/#/' | cat - $(project).scr > $@/$(date)/$(project).scr

# Create configuration bit streaming (Xillinx format)
$(project).mcs: $(project).bit
	promgen -w -s $(flashsize) -p mcs -o $@ -u 0 $^


# Create configuration bit streaming (generic format)
$(project).bit: $(project)_par.ncd
	# bitgen $(intstyle) -g DriveDone:yes -g StartupClk:Cclk -w $(project)_par.ncd $(project).bit
	bitgen $(intstyle) -g Binary:yes  -g DriveDone:yes -g StartupClk:Cclk -g DonePipe:yes -w $(project)_par.ncd $(project).bit

# Place & Route
$(project)_par.ncd: $(project).ncd
	if par $(intstyle) $(par_opts) -w $(project).ncd $(project)_par.ncd; then \
		:; \
	else \
		$(MAKE) etwr; \
	fi; \

# Mapping (Rules check & maps the design logic to fisical components)
$(project).ncd: $(project).ngd
	if [ -r $(project)_par.ncd ]; then \
		cp $(project)_par.ncd smartguide.ncd; \
		smartguide="-smartguide smartguide.ncd"; \
	else \
		smartguide=""; \
	fi; \
	map $(intstyle) $(map_opts) $$smartguide $<

# Netlist to Xillix DataBase format
$(project).ngd: $(project).ngc $(project).ucf $(project).bmm
	 ngdbuild $(intstyle) $(project).ngc -bm $(project).bmm

# Synth
$(project).ngc: $(hdlfiles) $(local_corengcs) $(project).scr $(project).prj
	@echo "\n==============  Synth  =============="	
	@xst $(intstyle) -ifn $(project).scr | tee -a xst_report.log  

# Generating the project file
$(project).prj: $(hdlfiles) $(mkfiles)
	@echo "\n==============  Generationg the Project File  =============="	
	@for src in $(verilog_files); do echo "verilog work $$src" >> $(project).tmpprj; done
	@for src in $(vhdl_files); do echo "vhdl work $$src" >> $(project).tmpprj; done
	@sort -u $(project).tmpprj > $(project).prj
	@rm -f $(project).tmpprj
	@echo "$(project).prj: Generated\n"

optfile += $(wildcard $(project).opt)
top_module ?= $(project)
$(project).scr: $(optfile) $(mkfiles) ./xilinx.opt
	@echo "\n==============  Generating the Config File  =============="	
	@echo "run" > $@
	@echo "-p $(part)" >> $@
	@echo "-top $(top_module)" >> $@
	@echo "-ifn $(project).prj" >> $@
	@echo "-ofn $(project).ngc" >> $@
	@cat ./xilinx.opt $(optfile) >> $@
	@echo "$(project).scr: Generated\n"

$(project).post_map.twr: $(project).ncd
	 trce -e 10 $< $(project).pcf -o $@

$(project).twr: $(project)_par.ncd
	 trce $< $(project).pcf -o $(project).twr

$(project)_err.twr: $(project)_par.ncd
	 trce -e 10 $< $(project).pcf -o $(project)_err.twr


# some common junk
junk += $(local_corengcs)
junk += $(coregen_work_dir)
junk += *.xrpt
junk += $(project).mcs $(project).cfi $(project).prm
junk += $(project).bgn $(project).bit $(project).drc $(project)_bd.bmm
junk += $(project)_par.ncd $(project)_par.par $(project)_par.pad 
junk += $(project)_par_pad.csv $(project)_par_pad.txt 
junk += $(project)_par.grf $(project)_par.ptwx
junk += $(project)_par.unroutes $(project)_par.xpi
junk += $(project).ncd $(project).pcf $(project).ngm $(project).mrp $(project).map
junk += smartguide.ncd $(project).psr 
junk += $(project)_summary.xml $(project)_usage.xml
junk += $(project).ngd $(project).bld
junk += xlnx_auto* $(top_module).lso $(project).srp 
junk += netlist.lst xst $(project).ngc
junk += $(project).prj
junk += $(project).scr
junk += $(project).post_map.twr $(project).post_map.twx smartpreview.twr
junk += $(project).twr $(project).twx smartpreview.twr
junk += $(project)_err.twr $(project)_err.twx
junk += xst_report.log
junk += $(project).bin
junk += _xmsgs 
junk += $(project)_bitgen.xwbt
junk += par_usage_statistics.html
junk += usage_statistics_webtalk.html
junk += webtalk.log


.gitignore: $(mkfiles)
	echo programming_files $(junk)  | sed 's, ,\n,g' > .gitignore

clean::
	rm -rf $(junk)
