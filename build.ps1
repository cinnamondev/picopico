param (
  [switch]
  $Clean,
  [switch]
  $ForceRebuildCMake,
  [switch]
  $Release
)
# environment
./bootstrap.ps1

$cwd = Get-Location
if (-not $(Test-Path "${cwd}/build")) {mkdir build}
$build = Resolve-Path ./build/

if ($Clean) {
  Remove-Item -Path $build -Recurse -Force
  mkdir $build
}

Set-Location $build
if ($ForceRebuildCMake -or (-not $(Test-Path build.ninja))) {
  cmake .. 
}

if ($LASTEXITCODE -eq 0) {
  $BuildMode = If ($Release) {"Release"} else {"Debug"}
  #ninja "build-${BuildMode}.ninja"
  make -j8
}

cd ..