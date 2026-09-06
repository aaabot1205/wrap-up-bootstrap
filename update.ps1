[CmdletBinding()]
param(
    [string]$UserRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($UserRoot)) {
    $UserRoot = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
}
if ([string]::IsNullOrWhiteSpace($UserRoot)) {
    $UserRoot = [Environment]::GetEnvironmentVariable('USERPROFILE')
}
if ([string]::IsNullOrWhiteSpace($UserRoot)) {
    throw 'Unable to determine the user profile directory. Pass -UserRoot explicitly.'
}

$ProjectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$ResolvedUserRoot = [System.IO.Path]::GetFullPath($UserRoot)
$InstallScript = Join-Path $ProjectRoot 'install.ps1'
$VerifyScript = Join-Path $ProjectRoot 'verify.ps1'
$VersionPath = Join-Path $ProjectRoot 'VERSION'

function Invoke-Git {
    param([string[]]$Arguments)

    $Output = @(& git -C $ProjectRoot @Arguments 2>&1)
    $ExitCode = $LASTEXITCODE
    if ($ExitCode -ne 0) {
        $Detail = ($Output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
        throw "git $($Arguments -join ' ') failed with exit code ${ExitCode}: $Detail"
    }
    return $Output
}

function Get-CurrentVersion {
    if (-not (Test-Path -LiteralPath $VersionPath -PathType Leaf)) {
        return '(missing)'
    }
    return (Get-Content -Raw -Encoding UTF8 -LiteralPath $VersionPath).Trim()
}

function Get-PowerShellExecutable {
    $PowerShellCore = Join-Path $PSHOME 'pwsh.exe'
    if (Test-Path -LiteralPath $PowerShellCore -PathType Leaf) {
        return $PowerShellCore
    }

    $WindowsPowerShell = Join-Path $PSHOME 'powershell.exe'
    if (Test-Path -LiteralPath $WindowsPowerShell -PathType Leaf) {
        return $WindowsPowerShell
    }

    throw 'Unable to locate the current PowerShell executable.'
}

function Invoke-ProjectScript {
    param(
        [string]$PowerShellExecutable,
        [string]$ScriptPath
    )

    $Output = @(& $PowerShellExecutable -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -UserRoot $ResolvedUserRoot 2>&1)
    $ExitCode = $LASTEXITCODE
    $Output | ForEach-Object { Write-Output $_ }
    if ($ExitCode -ne 0) {
        throw "$([System.IO.Path]::GetFileName($ScriptPath)) failed with exit code $ExitCode."
    }
}

try {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'Git is not available on PATH.'
    }
    foreach ($RequiredPath in @($InstallScript, $VerifyScript)) {
        if (-not (Test-Path -LiteralPath $RequiredPath -PathType Leaf)) {
            throw "Required script is missing: $RequiredPath"
        }
    }

    $InsideWorkTree = (Invoke-Git -Arguments @('rev-parse', '--is-inside-work-tree') | Select-Object -First 1).ToString().Trim()
    if ($InsideWorkTree -cne 'true') {
        throw "$ProjectRoot is not a Git working tree."
    }

    try {
        $Branch = (Invoke-Git -Arguments @('symbolic-ref', '--quiet', '--short', 'HEAD') | Select-Object -First 1).ToString().Trim()
    } catch {
        throw 'The repository is in detached HEAD state; update without switching branches is unsafe.'
    }
    if ([string]::IsNullOrWhiteSpace($Branch)) {
        throw 'The repository is in detached HEAD state; update without switching branches is unsafe.'
    }

    $WorktreeState = @(Invoke-Git -Arguments @('status', '--porcelain=v1', '--untracked-files=all'))
    if ($WorktreeState.Count -gt 0) {
        throw 'The repository has staged, unstaged, or untracked changes. Preserve or commit them before updating.'
    }

    try {
        $Upstream = (Invoke-Git -Arguments @('rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}') | Select-Object -First 1).ToString().Trim()
    } catch {
        throw "Branch '$Branch' has no readable upstream. Configure one before updating."
    }
    if ([string]::IsNullOrWhiteSpace($Upstream)) {
        throw "Branch '$Branch' has no configured upstream."
    }

    $PreviousVersion = Get-CurrentVersion
    Write-Output "Updating $ProjectRoot"
    Write-Output "Branch: $Branch"
    Write-Output "Upstream: $Upstream"
    Write-Output "Version before update: $PreviousVersion"

    Write-Output 'Fetching upstream state...'
    Invoke-Git -Arguments @('fetch', '--quiet') | Out-Null

    $CountsLine = (Invoke-Git -Arguments @('rev-list', '--left-right', '--count', 'HEAD...@{u}') | Select-Object -First 1).ToString().Trim()
    $Counts = @($CountsLine -split '\s+')
    if ($Counts.Count -ne 2) {
        throw "Unable to determine ahead/behind state: $CountsLine"
    }
    $Ahead = [int]$Counts[0]
    $Behind = [int]$Counts[1]
    if ($Ahead -gt 0) {
        throw "Local branch '$Branch' is ahead of '$Upstream' by $Ahead commit(s). Refusing to install unpublished or divergent local state."
    }

    if ($Behind -gt 0) {
        Write-Output "Fast-forwarding by $Behind commit(s)..."
        Invoke-Git -Arguments @('merge', '--ff-only', '@{u}') | ForEach-Object { Write-Output $_ }
    } else {
        Write-Output 'Repository is already current.'
    }

    $PostUpdateState = @(Invoke-Git -Arguments @('status', '--porcelain=v1', '--untracked-files=all'))
    if ($PostUpdateState.Count -gt 0) {
        throw 'Repository update did not leave a clean worktree; global installation was not started.'
    }

    $CurrentVersion = Get-CurrentVersion
    $PowerShellExecutable = Get-PowerShellExecutable
    Write-Output 'Installing canonical files. Changed existing global files are backed up beside their destinations.'
    Invoke-ProjectScript -PowerShellExecutable $PowerShellExecutable -ScriptPath $InstallScript

    Write-Output 'Verifying installation...'
    Invoke-ProjectScript -PowerShellExecutable $PowerShellExecutable -ScriptPath $VerifyScript

    Write-Output "Version transition: $PreviousVersion -> $CurrentVersion"
    Write-Output "Update completed successfully on branch '$Branch' from '$Upstream'."
    exit 0
} catch {
    [Console]::Error.WriteLine("Update failed safely: $($_.Exception.Message)")
    exit 1
}
