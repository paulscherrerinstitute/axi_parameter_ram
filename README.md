# General Information

## Maintainer
Oliver Bründler [oliver.bruendler@psi.ch]

## Authors
Oliver Bründler [oliver.bruendler@psi.ch]

## Changelog
See [Changelog](Changelog.md)

## Documentation
[SW Driver](./doc/api/html/globals_func.html)

<!-- DO NOT CHANGE FORMAT: this section is parsed to resolve dependencies -->

## Dependencies

* TCL
  * [PsiSim](https://github.com/paulscherrerinstitute/PsiSim) (2.1.0 or higher, for development only)
  * [PsiIpPackage](https://git.psi.ch/GFA/Libraries/Firmware/TCL/PsiIpPackage) (1.5.0, for development only )
  * [PsiUtil](https://git.psi.ch/GFA/Libraries/Firmware/TCL/PsiUtil) (1.1.0, for development only )
* VHDL
  * [psi\_common](https://github.com/paulscherrerinstitute/psi_common) (2.0.0 or higher)
  * [psi\_tb](https://github.com/paulscherrerinstitute/psi_tb) (2.0.0 or higher)
* VivadoIp
  * [axi\_slave\_ipif\_package](https://git.psi.ch/GFA/Libraries/Firmware/VivadoIp/axi_slave_ipif_package) (1.0.1 or higher)
  * [**axi\_parameter\_ram**](https://git.psi.ch/GFA/Libraries/Firmware/VivadoIp/axi_parameter_ram)

<!-- END OF PARSED SECTION -->

Dependencies can also be checked out using the python script *scripts/dependencies.py*. For details, refer to the help of the script:

```
python dependencies.py -help
```

Note that the [dependencies package](https://git.psi.ch/GFA/Libraries/Firmware/Python/PsiLibDependencies) must be installed in order to run the script.





 