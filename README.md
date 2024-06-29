# picopico

## Bootstrap

Requiries Powershell on *all* operating systems. `bootstrap.ps1` is used to maintain
the build environment. It will search for pico-sdk in the current, then parent directories.
If an installation is not already present, and the previous is true, it will prompt to clone a new copy.

Bootstrap will also invoke vcpkg and activate the build environment. It is handy as a pre-build step, as
you will not need to install any other packages.

You can use this template without the bootstrap script. You will requirie the following:
- arm-none-eabi-gcc (pico-sdk only supports gcc! no AC6)
- cmake
- ninja
- openocd

### Structuring your projects

Personally, I reccomend placing your pico-sdk install in the parent directory of
your project. Try to avoid cluttering your system with many sdk installs, if you
have cleaned up your installs, use option `-ResetSDKLocation` and it will remove
the environment variable. 

You could also choose to place it in your home directory. It is important to set
the environment variable PICO_SDK_PATH. This can always be set by yourself, though
usng the option `-PICO_SDK_PATH <path>` via `bootstrap.ps1` will also do this.

## Integration

### Vscode

Reccomended extensions:

Example tasks.json:
```

```

## Debugging / picoprobe

The Pi Foundation have their own firmware for the Pico, called 
[debugprobe](https://github.com/raspberrypi/debugprobe), which can
turn a Pi Pico into a CMSIS-DAP debug probe with additional UART bridge.

There are alternative debug probes you can use instead too, any CMSIS-DAP probe
can be used without additional confiiguration. Past this, you're on your own :).

![Getting Started with Raspberry Pi Pico - page 64. Wiring Diagram](./.assets/picoprobe_wiring.png)

> The above is an exert from  "[Getting Started with Raspberry Pi Pico](https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf)" datasheet - Page 64.<br><br>
The documentation of the RP2040 microcontroller is licensed under a [Creative Commons Attribution-NoDerivatives 4.0 International (CC BY-ND)](https://creativecommons.org/licenses/by-nd/4.0/).

Alternatively, the Pi Foundation also [make their own debug probe](https://www.raspberrypi.com/products/debug-probe/), which should function through the same means, but using
their standardised [Debug connector spec](https://datasheets.raspberrypi.com/debug/debug-connector-specification.pdf).

# Licensing

[Apache 2.0 License](./LICENSE).

```text
   Copyright 2024 Cinnamondev

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

# TODO

- CI Pipeline for OpenOCD builds to replace microsoft/openocd.