###############################################################
# Include PSI packaging commands
###############################################################
source ../../../TCL/PsiIpPackage/PsiIpPackage.tcl
namespace import -force psi::ip_package::latest::*

###############################################################
# General Information
###############################################################
set IP_NAME axi_parameter_ram
set IP_VERSION 1.0
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

#Relative Library Files
add_lib_relative \
	"../../.."	\
	{ \
		VHDL/psi_common/hdl/psi_common_math_pkg.vhd \
		VHDL/psi_common/hdl/psi_common_sp_ram_rbw_be.vhd \
		VHDL/psi_common/hdl/psi_common_tdp_ram_rbw.vhd \
		VHDL/psi_common/hdl/psi_common_sync_fifo.vhd \
		VivadoIp/axi_slave_ipif_package/hdl/axi_slave_ipif_package.vhd \
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

#This component has a standard AXI slave port
has_std_axi_if false

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




