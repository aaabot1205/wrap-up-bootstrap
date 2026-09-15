[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot
$TempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$TestRoot = [IO.Path]::GetFullPath((Join-Path $TempBase ('wrap-up-bootstrap-invocation-' + [guid]::NewGuid().ToString('N'))))
$SafePrefix = $TempBase.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
if (-not $TestRoot.StartsWith($SafePrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe invocation test root.' }
$ShellPath = (Get-Process -Id $PID).Path

function Invoke-Check {
    param([bool]$ShouldPass, [string]$ExpectedFailure = '')
    $Output = @(& $ShellPath -NoProfile -ExecutionPolicy Bypass -File (Join-Path $TestRoot 'verify.ps1') -CanonicalOnly 2>&1)
    $Code = $LASTEXITCODE
    if ($ShouldPass -and $Code -ne 0) { throw "Valid policy rejected: $($Output -join ' ')" }
    if (-not $ShouldPass -and ($Code -eq 0 -or ($Output -join ' ') -notlike "*$ExpectedFailure*")) {
        throw "Invalid policy was not rejected for the expected reason: $($Output -join ' ')"
    }
}

New-Item -ItemType Directory -Path $TestRoot | Out-Null
try {
    $Paths = @(& git -C $ProjectRoot ls-files)
    if ($LASTEXITCODE -ne 0) { throw 'Unable to list canonical files.' }
    foreach ($Relative in $Paths) {
        $Target = [IO.Path]::GetFullPath((Join-Path $TestRoot $Relative))
        if (-not $Target.StartsWith($TestRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe fixture path.' }
        New-Item -ItemType Directory -Path (Split-Path -Parent $Target) -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $ProjectRoot $Relative) -Destination $Target
    }
    Invoke-Check -ShouldPass $true
    foreach ($Skill in @('bootstrap', 'wrap-up')) {
        $Entry = Join-Path $TestRoot "$Skill\SKILL.md"
        $EntryText = [IO.File]::ReadAllText($Entry)
        foreach ($Replacement in @('disable-model-invocation: false', 'disable-model-invocation: "true"', '')) {
            [IO.File]::WriteAllText($Entry, $EntryText.Replace('disable-model-invocation: true', $Replacement))
            Invoke-Check -ShouldPass $false -ExpectedFailure "$Skill must set disable-model-invocation"
        }
        [IO.File]::WriteAllText($Entry, $EntryText)
        $Metadata = Join-Path $TestRoot "$Skill\agents\openai.yaml"
        $MetadataText = [IO.File]::ReadAllText($Metadata)
        foreach ($Replacement in @('allow_implicit_invocation: true', 'allow_implicit_invocation: "false"', '')) {
            [IO.File]::WriteAllText($Metadata, $MetadataText.Replace('allow_implicit_invocation: false', $Replacement))
            Invoke-Check -ShouldPass $false -ExpectedFailure "$Skill must set policy.allow_implicit_invocation"
        }
        [IO.File]::WriteAllText($Metadata, $MetadataText)
    }
    Invoke-Check -ShouldPass $true
    Write-Output '[PASS] Invocation metadata contract: valid configuration accepted; 12 missing, enabled, or string-valued policy mutations rejected. This is not a host invocation behavior test.'
} finally {
    if (Test-Path -LiteralPath $TestRoot) { Remove-Item -LiteralPath $TestRoot -Recurse -Force }
}
