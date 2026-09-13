[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProjectRoot = [IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$TempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$TestRoot = [IO.Path]::GetFullPath((Join-Path $TempRoot ('wrap-up-bootstrap-packaging-' + [guid]::NewGuid().ToString('N'))))
$SafePrefix = $TempRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
if (-not $TestRoot.StartsWith($SafePrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe packaging test root.' }

function Assert-SkillPackage {
    param([string]$SkillRoot)
    $Entry = Join-Path $SkillRoot 'SKILL.md'
    if (-not (Test-Path -LiteralPath $Entry -PathType Leaf)) { throw "Skill entry is missing: $Entry" }
    $Text = [IO.File]::ReadAllText($Entry)
    foreach ($Match in [regex]::Matches($Text, '\[[^\]]+\]\(([^)]+\.md)\)')) {
        $Relative = $Match.Groups[1].Value.Replace('/', [IO.Path]::DirectorySeparatorChar)
        if ([IO.Path]::IsPathRooted($Relative)) { throw "Skill reference must be relative: $Relative" }
        $Resolved = [IO.Path]::GetFullPath((Join-Path $SkillRoot $Relative))
        $Prefix = [IO.Path]::GetFullPath($SkillRoot).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
        if (-not $Resolved.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)) { throw "Skill reference escapes package: $Relative" }
        if (-not (Test-Path -LiteralPath $Resolved -PathType Leaf)) { throw "Skill reference is missing: $Relative" }
    }
}

New-Item -ItemType Directory -Path $TestRoot | Out-Null
try {
    foreach ($SkillName in @('bootstrap', 'wrap-up')) {
        $Destination = Join-Path $TestRoot $SkillName
        Copy-Item -LiteralPath (Join-Path $ProjectRoot $SkillName) -Destination $Destination -Recurse
        Assert-SkillPackage -SkillRoot $Destination
    }

    $MissingReference = Join-Path $TestRoot 'wrap-up\references\plan-fidelity.md'
    Move-Item -LiteralPath $MissingReference -Destination ($MissingReference + '.missing')
    $Rejected = $false
    try { Assert-SkillPackage -SkillRoot (Join-Path $TestRoot 'wrap-up') } catch { $Rejected = $_.Exception.Message -like '*reference is missing*' }
    if (-not $Rejected) { throw 'Package validation accepted a missing required reference.' }

    Write-Output '[PASS] Each skill is independently packageable and a missing linked reference is rejected.'
} finally {
    if (Test-Path -LiteralPath $TestRoot) { Remove-Item -LiteralPath $TestRoot -Recurse -Force }
}
