param (
    [switch]
    $ResetSDKLocation
)

# development dependencies + specify pico sdk

# bootstrap vcpkg & activate build environment
Invoke-Expression (Invoke-WebRequest -useb https://aka.ms/vcpkg-init.ps1)
vcpkg activate

if ($ResetSDKLocation) {
  [Environment]::SetEnvironmentVariable("PICO_SDK_PATH", $null, "User")
  $env:PICO_SDK_PATH = ""
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
If there is no existing installation, it can be cloned for you. Proceed? (y/N) :
"@
    if ("${userInput}".toLower() -eq "y") {
      $userInput = Read-Host @"
Clone in current directory (1, default) or parent directory (2)?
(1/2) : 
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

      Write-Host "Using pico-sdk : ${env:PICO_SDK_PATH}"
      $userInput = Read-Host @"
Would you like to SET the PICO_SDK_PATH env-var to this new installation?
(Y/n) :
"@
      if ("${userInput}" -eq "n") { exit }
      [Environment]::SetEnvironmentVariable("PICO_SDK_PATH", $env:PICO_SDK_PATH, "User")
      exit
    }
  }
}


exit

$myJson = Get-Content .\config.json -Raw | ConvertFrom-Json 


$picoSDKPath = "$(Get-Location)/pico-sdk"

# use PICO_SDK_PATH if it is available
if (-not $myJson.picoSDK)  {$}
if ($env:PICO_SDK_PATH -and (-not $myJson.ignoreEnv)) {
  $picoSDKPath = $env:PICO_SDK_PATH
}

if ($myJson.ignoreEnv -or (-not $env:PICO_SDK_PATH)) {
  # consistent behaviour - if iignore env go straight to config.

  $uriIsHTTPX = ([uri]::IsWellFormedUriString($myJson.sdkURI, 'Absolute') -and ([uri] $myJson.sdkURI).Scheme -in 'http', 'https') 
  $uriIsSSH = ($myJson.sdkURI -match ".+@.+\..+:.+?=*[\/].+") # X@X.X:X/X
  if ($uriIsHTTPX -or $uriIsSSH) {
    # remove previous
    if ((Test-Path pico-sdk) -and ("$(git --git-dir=./pico-sdk/.git remote get-url origin)".Trim() -ne $myJson.sdkURI)) {
      Write-Host "Git repository"
      Remove-Item -LiteralPath $picoSDKPath -Force -Recurse
      git clone $myJson.sdkURI
      $env:PICO_SDK_PATH = $picoSDKPath
      $myJson.picoSDK = $picoSDKPath
    }
  } elseif ($myJson.picoSDK) {
    $env:PICO_SDK_PATH = $myJson.picoSDK
  } elseif ($myJson.sdkURI) {
    Write-Error "SDK URI is not legible. Provide HTTPS or SSH Git URI."
  } else {
    Write-Error "SDK Path not legible or valid or other case."
  }
}
