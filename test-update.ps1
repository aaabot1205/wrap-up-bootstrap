[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$TempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$TestRoot = [System.IO.Path]::GetFullPath((Join-Path $TempRoot ("wrap-up-bootstrap-update-" + [guid]::NewGuid().ToString('N'))))
$SafePrefix = $TempRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $TestRoot.StartsWith($SafePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Refusing to use an unsafe test root.'
}

function Assert-Condition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Invoke-Git {
    param([string]$Repository, [string[]]$Arguments)

    $Output = @(& git -C $Repository @Arguments 2>&1)
    $ExitCode = $LASTEXITCODE
    if ($ExitCode -ne 0) {
        $Detail = ($Output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
        throw "git $($Arguments -join ' ') failed with exit code ${ExitCode}: $Detail"
    }
    return $Output
}

function Invoke-ClientScript {
    param([string]$ClientPath, [string]$ScriptName, [string[]]$ExtraArguments = @())

    $ScriptPath = Join-Path $ClientPath $ScriptName
    $PreviousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $Output = @(& powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @ExtraArguments 2>&1)
    } finally {
        $ErrorActionPreference = $PreviousPreference
    }
    return [PSCustomObject]@{
        ExitCode = $LASTEXITCODE
        Output   = @($Output | ForEach-Object { $_.ToString() })
    }
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

New-Item -ItemType Directory -Path $TestRoot | Out-Null
try {
    $BareOriginPath = Join-Path $TestRoot 'origin.git'
    $ClientPath = Join-Path $TestRoot 'client'
    $IsolatedUserRoot = Join-Path $TestRoot 'userroot'

    $HeadCommit = (Invoke-Git -Repository $ProjectRoot -Arguments @('rev-parse', 'HEAD') | Select-Object -First 1).ToString().Trim()

    Write-Output 'Selecting the most recent prior release tag as the old state to upgrade from...'
    $TagLines = @(Invoke-Git -Repository $ProjectRoot -Arguments @('for-each-ref', '--sort=-creatordate', '--format=%(refname:short) %(objectname) %(*objectname)', 'refs/tags'))
    $OldRef = $null
    foreach ($Line in $TagLines) {
        $Parts = @($Line -split '\s+' | Where-Object { $_ -ne '' })
        if ($Parts.Count -lt 2) { continue }
        $TagName = $Parts[0]
        $TagCommit = if ($Parts.Count -ge 3) { $Parts[2] } else { $Parts[1] }
        if ($TagCommit -ceq $HeadCommit) { continue }
        $IsAncestor = $true
        try {
            Invoke-Git -Repository $ProjectRoot -Arguments @('merge-base', '--is-ancestor', $TagCommit, 'HEAD') | Out-Null
        } catch {
            $IsAncestor = $false
        }
        if ($IsAncestor) {
            $OldRef = $TagName
            break
        }
    }
    Assert-Condition (-not [string]::IsNullOrWhiteSpace($OldRef)) 'No prior tag was found to use as the old release state.'
    Write-Output "Using '$OldRef' as the prior release state."

    Write-Output 'Creating an isolated bare origin seeded at the old release...'
    New-Item -ItemType Directory -Path $BareOriginPath -Force | Out-Null
    Invoke-Git -Repository $BareOriginPath -Arguments @('init', '--bare', '--quiet') | Out-Null
    Invoke-Git -Repository $BareOriginPath -Arguments @('symbolic-ref', 'HEAD', 'refs/heads/main') | Out-Null
    Invoke-Git -Repository $ProjectRoot -Arguments @('push', '--quiet', $BareOriginPath, "${OldRef}^{commit}:refs/heads/main") | Out-Null

    Write-Output 'Cloning an isolated client from the old release...'
    Invoke-Git -Repository $ProjectRoot -Arguments @('clone', '--quiet', $BareOriginPath, $ClientPath) | Out-Null
    Invoke-Git -Repository $ClientPath -Arguments @('config', 'user.email', 'test-update@wrap-up-bootstrap.local') | Out-Null
    Invoke-Git -Repository $ClientPath -Arguments @('config', 'user.name', 'test-update') | Out-Null

    Write-Output 'Seeding the isolated user root with the old release (so upgrading has something real to back up)...'
    $SeedResult = Invoke-ClientScript -ClientPath $ClientPath -ScriptName 'install.ps1' -ExtraArguments @('-UserRoot', $IsolatedUserRoot)
    Assert-Condition ($SeedResult.ExitCode -eq 0) "Seeding the isolated root with the old release failed: $($SeedResult.Output -join [Environment]::NewLine)"

    $OldVersion = ((Invoke-Git -Repository $ProjectRoot -Arguments @('show', "${OldRef}:VERSION")) -join "`n").Trim()
    $NewVersion = ((Invoke-Git -Repository $ProjectRoot -Arguments @('show', 'HEAD:VERSION')) -join "`n").Trim()
    Assert-Condition ($OldVersion -cne $NewVersion) "Chosen old ref '$OldRef' has the same VERSION as HEAD ($NewVersion); cannot exercise a real version transition."

    $SkillRoots = @(
        (Join-Path $IsolatedUserRoot '.agents\skills'),
        (Join-Path $IsolatedUserRoot '.claude\skills'),
        (Join-Path $IsolatedUserRoot '.gemini\config\skills'),
        (Join-Path $IsolatedUserRoot '.gemini\antigravity\skills')
    )
    $ChangedSkillFiles = @{}
    foreach ($SkillName in @('wrap-up', 'bootstrap')) {
        $OldContent = ((Invoke-Git -Repository $ProjectRoot -Arguments @('show', "${OldRef}:$SkillName/SKILL.md")) -join "`n")
        $NewContent = ((Invoke-Git -Repository $ProjectRoot -Arguments @('show', "HEAD:$SkillName/SKILL.md")) -join "`n")
        $ChangedSkillFiles[$SkillName] = ($OldContent -cne $NewContent)
    }

    Write-Output 'Advancing the isolated origin to the current canonical HEAD...'
    Invoke-Git -Repository $ProjectRoot -Arguments @('push', '--quiet', $BareOriginPath, 'HEAD:refs/heads/main') | Out-Null

    Write-Output 'Running update.ps1 -- the actual dry-run under test...'
    $UpdateResult = Invoke-ClientScript -ClientPath $ClientPath -ScriptName 'update.ps1' -ExtraArguments @('-UserRoot', $IsolatedUserRoot)
    $UpdateOutputText = $UpdateResult.Output -join [Environment]::NewLine
    Assert-Condition ($UpdateResult.ExitCode -eq 0) "update.ps1 dry-run failed unexpectedly: $UpdateOutputText"
    Assert-Condition ($UpdateOutputText -match [regex]::Escape("Version transition: $OldVersion -> $NewVersion")) "update.ps1 did not report the expected version transition. Output: $UpdateOutputText"

    foreach ($SkillName in @('wrap-up', 'bootstrap')) {
        if ($ChangedSkillFiles[$SkillName]) {
            foreach ($Root in $SkillRoots) {
                $BackupCount = @(Get-ChildItem -LiteralPath (Join-Path $Root $SkillName) -File -Filter 'SKILL.md.backup-*' -ErrorAction SilentlyContinue).Count
                Assert-Condition ($BackupCount -eq 1) "Expected exactly one backup for changed $SkillName/SKILL.md under $Root, found $BackupCount."
            }
        }
        foreach ($Root in $SkillRoots) {
            Assert-SkillTreeMatches -SkillName $SkillName -DestinationRoot $Root
        }
    }

    $ClientHead = (Invoke-Git -Repository $ClientPath -Arguments @('rev-parse', 'HEAD') | Select-Object -First 1).ToString().Trim()
    Assert-Condition ($ClientHead -ceq $HeadCommit) "Client did not fast-forward to the canonical HEAD ($HeadCommit); found $ClientHead."
    $ClientStatus = @(Invoke-Git -Repository $ClientPath -Arguments @('status', '--porcelain=v1', '--untracked-files=all'))
    Assert-Condition ($ClientStatus.Count -eq 0) 'Client worktree is not clean after update.ps1.'

    Write-Output 'Confirming update.ps1 refuses a dirty worktree...'
    $VersionFilePath = Join-Path $ClientPath 'VERSION'
    $OriginalVersionText = [System.IO.File]::ReadAllText($VersionFilePath)
    [System.IO.File]::AppendAllText($VersionFilePath, "`n")
    $DirtyResult = Invoke-ClientScript -ClientPath $ClientPath -ScriptName 'update.ps1' -ExtraArguments @('-UserRoot', $IsolatedUserRoot)
    $DirtyOutputText = $DirtyResult.Output -join [Environment]::NewLine
    Assert-Condition ($DirtyResult.ExitCode -ne 0) 'update.ps1 did not refuse a dirty worktree.'
    Assert-Condition ($DirtyOutputText -match 'staged, unstaged, or untracked changes') "update.ps1's dirty-tree refusal message did not match. Output: $DirtyOutputText"
    [System.IO.File]::WriteAllText($VersionFilePath, $OriginalVersionText)
    Invoke-Git -Repository $ClientPath -Arguments @('checkout', '--', 'VERSION') | Out-Null

    Write-Output 'Confirming update.ps1 refuses a branch that is ahead of its upstream...'
    [System.IO.File]::AppendAllText((Join-Path $ClientPath 'VERSION'), "`n")
    Invoke-Git -Repository $ClientPath -Arguments @('commit', '-am', 'local-only test commit') | Out-Null
    $AheadResult = Invoke-ClientScript -ClientPath $ClientPath -ScriptName 'update.ps1' -ExtraArguments @('-UserRoot', $IsolatedUserRoot)
    $AheadOutputText = $AheadResult.Output -join [Environment]::NewLine
    Assert-Condition ($AheadResult.ExitCode -ne 0) 'update.ps1 did not refuse an ahead-of-upstream local branch.'
    Assert-Condition ($AheadOutputText -match 'ahead of') "update.ps1's ahead-of-upstream refusal message did not match. Output: $AheadOutputText"

    Write-Output "[PASS] Isolated dry-run upgraded from '$OldRef' ($OldVersion) to HEAD ($NewVersion): version transition reported, backups created for changed skills, all installed files match canonical, and update.ps1 correctly refused both a dirty worktree and an ahead-of-upstream branch."
} finally {
    if (Test-Path -LiteralPath $TestRoot) {
        Remove-Item -LiteralPath $TestRoot -Recurse -Force
    }
}
