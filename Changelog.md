## 2.2.2

* Info
  * Migration to GitHub

## 2.2.1

* Bugfixes
  * Test more than 1024 parameters on HW and fix issues

## 2.2.0

* Features
  * Added dependency resolution script
* Changes
  * Use AXI slave from *psi\_common* instead of legacy version

## 2.1.1

* New Features
  * None
* Bugfixes
  * Parametrization of RAM depth did not work correctly (FIFO width was not scaled)

## 2.1.0

* New Features
  * Made memory depth configurable
* Bugfixes
  * None

## 2.0.0

* Changes (not reverse compatiable)
  * Change to use new library versions after open sourcing (see README>Dependencies for detealy)

## 1.1.2

* New Features
  * None
* Bugfixes
  * Made compatible with psi\_common >= 1.10.0

## 1.1.1

* New Features
  * None
* Bugfixes
  * Fixed AXI\_PARAMETER\_RAM\_MEM\_OFFS ins driver headerfile

## 1.1.0

* New Features
  * Added SW Driver
* Bugfixes
  * Made AXI address and data width fixed (8k/13bit address range, 32-bit data) since other values are not supported anyway
* Changed Dependencies
  * Requires TCL/PsiIpPackage >= 1.2.0

## 1.0.2

* Bugfixes
  * Fixed bug in TB (wrong library name)
* Cleanup
  * Made project ready for continuous integration

## 1.0.1

* Added Features
  * Added propper testbench
* Bugfixes
  * Replaced FIFO/RAM primitives by psi_common constructs for family independency (old version only compiled for 7 series)
* Changed Dependencies
  * Requires psi_common >= 1.4.0
  * Requires psi_tb

## V1.00

* First release (port from CVS)