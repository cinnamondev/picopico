<# Copyright 2024 Cinnamondev

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
#>

param (
    [switch]
    $ResetSDKLocation,
    [string]
    $PICO_SDK_PATH
)

# development dependencies + specify pico sdk

# bootstrap vcpkg & activate build environment
Invoke-Expression (Invoke-WebRequest -useb https://aka.ms/vcpkg-init.ps1)
vcpkg activate

if ($ResetSDKLocation) {
  [Environment]::SetEnvironmentVariable("PICO_SDK_PATH", $null, "User")
  $env:PICO_SDK_PATH = ""
}

$oldPath = $env:PICO_SDK_PATH

if ($PICO_SDK_PATH) {
  $prevPath = $env:PICO_SDK_PATH
  $env:PICO_SDK_PATH = Resolve-Path $PICO_SDK_PATH
  Write-Host "Using pico-sdk : ${env:PICO_SDK_PATH}"
  if ($env:PICO_SDK_PATH -eq $prevPath) { exit }
  $userInput = Read-Host @"
  Would you like to SET the PICO_SDK_PATH env-var to this new path?
  (Y/n)
"@
  if ("${userInput}" -eq "n") { exit }
  [Environment]::SetEnvironmentVariable("PICO_SDK_PATH", $env:PICO_SDK_PATH, "User")
  exit
}

$cwd = Get-Location
if(-not $env:PICO_SDK_PATH) {
  if (Test-Path pico-sdk) {
    $env:PICO_SDK_PATH = "$(Resolve-Path ./)/pico-sdk"
  } elseif (Test-Path ../pico-sdk) {
    $env:PICO_SDK_PATH = "$(Resolve-Path ../)/pico-sdk"
  } else {
    ## tree finish, offer to clone
    $userInput = Read-Host @"
Cannot resolve pico-sdk in ./ or ../ .
Please specify environment variable PICO_SDK_PATH to the absolute path of your SDK.
If there is no existing installation, it can be cloned for you. Proceed?
(y/N)
"@
    if ("${userInput}".toLower() -eq "y") {
      $userInput = Read-Host @"
Clone in current directory (1, default) or parent directory (2)?
(1/2)
"@
      if ($userInput -eq "2") {
        cd ..
      }
      git clone https://github.com/raspberrypi/pico-sdk.git
      cd pico-sdk
      git submodule init
      git submodule update
      $env:PICO_SDK_PATH = "$(Resolve-Path ./)"
      cd $cwd
  }
  if (-not $oldPath) {
    $userInput = Read-Host @"
Would you like to SET the PICO_SDK_PATH env-var to this new installation?
(Y/n)
"@
    if ("${userInput}" -eq "n") { exit }
      [Environment]::SetEnvironmentVariable("PICO_SDK_PATH", $env:PICO_SDK_PATH, "User")
    }
}

}


Write-Host "Using pico-sdk : ${env:PICO_SDK_PATH}"
