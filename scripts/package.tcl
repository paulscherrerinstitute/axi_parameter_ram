###############################################################
# Include PSI packaging commands
###############################################################
source ../../../TCL/PsiIpPackage/PsiIpPackage.tcl
namespace import -force psi::ip_package::latest::*

###############################################################
# General Information
###############################################################
set IP_NAME axi_parameter_ram
set IP_VERSION 2.2
set IP_REVISION "auto"
set IP_LIBRARY GPAC3
set IP_DESCIRPTION "Parameter RAM for data exchange between CPU and EPICS"

init $IP_NAME $IP_VERSION $IP_REVISION $IP_LIBRARY
set_description $IP_DESCIRPTION
set_logo_relative "../doc/psi_logo_150.gif"
###############################################################
# Add Source Files
###############################################################

#Relative Source Files
add_sources_relative { \
	../hdl/axi_parameter_ram_v1_0.vhd \
}	

#PSI Common
add_lib_relative \
	"../../../VHDL/psi_common/hdl"	\
	{ \
		psi_common_array_pkg.vhd \
		psi_common_math_pkg.vhd \
		psi_common_logic_pkg.vhd \
		psi_common_sp_ram_be.vhd \
		psi_common_sdp_ram.vhd \
		psi_common_sync_fifo.vhd \
		psi_common_pl_stage.vhd \
		psi_common_axi_slave_ipif.vhd \
	}	


###############################################################
# Driver Files
###############################################################	

add_drivers_relative ../drivers/axi_parameter_ram { \
	src/axi_parameter_ram.c \
	src/axi_parameter_ram.h \
}

###############################################################
# GUI Parameters
###############################################################

#User Parameters
gui_add_page "Configuration"

gui_create_parameter "RamSizeDword_g" "Number of RAM entries (in DWORD)"
gui_parameter_set_range 256 65536
gui_add_parameter

gui_create_parameter "C_S_AXI_ADDR_WIDTH" "AXI Address width"
gui_add_parameter

###############################################################
# Optional Ports
###############################################################

#None

###############################################################
# Package Core
###############################################################
set TargetDir ".."
#											Edit  Synth	
package_ip $TargetDir            			false true




