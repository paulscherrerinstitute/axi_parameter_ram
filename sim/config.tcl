#Constants
set LibPath "../../.."

#Set library
psi::sim::add_library axi_parameter_ram_v1_0_lib

#suppress messages
psi::sim::compile_suppress 135,1236
psi::sim::run_suppress 8684,3479,3813,8009,3812

# libraries
psi::sim::add_sources "$LibPath" {
	VHDL/psi_common/hdl/psi_common_math_pkg.vhd \
	VHDL/psi_common/hdl/psi_common_tdp_ram_rbw_be.vhd \
	VHDL/psi_common/hdl/psi_common_tdp_ram_rbw.vhd \
	VHDL/psi_common/hdl/psi_common_sync_fifo.vhd \
	VHDL/psi_tb/hdl/psi_tb_txt_util.vhd \
	VHDL/psi_tb/hdl/psi_tb_axi_pkg.vhd \
} -tag lib

# axi_slave_ipif	
psi::sim::add_sources "$LibPath/VivadoIp/axi_slave_ipif_package/hdl" {
	axi_slave_ipif_package.vhd \
} -tag lib

# project sources
psi::sim::add_sources "../hdl" {
	axi_parameter_ram_v1_0.vhd \
} -tag src

# testbench
psi::sim::add_sources "../tb" {
	axi_parameter_ram_tb.vhd \
} -tag tb
	
#TB Runs
psi::sim::create_tb_run "axi_parameter_ram_tb"
psi::sim::add_tb_run