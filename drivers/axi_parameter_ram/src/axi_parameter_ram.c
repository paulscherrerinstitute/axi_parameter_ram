#include "axi_parameter_ram.h"
#include <xil_io.h>

void AxiParameterRam_WriteParam(	const uint32_t baseAddr,
									const uint16_t paramAddr,
									const uint32_t value,
									bool suppressIrq)
{
	uint32_t addr = baseAddr+AXI_PARAMETER_RAM_MEM_OFFS+paramAddr;
	if (suppressIrq)
	{
		addr += AXI_PARAMETER_RAM_NO_IRQ_OFFS;
	}
	Xil_Out32(addr, value);
}

uint32_t AxiParameterRam_ReadParam(	const uint32_t baseAddr,
									const uint16_t paramAddr)
{
	return Xil_In32(baseAddr + AXI_PARAMETER_RAM_MEM_OFFS + paramAddr);
}

bool AxiParameterRam_Empty(const uint32_t baseAddr)
{
	uint32_t status = Xil_In32(baseAddr + AXI_PARAMETER_RAM_STATUS_OFFS);
	return ((status & AXI_PARAMETER_RAM_STATUS_EMPTY_MSK) != 0);
}

uint16_t AxiParameterRam_GetAccessAddr(const uint32_t baseAddr)
{
	return Xil_In32(baseAddr + AXI_PARAMETER_RAM_ADDR_OFFS);
}
