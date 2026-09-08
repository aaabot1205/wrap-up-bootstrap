[CmdletBinding()]
param(
    [ValidateSet('Validate', 'Prepare', 'Check')]
    [string]$Mode = 'Validate',
    [string]$WorkspaceRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$FixtureRoot = Join-Path $ProjectRoot 'tests\fixtures\plan-fidelity'
$TemplateRoot = Join-Path $FixtureRoot 'template'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$ExpectedScenarios = [ordered]@{
    'codex-to-claude' = @('Codex', 'Claude Code', 'confirmed')
    'codex-to-antigravity' = @('Codex', 'Antigravity', 'confirmed')
    'claude-to-codex' = @('Claude Code', 'Codex', 'confirmed')
    'claude-to-antigravity' = @('Claude Code', 'Antigravity', 'unconfirmed-only')
    'antigravity-to-codex' = @('Antigravity', 'Codex', 'unconfirmed-only')
    'antigravity-to-claude' = @('Antigravity', 'Claude Code', 'unconfirmed-only')
}

function Assert-Condition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Resolve-SafeChildPath {
    param([string]$BasePath, [string]$RelativePath, [string]$Description)

    Assert-Condition (-not [string]::IsNullOrWhiteSpace($RelativePath)) "$Description is empty."
    Assert-Condition (-not [System.IO.Path]::IsPathRooted($RelativePath)) "$Description must be repository-relative: $RelativePath"
    $ResolvedBase = [System.IO.Path]::GetFullPath($BasePath)
    $ResolvedPath = [System.IO.Path]::GetFullPath((Join-Path $ResolvedBase $RelativePath))
    $Prefix = $ResolvedBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    Assert-Condition ($ResolvedPath.StartsWith($Prefix, [System.StringComparison]::OrdinalIgnoreCase)) "$Description escapes its fixture root: $RelativePath"
    return $ResolvedPath
}

function Invoke-Git {
    param([string]$Repository, [string[]]$Arguments)

    $PreviousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $Output = @(& git -C $Repository @Arguments 2>&1)
        $ExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $PreviousErrorActionPreference
    }
    if ($ExitCode -ne 0) {
        $Detail = ($Output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
        throw "git $($Arguments -join ' ') failed with exit code ${ExitCode}: $Detail"
    }
    return @($Output | Where-Object { -not $_.ToString().StartsWith('warning: ', [System.StringComparison]::OrdinalIgnoreCase) })
}

function Get-PlanBody {
    param([string]$Path)

    $Text = [System.IO.File]::ReadAllText($Path)
    $Pattern = '(?s)<!-- BEGIN CONFIRMED PLAN -->\r?\n(.*?)<!-- END CONFIRMED PLAN -->'
    $Match = [regex]::Match($Text, $Pattern)
    Assert-Condition $Match.Success "Plan markers are missing or malformed: $Path"
    Assert-Condition ([regex]::Matches($Text, $Pattern).Count -eq 1) "Plan markers are not unique: $Path"
    return $Match.Groups[1].Value
}

function Get-FixtureDefinitions {
    $ScenarioDirectories = @(Get-ChildItem -LiteralPath $FixtureRoot -Directory | Where-Object { $_.Name -cne 'template' })
    $ActualIds = @($ScenarioDirectories.Name | Sort-Object)
    $ExpectedIds = @($ExpectedScenarios.Keys | Sort-Object)
    Assert-Condition ((@(Compare-Object $ExpectedIds $ActualIds)).Count -eq 0) 'Plan Fidelity fixture directories do not match the six required source-to-receiver directions.'

    $Definitions = @()
    foreach ($Id in $ExpectedScenarios.Keys) {
        $Directory = Join-Path $FixtureRoot $Id
        $ManifestPath = Join-Path $Directory 'fixture.json'
        Assert-Condition (Test-Path -LiteralPath $ManifestPath -PathType Leaf) "Fixture manifest is missing: $ManifestPath"
        try {
            $Manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $ManifestPath | ConvertFrom-Json
        } catch {
            throw "Fixture manifest is invalid JSON: $ManifestPath. $($_.Exception.Message)"
        }

        $Expected = $ExpectedScenarios[$Id]
        Assert-Condition ($Manifest.id -ceq $Id) "Fixture id does not match its directory: $Id"
        Assert-Condition ($Manifest.source_platform -ceq $Expected[0]) "Fixture $Id has the wrong source platform."
        Assert-Condition ($Manifest.receiver_platform -ceq $Expected[1]) "Fixture $Id has the wrong receiver platform."
        Assert-Condition ($Manifest.scenario -ceq $Expected[2]) "Fixture $Id has the wrong Plan Fidelity scenario."
        Assert-Condition ($Manifest.source_platform -cne $Manifest.receiver_platform) "Fixture $Id is not a cross-platform direction."

        $RelativePaths = @(
            [string]$Manifest.instruction_file,
            [string]$Manifest.documents.status,
            [string]$Manifest.documents.handoff,
            [string]$Manifest.documents.plan
        )
        foreach ($RelativePath in $RelativePaths) {
            Resolve-SafeChildPath -BasePath $Directory -RelativePath $RelativePath -Description "Fixture $Id path" | Out-Null
        }
        Assert-Condition ((@($RelativePaths | Sort-Object -Unique)).Count -eq 4) "Fixture $Id repeats an instruction or document path."

        $Definitions += [pscustomobject]@{ Id = $Id; ManifestPath = $ManifestPath; Manifest = $Manifest }
    }
    return $Definitions
}

function Test-CanonicalFixtures {
    $RequiredTemplates = @(
        '.gitignore',
        'INSTRUCTIONS_TEMPLATE.md',
        'STATUS_TEMPLATE.md',
        'HANDOFF_TEMPLATE.md',
        'PLAN_TEMPLATE.md',
        'CONFIRMATION_TEMPLATE.md',
        'CONFIRMED_PLAN_BODY.txt',
        'BASELINE_PLAN_BODY.txt',
        'UNCONFIRMED_DRAFT.md',
        'PROJECT_CONTEXT_TEMPLATE.yaml',
        'verify.ps1'
    )
    foreach ($TemplateName in $RequiredTemplates) {
        Assert-Condition (Test-Path -LiteralPath (Join-Path $TemplateRoot $TemplateName) -PathType Leaf) "Fixture template is missing: $TemplateName"
    }

    $ConfirmedBody = [System.IO.File]::ReadAllText((Join-Path $TemplateRoot 'CONFIRMED_PLAN_BODY.txt'))
    $BaselineBody = [System.IO.File]::ReadAllText((Join-Path $TemplateRoot 'BASELINE_PLAN_BODY.txt'))
    $DraftText = [System.IO.File]::ReadAllText((Join-Path $TemplateRoot 'UNCONFIRMED_DRAFT.md'))
    Assert-Condition (-not [string]::IsNullOrWhiteSpace($ConfirmedBody)) 'Confirmed-plan source is empty.'
    Assert-Condition (-not [string]::IsNullOrWhiteSpace($BaselineBody)) 'Baseline-plan source is empty.'
    Assert-Condition ($ConfirmedBody -cne $BaselineBody) 'Confirmed and baseline plan bodies must differ.'
    Assert-Condition ($DraftText -match '(?m)^draft_sentinel:\s*\S+') 'Unconfirmed draft does not declare a sentinel.'

    return @(Get-FixtureDefinitions)
}

function Expand-Template {
    param([string]$TemplatePath, [string]$DestinationPath, [hashtable]$Replacements)

    $Text = Get-Content -Raw -Encoding UTF8 -LiteralPath $TemplatePath
    foreach ($Key in $Replacements.Keys) { $Text = $Text.Replace($Key, $Replacements[$Key]) }
    $DestinationParent = Split-Path -Parent $DestinationPath
    New-Item -ItemType Directory -Force -Path $DestinationParent | Out-Null
    [System.IO.File]::WriteAllText($DestinationPath, $Text, $Utf8NoBom)
}

function Prepare-Workspaces {
    param([object[]]$Definitions, [string]$DestinationRoot)

    Assert-Condition (-not [string]::IsNullOrWhiteSpace($DestinationRoot)) 'Prepare mode requires -WorkspaceRoot.'
    $ResolvedRoot = [System.IO.Path]::GetFullPath($DestinationRoot)
    Assert-Condition ($ResolvedRoot -cne [System.IO.Path]::GetPathRoot($ResolvedRoot)) 'WorkspaceRoot may not be a filesystem root.'
    Assert-Condition (-not (Test-Path -LiteralPath $ResolvedRoot)) "WorkspaceRoot already exists; refusing to overwrite it: $ResolvedRoot"
    New-Item -ItemType Directory -Path $ResolvedRoot | Out-Null

    foreach ($Definition in $Definitions) {
        $Manifest = $Definition.Manifest
        $Repository = Join-Path $ResolvedRoot $Definition.Id
        New-Item -ItemType Directory -Path $Repository | Out-Null
        $IsConfirmed = $Manifest.scenario -ceq 'confirmed'
        $ScenarioInstruction = if ($IsConfirmed) {
            'The durable `CONFIRMATION.md` records the user''s explicit confirmation and points to the exact confirmed text in `CONFIRMED_PLAN_BODY.txt`. Preserve that text verbatim.'
        } else {
            'No exact user-confirmed plan text is available. `UNCONFIRMED_DRAFT.md` is AI-authored and unconfirmed. Leave the canonical plan body unchanged and record a Blocked result.'
        }
        $Replacements = @{
            '{{SOURCE_PLATFORM}}' = [string]$Manifest.source_platform
            '{{RECEIVER_PLATFORM}}' = [string]$Manifest.receiver_platform
            '{{STATUS_FILE}}' = [string]$Manifest.documents.status
            '{{HANDOFF_FILE}}' = [string]$Manifest.documents.handoff
            '{{PLAN_FILE}}' = [string]$Manifest.documents.plan
            '{{SCENARIO_INSTRUCTION}}' = $ScenarioInstruction
        }
        $GeneratedFiles = [ordered]@{
            'INSTRUCTIONS_TEMPLATE.md' = [string]$Manifest.instruction_file
            'STATUS_TEMPLATE.md' = [string]$Manifest.documents.status
            'HANDOFF_TEMPLATE.md' = [string]$Manifest.documents.handoff
            'PLAN_TEMPLATE.md' = [string]$Manifest.documents.plan
            'PROJECT_CONTEXT_TEMPLATE.yaml' = 'PROJECT_CONTEXT.yaml'
        }
        foreach ($Entry in $GeneratedFiles.GetEnumerator()) {
            $DestinationPath = Resolve-SafeChildPath -BasePath $Repository -RelativePath $Entry.Value -Description "Prepared fixture $($Definition.Id) path"
            Expand-Template -TemplatePath (Join-Path $TemplateRoot $Entry.Key) -DestinationPath $DestinationPath -Replacements $Replacements
        }

        foreach ($TemplateName in @('.gitignore', 'BASELINE_PLAN_BODY.txt', 'UNCONFIRMED_DRAFT.md', 'verify.ps1')) {
            Copy-Item -LiteralPath (Join-Path $TemplateRoot $TemplateName) -Destination (Join-Path $Repository $TemplateName)
        }
        if ($IsConfirmed) {
            Copy-Item -LiteralPath (Join-Path $TemplateRoot 'CONFIRMED_PLAN_BODY.txt') -Destination (Join-Path $Repository 'CONFIRMED_PLAN_BODY.txt')
            Copy-Item -LiteralPath (Join-Path $TemplateRoot 'CONFIRMATION_TEMPLATE.md') -Destination (Join-Path $Repository 'CONFIRMATION.md')
        }
        Copy-Item -LiteralPath $Definition.ManifestPath -Destination (Join-Path $Repository 'fixture.json')

        Invoke-Git -Repository $Repository -Arguments @('init', '-b', 'main') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('config', 'user.name', 'Plan Fidelity Fixture') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('config', 'user.email', 'fixture@example.invalid') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('config', 'core.autocrlf', 'false') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('add', '--all') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('commit', '-m', "fixture: initialize $($Definition.Id)") | Out-Null
        Write-Output "[PREPARED] $($Definition.Id): $Repository"
    }
    Write-Output "Prepared $($Definitions.Count) isolated Plan Fidelity workspaces under $ResolvedRoot"
}

function Test-EvidenceLabel {
    param([string]$Text, [string]$Label)
    $Pattern = '(?im)(?:^|\|)\s*(?:[-*]\s*)?(?:\*\*|`)?{0}(?:\*\*|`)?\s*(?::|\|)' -f [regex]::Escape($Label)
    return [regex]::IsMatch($Text, $Pattern)
}

function Test-WorkspaceResults {
    param([object[]]$Definitions, [string]$ResultsRoot)

    Assert-Condition (-not [string]::IsNullOrWhiteSpace($ResultsRoot)) 'Check mode requires -WorkspaceRoot.'
    $ResolvedRoot = [System.IO.Path]::GetFullPath($ResultsRoot)
    Assert-Condition (Test-Path -LiteralPath $ResolvedRoot -PathType Container) "WorkspaceRoot does not exist: $ResolvedRoot"

    $PassCount = 0
    foreach ($Definition in $Definitions) {
        $Manifest = $Definition.Manifest
        $Repository = Join-Path $ResolvedRoot $Definition.Id
        Assert-Condition (Test-Path -LiteralPath (Join-Path $Repository '.git') -PathType Container) "Prepared fixture is not a Git repository: $Repository"

        $PlanPath = Resolve-SafeChildPath -BasePath $Repository -RelativePath ([string]$Manifest.documents.plan) -Description "Result fixture $($Definition.Id) plan"
        $ActualBody = Get-PlanBody -Path $PlanPath
        $ExpectedSource = if ($Manifest.scenario -ceq 'confirmed') { 'CONFIRMED_PLAN_BODY.txt' } else { 'BASELINE_PLAN_BODY.txt' }
        $ExpectedBody = [System.IO.File]::ReadAllText((Join-Path $Repository $ExpectedSource))
        Assert-Condition ($ActualBody -ceq $ExpectedBody) "Fixture $($Definition.Id) did not preserve the required plan body character-for-character."

        $DraftText = [System.IO.File]::ReadAllText((Join-Path $Repository 'UNCONFIRMED_DRAFT.md'))
        $DraftMatch = [regex]::Match($DraftText, '(?m)^draft_sentinel:\s*(\S+)')
        Assert-Condition $DraftMatch.Success "Fixture $($Definition.Id) draft sentinel is missing."
        Assert-Condition ([System.IO.File]::ReadAllText($PlanPath).IndexOf($DraftMatch.Groups[1].Value, [System.StringComparison]::Ordinal) -lt 0) "Fixture $($Definition.Id) copied unconfirmed draft content into the canonical plan."

        $StatusPath = Resolve-SafeChildPath -BasePath $Repository -RelativePath ([string]$Manifest.documents.status) -Description "Result fixture $($Definition.Id) status"
        $HandoffPath = Resolve-SafeChildPath -BasePath $Repository -RelativePath ([string]$Manifest.documents.handoff) -Description "Result fixture $($Definition.Id) handoff"
        $CombinedText = ([System.IO.File]::ReadAllText($StatusPath)) + "`n" + ([System.IO.File]::ReadAllText($HandoffPath))
        $RequiredLabels = if ($Manifest.scenario -ceq 'confirmed') { @('Verified', 'Observed') } else { @('Verified', 'Observed', 'Blocked') }
        foreach ($Label in $RequiredLabels) {
            Assert-Condition (Test-EvidenceLabel -Text $CombinedText -Label $Label) "Fixture $($Definition.Id) does not record evidence label '$Label'."
        }

        $MarkerPath = Join-Path $Repository '.test-artifacts\verification-ran.txt'
        Assert-Condition (Test-Path -LiteralPath $MarkerPath -PathType Leaf) "Fixture $($Definition.Id) did not execute its documented verification command."
        Assert-Condition (([System.IO.File]::ReadAllText($MarkerPath)) -match 'Plan Fidelity fixture verification passed') "Fixture $($Definition.Id) verification marker is invalid."

        $CommitCount = [int]((Invoke-Git -Repository $Repository -Arguments @('rev-list', '--count', 'HEAD') | Select-Object -First 1).ToString().Trim())
        Assert-Condition ($CommitCount -eq 1) "Fixture $($Definition.Id) created a commit in non-publishing plan mode."
        Assert-Condition ((@(Invoke-Git -Repository $Repository -Arguments @('diff', '--cached', '--name-only'))).Count -eq 0) "Fixture $($Definition.Id) staged files in non-publishing plan mode."
        $UntrackedPaths = @(Invoke-Git -Repository $Repository -Arguments @('ls-files', '--others', '--exclude-standard'))
        Assert-Condition ($UntrackedPaths.Count -eq 0) "Fixture $($Definition.Id) created replacement or other untracked files: $($UntrackedPaths -join ', ')"

        $ExpectedChangedPaths = @([string]$Manifest.documents.status, [string]$Manifest.documents.handoff)
        if ($Manifest.scenario -ceq 'confirmed') { $ExpectedChangedPaths += [string]$Manifest.documents.plan }
        $ChangedPaths = @(Invoke-Git -Repository $Repository -Arguments @('diff', '--name-only')) | Sort-Object
        Assert-Condition ((@(Compare-Object ($ExpectedChangedPaths | Sort-Object) $ChangedPaths)).Count -eq 0) "Fixture $($Definition.Id) changed files outside its expected Plan Fidelity scope."

        $PassCount++
        Write-Output "[PASS] $($Definition.Id): $($Manifest.source_platform) -> $($Manifest.receiver_platform) [$($Manifest.scenario)]"
    }
    Write-Output "Plan Fidelity summary: $PassCount passed, 0 failed."
}

try {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is not available on PATH.' }
    $Definitions = @(Test-CanonicalFixtures)
    switch ($Mode) {
        'Validate' { Write-Output "[PASS] Canonical Plan Fidelity matrix contains all $($Definitions.Count) directed cross-platform fixtures." }
        'Prepare' { Prepare-Workspaces -Definitions $Definitions -DestinationRoot $WorkspaceRoot }
        'Check' { Test-WorkspaceResults -Definitions $Definitions -ResultsRoot $WorkspaceRoot }
    }
    exit 0
} catch {
    [Console]::Error.WriteLine("Plan Fidelity regression $Mode failed: $($_.Exception.Message)")
    exit 1
}
