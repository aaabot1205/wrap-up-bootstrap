[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Repository,
    [Parameter(Mandatory = $true)][string]$SnapshotPath,
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath($Repository).TrimEnd('\', '/')
$Destination = [IO.Path]::GetFullPath($SnapshotPath)
$Prefix = $Root + [IO.Path]::DirectorySeparatorChar
if ($Destination.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The audit snapshot must be outside the receiving repository.'
}
if (-not (Test-Path -LiteralPath (Join-Path $Root '.git'))) { throw 'Repository must contain Git metadata.' }

function Read-Git {
    param([string[]]$Arguments)
    $Value = @(& git -C $Root @Arguments)
    if ($LASTEXITCODE -ne 0) { throw "Snapshot git command failed: $Arguments" }
    return ($Value -join "`n")
}

$Files = [ordered]@{}
foreach ($File in Get-ChildItem -LiteralPath $Root -Recurse -Force -File | Sort-Object FullName) {
    $Relative = $File.FullName.Substring($Prefix.Length).Replace('\', '/')
    if ($Relative -eq '.git' -or $Relative.StartsWith('.git/', [StringComparison]::Ordinal)) { continue }
    $Files[$Relative] = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash
}
$State = [ordered]@{
    files = $Files
    head = Read-Git @('rev-parse', 'HEAD')
    branch = Read-Git @('symbolic-ref', '--short', 'HEAD')
    index = Read-Git @('ls-files', '--stage')
    refs = Read-Git @('show-ref')
    remotes = Read-Git @('remote', '-v')
    status = Read-Git @('status', '--porcelain=v1', '--untracked-files=all')
}
$Json = $State | ConvertTo-Json -Depth 10
if ($Check) {
    $Original = [IO.File]::ReadAllText($Destination) | ConvertFrom-Json
    foreach ($Field in @('head', 'branch', 'index', 'refs', 'remotes', 'status')) {
        if (-not [string]::Equals([string]$State[$Field], [string]$Original.$Field, [StringComparison]::Ordinal)) {
            throw "Receiver changed snapshot field: $Field"
        }
    }
    $OriginalNames = @($Original.files.PSObject.Properties.Name | Sort-Object)
    $CurrentNames = @($Files.Keys | Sort-Object)
    if (@(Compare-Object -ReferenceObject $OriginalNames -DifferenceObject $CurrentNames).Count -ne 0) {
        throw 'Receiver changed the file set.'
    }
    foreach ($Name in $CurrentNames) {
        if (-not [string]::Equals([string]$Files[$Name], [string]$Original.files.$Name, [StringComparison]::Ordinal)) {
            throw "Receiver changed file content: $Name"
        }
    }
    Write-Output '[PASS] Receiver preserved complete file and Git snapshot.'
} else {
    if (Test-Path -LiteralPath $Destination) { throw 'Refusing to overwrite a baseline snapshot.' }
    [IO.File]::WriteAllText($Destination, $Json, (New-Object Text.UTF8Encoding($false)))
    Write-Output '[SNAPSHOT] Receiver baseline saved outside its repository.'
}
