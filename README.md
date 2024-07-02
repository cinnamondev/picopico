# cmsis-rp2040

Pico/RP2040 Project Template.

## Dependencies

- Powershell
- OpenOCD (TODO: Need to setup CI/CD for linux builds, then this will be providded in vcpkg)

Powershell (5.1 or so should be fine, works with the version installed on Windows 11). Everything else (compilers, etc...) will be installed by a bootstrapped `vcpkg`. This removes the need to install the ARM GCC compiler, Open-CMSIS-Pack ctools/[devtools](https://github.com/Open-CMSIS-Pack/devtools), cmake or ninja - at least within the build environment. If you need to access them quickly a second script is provided, `bootstrap.ps1` which will install all the same build tools. The Open-CMSIS-Pack suite is licensed under Apache 2.0 and is suitable for any FOSS application!

[Powershell](https://github.com/PowerShell/PowerShell) is now a crossplatform tool and this should work just about fine on linux - though this has not been properly tested yet. Powershell is licensed under the MIT license.

## Licenses

This code is licensed under the [Apache 2.0 License](./LICENSE).
