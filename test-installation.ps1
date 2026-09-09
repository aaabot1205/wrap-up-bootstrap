[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$TempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$TestUserRoot = [System.IO.Path]::GetFullPath((Join-Path $TempRoot ("wrap-up-bootstrap-install-" + [guid]::NewGuid().ToString('N'))))
$SafePrefix = $TempRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $TestUserRoot.StartsWith($SafePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Refusing to use an unsafe installation test root.'
}

function Assert-Condition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Invoke-RepositoryScript {
    param([string]$ScriptName, [string[]]$Arguments)

    $Output = @(& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ProjectRoot $ScriptName) @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) {
        $Detail = ($Output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
        throw "$ScriptName failed with exit code $LASTEXITCODE`: $Detail"
    }
    return $Output
}

function Assert-SkillTreeMatches {
    param([string]$SkillName, [string]$DestinationRoot)

    $SourceDirectory = Join-Path $ProjectRoot $SkillName
    $DestinationDirectory = Join-Path $DestinationRoot $SkillName
    foreach ($SourceFile in Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File) {
        $RelativePath = $SourceFile.FullName.Substring($SourceDirectory.Length).TrimStart('\')
        $DestinationFile = Join-Path $DestinationDirectory $RelativePath
        Assert-Condition (Test-Path -LiteralPath $DestinationFile -PathType Leaf) "Installed skill file is missing: $DestinationFile"
        $SourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourceFile.FullName).Hash
        $DestinationHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $DestinationFile).Hash
        Assert-Condition ($SourceHash -ceq $DestinationHash) "Installed skill file differs from canonical source: $DestinationFile"
    }
}

function Get-FileSnapshot {
    param([string]$Root)

    return @(Get-ChildItem -LiteralPath $Root -Recurse -File | Sort-Object FullName | ForEach-Object {
        $RelativePath = $_.FullName.Substring($Root.Length)
        $Hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash
        "$RelativePath|$Hash|$($_.LastWriteTimeUtc.Ticks)"
    })
}

New-Item -ItemType Directory -Path $TestUserRoot | Out-Null
try {
    $CurrentRoot = Join-Path $TestUserRoot '.gemini\config\skills'
    $LegacyRoot = Join-Path $TestUserRoot '.gemini\antigravity\skills'
    foreach ($Root in @($CurrentRoot, $LegacyRoot)) {
        $UnrelatedDirectory = Join-Path $Root 'unrelated-skill'
        New-Item -ItemType Directory -Force -Path $UnrelatedDirectory | Out-Null
        [System.IO.File]::WriteAllText((Join-Path $UnrelatedDirectory 'SKILL.md'), 'unrelated sentinel')

        $StaleDirectory = Join-Path $Root 'wrap-up'
        New-Item -ItemType Directory -Force -Path $StaleDirectory | Out-Null
        [System.IO.File]::WriteAllText((Join-Path $StaleDirectory 'SKILL.md'), 'stale managed copy')
    }

    Invoke-RepositoryScript -ScriptName 'install.ps1' -Arguments @('-UserRoot', $TestUserRoot) | Out-Null

    foreach ($Root in @(
        (Join-Path $TestUserRoot '.agents\skills'),
        (Join-Path $TestUserRoot '.claude\skills'),
        $CurrentRoot,
        $LegacyRoot
    )) {
        foreach ($SkillName in @('wrap-up', 'bootstrap')) {
            Assert-SkillTreeMatches -SkillName $SkillName -DestinationRoot $Root
        }
    }

    foreach ($Root in @($CurrentRoot, $LegacyRoot)) {
        $SentinelPath = Join-Path $Root 'unrelated-skill\SKILL.md'
        Assert-Condition (([System.IO.File]::ReadAllText($SentinelPath)) -ceq 'unrelated sentinel') "Installer changed an unrelated Antigravity skill: $SentinelPath"
        $BackupCount = @(Get-ChildItem -LiteralPath (Join-Path $Root 'wrap-up') -File -Filter 'SKILL.md.backup-*').Count
        Assert-Condition ($BackupCount -eq 1) "Installer did not create exactly one backup for the stale managed Antigravity skill in $Root"
    }

    Invoke-RepositoryScript -ScriptName 'verify.ps1' -Arguments @('-UserRoot', $TestUserRoot) | Out-Null
    $Before = Get-FileSnapshot -Root $TestUserRoot
    Invoke-RepositoryScript -ScriptName 'install.ps1' -Arguments @('-UserRoot', $TestUserRoot) | Out-Null
    $After = Get-FileSnapshot -Root $TestUserRoot
    Assert-Condition ((@(Compare-Object -ReferenceObject $Before -DifferenceObject $After)).Count -eq 0) 'Second installation changed files, hashes, or timestamps.'

    Write-Output '[PASS] Isolated installation populated Antigravity current and legacy skill roots, preserved unrelated skills, backed up stale managed copies, passed verification, and remained idempotent.'
} finally {
    if (Test-Path -LiteralPath $TestUserRoot) {
        Remove-Item -LiteralPath $TestUserRoot -Recurse -Force
    }
}
