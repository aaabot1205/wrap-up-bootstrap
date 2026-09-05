[CmdletBinding()]
param(
    [string]$UserRoot = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
)

Set-StrictMode -Version Latest

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Backup-FileIfChanged {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    if (-not (Test-Path -LiteralPath $DestinationPath)) {
        return
    }

    $SourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourcePath).Hash
    $DestinationHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $DestinationPath).Hash
    if ($SourceHash -ne $DestinationHash) {
        Copy-Item -LiteralPath $DestinationPath -Destination "$DestinationPath.backup-$Timestamp" -ErrorAction Stop
    }
}

function Sync-Skill {
    param(
        [string]$SkillName,
        [string]$DestinationRoot
    )

    $SourceDirectory = Join-Path $ProjectRoot $SkillName
    $DestinationDirectory = Join-Path $DestinationRoot $SkillName
    New-Item -ItemType Directory -Force -Path $DestinationDirectory -ErrorAction Stop | Out-Null

    foreach ($SourceFile in Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File) {
        $RelativePath = $SourceFile.FullName.Substring($SourceDirectory.Length).TrimStart('\')
        $DestinationFile = Join-Path $DestinationDirectory $RelativePath
        $DestinationParent = Split-Path -Parent $DestinationFile
        New-Item -ItemType Directory -Force -Path $DestinationParent -ErrorAction Stop | Out-Null

        Backup-FileIfChanged -SourcePath $SourceFile.FullName -DestinationPath $DestinationFile
        Copy-Item -LiteralPath $SourceFile.FullName -Destination $DestinationFile -Force -ErrorAction Stop
    }
}

function Install-ManagedRule {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $BeginMarker = '<!-- BEGIN wrap-up-bootstrap: response-language -->'
    $EndMarker = '<!-- END wrap-up-bootstrap: response-language -->'
    $ManagedBlock = (Get-Content -Raw -Encoding UTF8 -LiteralPath $SourcePath).Trim()
    $UnmarkedBlock = $ManagedBlock.Replace($BeginMarker, '').Replace($EndMarker, '').Trim()
    $Existing = if (Test-Path -LiteralPath $DestinationPath) {
        Get-Content -Raw -Encoding UTF8 -LiteralPath $DestinationPath
    } else {
        ''
    }

    $Pattern = '(?s)' + [regex]::Escape($BeginMarker) + '.*?' + [regex]::Escape($EndMarker)
    if ($Existing -match $Pattern) {
        $Updated = [regex]::Replace(
            $Existing,
            $Pattern,
            [System.Text.RegularExpressions.MatchEvaluator]{ param($Match) $ManagedBlock }
        )
    } elseif ($Existing.Trim() -eq $UnmarkedBlock) {
        $Updated = "$ManagedBlock`n"
    } elseif ([string]::IsNullOrWhiteSpace($Existing)) {
        $Updated = "$ManagedBlock`n"
    } else {
        $Updated = $Existing.TrimEnd() + "`n`n" + $ManagedBlock + "`n"
    }

    if ($Updated -ceq $Existing) {
        return
    }

    $DestinationParent = Split-Path -Parent $DestinationPath
    New-Item -ItemType Directory -Force -Path $DestinationParent -ErrorAction Stop | Out-Null
    if (Test-Path -LiteralPath $DestinationPath) {
        Copy-Item -LiteralPath $DestinationPath -Destination "$DestinationPath.backup-$Timestamp" -ErrorAction Stop
    }
    [System.IO.File]::WriteAllText($DestinationPath, $Updated, $Utf8NoBom)
}

$SkillRoots = @(
    (Join-Path $UserRoot '.agents\skills'),
    (Join-Path $UserRoot '.claude\skills'),
    (Join-Path $UserRoot '.gemini\antigravity\skills')
)

foreach ($SkillRoot in $SkillRoots) {
    Sync-Skill -SkillName 'wrap-up' -DestinationRoot $SkillRoot
    Sync-Skill -SkillName 'bootstrap' -DestinationRoot $SkillRoot
}

Install-ManagedRule -SourcePath (Join-Path $ProjectRoot 'global-rules\AGENTS.md') -DestinationPath (Join-Path $UserRoot '.codex\AGENTS.md')
Install-ManagedRule -SourcePath (Join-Path $ProjectRoot 'global-rules\CLAUDE.md') -DestinationPath (Join-Path $UserRoot '.claude\CLAUDE.md')
Install-ManagedRule -SourcePath (Join-Path $ProjectRoot 'global-rules\GEMINI.md') -DestinationPath (Join-Path $UserRoot '.gemini\GEMINI.md')

Write-Output 'Installed wrap-up, bootstrap, and response-language rules for Codex, Claude Code, and Antigravity.'
Write-Output 'Restart each platform or begin a new session to load the global instructions.'
