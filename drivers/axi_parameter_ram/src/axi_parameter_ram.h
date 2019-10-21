#pragma once

#ifdef __cplusplus
extern "C" {
#endif

//*******************************************************************************
// Includes
//*******************************************************************************
#include <stdint.h>
#include <stdbool.h>

//*******************************************************************************
// Constants
//*******************************************************************************

/// @cond
#define AXI_PARAMETER_RAM_NO_IRQ_OFFS 		0x1000
#define AXI_PARAMETER_RAM_MEM_OFFS 			0x10

#define AXI_PARAMETER_RAM_STATUS_OFFS		0x00
#define AXI_PARAMETER_RAM_STATUS_EMPTY_MSK	(1<<0)

#define AXI_PARAMETER_RAM_ADDR_OFFS			0x04
/// @endcond

//*******************************************************************************
// Functions
//*******************************************************************************
/**
 * @brief 	Write into the paramter RAM without generating an IRQ.
 *
 * @param 	baseAddr	Base address of the parameter ram (byte address)
 * @param 	paramAddr	Byte address of the parameter to write
 * @param 	value		Value of the parameter to write
 * @param	suppressIrq	If true, IRQ generation is suppressed
 */
void AxiParameterRam_WriteParam(	const uint32_t baseAddr,
									const uint16_t paramAddr,
									const uint32_t value,
									bool suppressIrq);

/**
 * Read a parameter from the parameter RAM.
 *
 * @param 	baseAddr	Base address of the parameter ram (byte address)
 * @param 	paramAddr	Byte address of the parameter to read
 * @return				Value of the parameter
 */
uint32_t AxiParameterRam_ReadParam(	const uint32_t baseAddr,
									const uint16_t param);

/**
 * Check if the parameter ram access FIFO is empty.
 *
 * @param 	baseAddr	Base address of the parameter ram (byte address)
 * @return				True = FIFO is empty
 */
bool AxiParameterRam_Empty(const uint32_t baseAddr);

/**
 * Get the address of the next access that is stored in the FIFO
 *
 * @param 	baseAddr	Base address of the parameter ram (byte address)
 * @return				Address (byte address within param-ram) of the parameter access that caused an IRQ
 */
uint16_t AxiParameterRam_GetAccessAddr(const uint32_t baseAddr);

#ifdef __cplusplus
}
#endif
