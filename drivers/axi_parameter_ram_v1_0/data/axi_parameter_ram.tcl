

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "axi_parameter_ram" "NUM_INSTANCES" "DEVICE_ID"  "C_BASEADDR" "C_HIGHADDR"
}
