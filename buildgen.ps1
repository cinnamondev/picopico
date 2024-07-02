# buildgen.ps1
# Tested on Powershell 7.4.2 Linux, 
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
    [string]
    $csolution = "",
    [switch]
    $IgnoreEnvironment,
    [string]
    $TargetProject = "",
    [string]
    $BuildType = "Debug",
    [string]
    $TargetType = "",
    [switch]
    $Program,
    [switch]
    $Help
)

$err
try {
    Import-Module powershell-yaml
} 
catch {
    Write-Host "Module powershell-yaml is required to parse csolution/cproject(s). Installing to User scope..."
    Install-Module powershell-yaml -Scope CurrentUser
}


if ($Help) {
    Write-Host @"
buildgen.ps1 <path to csolution> [args]
args:
    -csolution <path to csolution>  (not required if only 1 csolution present in cwd)
    -BuildTarget <Debug/Release> (default=Debug)
    -TargetProject <name of project> (Required)
    -IgnoreEnvironment (ignore incorrect CWD errors)
    -Help (opens this menu)
"@
    exit
}

./bootstrap.ps1

# Find solution file
$SOLUTIONS = @(Get-ChildItem -Filter "*.csolution.y*ml" | select -expand FullName)
$SOLUTION = ""
if ($SOLUTIONS.Length -eq 1) {
    # we only need to double check there wasnt a csolution explicitly provided.
    $SOLUTION = @($SOLUTIONS)[0]
    if (($SOLUTION -ne $csolution) -and $csolution) { # cannot find explicit csolution.
        Write-Error "Cannot find supplied csolution (one found in CWD, but it did not match supplied string)"
        exit
    }
} else {
    if (-not $csolution) {
        Write-Error "Multiple csolutions available. Please specify which one."
        exit
    } else {
        if ($csolution -Match ".+\.csolution.y[a]*ml") {
            $SOLUTION = Resolve-Path $csolution -ErrorVariable err -ErrorAction SilentlyContinue
        } else {
            # extension not provided, test which extension to use. Al
            if ((Test-Path "${csolution}.csolution.yaml") -eq $true) {
                $SOLUTION = "$(Resolve-Path "${csolution}.csolution.yaml")"
            } elseif ((Test-Path "${csolution}.csolution.yml") -eq $true) {
                $SOLUTION = "$(Resolve-Path "${csolution}.csolution.yml")"
            } else { # no instances of *.csolution.y(a)ml
                Write-Error "Could not find csolution."
                exit 
            }
        }
        if ($err) {
                Write-Host $err
                exit
            }
        if ((-not ($SOLUTIONS -contains $SOLUTION)) -and ($SOLUTION -ne "") -and (-not $IgnoreEnvironment)) {
            # SOLUTION resolved, not found in CWD. Override with -IgnoreEnvironment
            Write-Error "soft fault, csolution found but it is not in cwd. are you calling from a different env?? (use switch -IgnoreEnvironment to ignore)"
            exit
        }
    }
}
Write-Host "Using CSOLUTION: ${SOLUTION}"

# Discover projects, targets, types.

$yaml_csolution = $(Get-Content $SOLUTION | ConvertFrom-yaml).solution
$AvailableProjects = @{} # project hashtable
$TargetTypeList = @() # Target types array
$BuildTypeList = @() # Build types array

foreach($project in $yaml_csolution.projects) {
    $($project.GetEnumerator()).Value -match "(.*[\\\/](.+).cproject.y[a]*ml)" | Out-Null
    $AvailableProjects["$(($Matches.2 | Out-String).Trim())"] = $Matches.1
}

foreach($target in $yaml_csolution["target-types"]) {
    $target.type | ForEach-Object {
        $TargetTypeList += $_.Trim()
    }
}

foreach($builds in $yaml_csolution["build-types"]) {
    $builds.type | ForEach-Object {
        $BuildTypeList += $_.Trim()
    }
}

# Check if we have anything missing...

if  ($AvailableProjects.Length -eq 0) { # csolution is missing projects?
    Write-Error "Could not find any projects in csolution :("
    exit
} else {
    Write-Host @"
Found Projects:
$($AvailableProjects.Keys | Out-String)
"@
}

if  ($TargetTypeList.Length -eq 0) { # csolution is missing targets?
    Write-Error "There are no targets?"
    exit
} else {
    Write-Host @"
Found Targets:
$($TargetTypeList | Out-String)
"@
}

