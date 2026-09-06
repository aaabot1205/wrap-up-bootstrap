$ErrorActionPreference = 'Stop'

$RuntimePath = Join-Path $PSScriptRoot 'config\runtime.json'
$Runtime = Get-Content -Raw -Encoding UTF8 -LiteralPath $RuntimePath | ConvertFrom-Json
if ($Runtime.mode -cne 'durable-v3') {
    throw "Expected durable-v3, got $($Runtime.mode)."
}

$ArtifactDirectory = Join-Path $PSScriptRoot '.test-artifacts'
New-Item -ItemType Directory -Force -Path $ArtifactDirectory | Out-Null
$MarkerPath = Join-Path $ArtifactDirectory 'verification-ran.txt'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($MarkerPath, "Fixture verification passed.`n", $Utf8NoBom)
Write-Output 'Fixture verification passed.'
