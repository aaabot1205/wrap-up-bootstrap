$ErrorActionPreference = 'Stop'

$Manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'fixture.json') | ConvertFrom-Json
$PlanPath = Join-Path $PSScriptRoot ([string]$Manifest.documents.plan)
$PlanText = [System.IO.File]::ReadAllText($PlanPath)
$Match = [regex]::Match($PlanText, '(?s)<!-- BEGIN CONFIRMED PLAN -->\r?\n(.*?)<!-- END CONFIRMED PLAN -->')
if (-not $Match.Success) { throw 'Canonical plan markers are missing.' }
$ActualBody = $Match.Groups[1].Value
$ExpectedFile = if ($Manifest.scenario -ceq 'confirmed') { 'CONFIRMED_PLAN_BODY.txt' } else { 'BASELINE_PLAN_BODY.txt' }
$ExpectedBody = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot $ExpectedFile))
if ($ActualBody -cne $ExpectedBody) { throw 'Canonical plan body differs from the exact expected source.' }

$DraftText = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'UNCONFIRMED_DRAFT.md'))
$DraftMatch = [regex]::Match($DraftText, '(?m)^draft_sentinel:\s*(\S+)')
if (-not $DraftMatch.Success) { throw 'Draft sentinel is missing.' }
if ($PlanText.IndexOf($DraftMatch.Groups[1].Value, [System.StringComparison]::Ordinal) -ge 0) { throw 'Canonical plan contains unconfirmed draft content.' }

$ArtifactDirectory = Join-Path $PSScriptRoot '.test-artifacts'
New-Item -ItemType Directory -Force -Path $ArtifactDirectory | Out-Null
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $ArtifactDirectory 'verification-ran.txt'), "Plan Fidelity fixture verification passed.`n", $Utf8NoBom)
Write-Output 'Plan Fidelity fixture verification passed.'