if  ($BuildTypeList.Length -eq 0) { # csolution is missing builds?
    Write-Error "There are no build types?"
    exit
} else {
    Write-Host @"
Found Build Types:
$($BuildTypeList | Out-String)
"@
}

# Project Inference & parameter checking

if (-not $TargetProject) {
    # targetproject not specified
    if ($AvailableProjects -eq 1) {
        # No target project provided
        $TargetProject = $AvailableProjects[0]
        Write-Host "(warning) inferring project via only singular available..."
    } else {
        Write-Error "Multiple projects present, but none specified (Specify with -TargetProject <project name>)."
        exit
    }
}

if (-not $AvailableProjects.ContainsKey($TargetProject.Trim())) { 
    Write-Error "Cannot find target project! (See list of available projects, and/or check your csolution)"
    exit
}

# target inference & parameter checking

if ((-not $TargetType) -and ($TargetTypeList.Length -eq 1)) {
    $TargetType = $TargetTypeList[0]
    Write-Host "inferring target type by only available..."
}

if (-not $TargetTypeList -contains $TargetType) { 
    Write-Error "Cannot find target type! (See list of available target types, and/or check your csolution) (specify using -TargetType <device>)"
    exit
}

# build inference & parameter checking

if ((-not $BuildType) -and ($BuildTypeList.Length -eq 1)) {
    $BuildType = $BuildTypeList[0]
    Write-Host "inferring build type by only available..."
}

if (-not $BuildTypeList -contains $BuildType) { 
    Write-Error "Cannot find build type! (See list of available build types, and/or check your csolution) (specify using -BuildType <build type>)"
    exit
}

# TODO: wrap to build multiple projects, targets, etc. i.e -TargetProject * -BuildType Release -TargetType * for all projects and targets as Release.
$ProjectName = $TargetProject.Trim()
$Project_Full_Path = $AvailableProjects[$ProjectName]

$_T = Get-Location
$BUILDROOT = "${_T}/build"
$TEMPDIR = "${_T}/build/"
$PROJECTDIR ="${_T}/build/${ProjectName}"
$TARGETDIR = "${_T}/build/${ProjectName}/${TargetType}"
$BUILDDIR = "${_T}/build/${ProjectName}/${TargetType}/${BuildType}"
$OUTPUTDIR = "${_T}/out/${ProjectName}/${TargetType}/${BuildType}/"


# ensure build directories exist
if (-not (Test-Path $OUTPUTDIR)) {
    New-Item -Path $OUTPUTDIR -ItemType Directory
    New-Item -Path $BUILDDIR -ItemType Directory
}

# Get missing packages
foreach($l in (csolution -s $SOLUTION list packs -m)) {
    Write-Host "[BUILDGEN] Installing CMSIS-Pack: "$l
    cpackget add $("${l}".Split("@")[0])
}
# Create *.CPRJ targets
csolution convert -s $SOLUTION -o $TEMPDIR
# Create CMakeList for target project
cbuildgen cmake "${BUILDROOT}/${ProjectName}.${BuildType}+${TargetType}.cprj" --intdir $BUILDDIR --outdir $OUTPUTDIR

# Build with CMake + Ninja
Set-Location $BUILDDIR


(Get-Content "CMakeLists.txt") | 
    Foreach-Object {
        $_
        if ($_ -match 'cmake_minimum_required\(.+\)') {
            # Insert SDK after version
            Write-Output "include(${_T}/pico_sdk_import.cmake)".Replace('\','/')
        }
        if ($_ -match 'project\(.+\)') {
            # Load SDK after project (+ additional languages for SDK)
            Write-Output @"
project(`${TARGET} CXX ASM)
pico_sdk_init()
"@
        }
    } | Set-Content "CMakeLists.txt"

$SDK_OPTS_PATH = "${_T}/sdk_options.cmake" 
# Check if a sdk_options.BUILD+TARGET.cmake exists
if (Test-Path "${_T}/sdk_options.${BuildType}+${TargetType}.cmake") {
    $SDK_OPTS_PATH = "${_T}/sdk_options.${BuildType}+${TargetType}.cmake"
}

# Include SDK options ( include() via cmake confuses it :( )
Get-Content "${_T}/sdk_options.cmake" | Add-Content "CMakeLists.txt"

cmake -GNinja -B . 
ninja 

if ($Program) {
    openocd -f ${_T}/openocd.cfg -c "program ${_T}/out/${ProjectName}/${TargetType}/${BuildType}/${ProjectName}.elf verify reset exit"
}

Set-Location $_T
