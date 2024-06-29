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

Write-Host "Using pico-sdk : ${env:PICO_SDK_PATH}"
