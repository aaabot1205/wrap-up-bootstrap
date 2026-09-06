[CmdletBinding()]
param(
    [ValidateSet('Validate', 'Prepare', 'Check')]
    [string]$Mode = 'Validate',
    [string]$WorkspaceRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$FixtureRoot = Join-Path $ProjectRoot 'tests\fixtures\takeover'
$TemplateRoot = Join-Path $FixtureRoot 'template'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$RequiredResultLabels = @('Verified', 'Observed', 'Not run', 'Blocked')
$ExpectedScenarios = [ordered]@{
    'codex-to-claude' = @('Codex', 'Claude Code')
    'codex-to-antigravity' = @('Codex', 'Antigravity')
    'claude-to-codex' = @('Claude Code', 'Codex')
    'claude-to-antigravity' = @('Claude Code', 'Antigravity')
    'antigravity-to-codex' = @('Antigravity', 'Codex')
    'antigravity-to-claude' = @('Antigravity', 'Claude Code')
}

function Assert-Condition {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Resolve-SafeChildPath {
    param(
        [string]$BasePath,
        [string]$RelativePath,
        [string]$Description
    )

    Assert-Condition (-not [string]::IsNullOrWhiteSpace($RelativePath)) "$Description is empty."
    Assert-Condition (-not [System.IO.Path]::IsPathRooted($RelativePath)) "$Description must be repository-relative: $RelativePath"
    $ResolvedBase = [System.IO.Path]::GetFullPath($BasePath)
    $ResolvedPath = [System.IO.Path]::GetFullPath((Join-Path $ResolvedBase $RelativePath))
    $Prefix = $ResolvedBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    Assert-Condition ($ResolvedPath.StartsWith($Prefix, [System.StringComparison]::OrdinalIgnoreCase)) "$Description escapes its fixture root: $RelativePath"
    return $ResolvedPath
}

function Invoke-Git {
    param(
        [string]$Repository,
        [string[]]$Arguments
    )

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

function Get-FixtureDefinitions {
    $ScenarioDirectories = @(Get-ChildItem -LiteralPath $FixtureRoot -Directory | Where-Object { $_.Name -cne 'template' })
    $ActualIds = @($ScenarioDirectories.Name | Sort-Object)
    $ExpectedIds = @($ExpectedScenarios.Keys | Sort-Object)
    $DirectoryDelta = @(Compare-Object $ExpectedIds $ActualIds)
    Assert-Condition ($DirectoryDelta.Count -eq 0) 'Takeover fixture directories do not match the six required source-to-receiver directions.'

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

        $ExpectedPair = $ExpectedScenarios[$Id]
        Assert-Condition ($Manifest.id -ceq $Id) "Fixture id does not match its directory: $Id"
        Assert-Condition ($Manifest.source_platform -ceq $ExpectedPair[0]) "Fixture $Id has the wrong source platform."
        Assert-Condition ($Manifest.receiver_platform -ceq $ExpectedPair[1]) "Fixture $Id has the wrong receiver platform."
        Assert-Condition ($Manifest.source_platform -cne $Manifest.receiver_platform) "Fixture $Id is not a cross-platform direction."

        $RelativePaths = @(
            [string]$Manifest.instruction_file,
            [string]$Manifest.documents.status,
            [string]$Manifest.documents.spec,
            [string]$Manifest.documents.handoff
        )
        foreach ($RelativePath in $RelativePaths) {
            Resolve-SafeChildPath -BasePath $Directory -RelativePath $RelativePath -Description "Fixture $Id path" | Out-Null
        }
        Assert-Condition ((@($RelativePaths | Sort-Object -Unique)).Count -eq 4) "Fixture $Id repeats an instruction or document path."

        $Definitions += [pscustomobject]@{
            Id = $Id
            Directory = $Directory
            ManifestPath = $ManifestPath
            Manifest = $Manifest
        }
    }
    return $Definitions
}

function Test-CanonicalFixtures {
    $RequiredTemplates = @(
        '.gitignore',
        'INSTRUCTIONS_TEMPLATE.md',
        'STATUS_TEMPLATE.md',
        'SPEC_TEMPLATE.md',
        'HANDOFF_TEMPLATE.md',
        'runtime.json',
        'approval.json',
        'verify.ps1'
    )
    foreach ($TemplateName in $RequiredTemplates) {
        $TemplatePath = Join-Path $TemplateRoot $TemplateName
        Assert-Condition (Test-Path -LiteralPath $TemplatePath -PathType Leaf) "Fixture template is missing: $TemplatePath"
    }

    $StatusTemplate = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $TemplateRoot 'STATUS_TEMPLATE.md')
    $SpecTemplate = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $TemplateRoot 'SPEC_TEMPLATE.md')
    $HandoffTemplate = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $TemplateRoot 'HANDOFF_TEMPLATE.md')
    Assert-Condition ($StatusTemplate -match 'implementation_state:\s*in-progress') 'Status template no longer contains the intentional implementation-state contradiction.'
    Assert-Condition ($StatusTemplate -match 'runtime_mode:\s*legacy-v1') 'Status template no longer contains the intentional runtime contradiction.'
    Assert-Condition ($StatusTemplate -match '(?i)Assumption:') 'Status template no longer contains the explicit unverified assumption.'
    Assert-Condition ($SpecTemplate -match 'durable-v3') 'Spec template does not define the durable-v3 target.'
    Assert-Condition ($SpecTemplate -match '(?i)Not run') 'Spec template does not identify the initially unexecuted local check.'
    Assert-Condition ($HandoffTemplate -match '(?i)Next action:\s*migrate') 'Handoff template no longer contains the intentional stale next action.'

    $Runtime = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $TemplateRoot 'runtime.json') | ConvertFrom-Json
    $Approval = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $TemplateRoot 'approval.json') | ConvertFrom-Json
    Assert-Condition ($Runtime.mode -ceq 'durable-v3') 'Fixture live runtime mode must be durable-v3.'
    Assert-Condition ($Approval.status -ceq 'pending') 'Fixture external approval must remain pending.'

    return @(Get-FixtureDefinitions)
}

function Expand-Template {
    param(
        [string]$TemplatePath,
        [string]$DestinationPath,
        [hashtable]$Replacements
    )

    $Text = Get-Content -Raw -Encoding UTF8 -LiteralPath $TemplatePath
    foreach ($Key in $Replacements.Keys) {
        $Text = $Text.Replace($Key, $Replacements[$Key])
    }
    $DestinationParent = Split-Path -Parent $DestinationPath
    New-Item -ItemType Directory -Force -Path $DestinationParent | Out-Null
    [System.IO.File]::WriteAllText($DestinationPath, $Text, $Utf8NoBom)
}

function Prepare-Workspaces {
    param(
        [object[]]$Definitions,
        [string]$DestinationRoot
    )

    Assert-Condition (-not [string]::IsNullOrWhiteSpace($DestinationRoot)) 'Prepare mode requires -WorkspaceRoot.'
    $ResolvedRoot = [System.IO.Path]::GetFullPath($DestinationRoot)
    Assert-Condition ($ResolvedRoot -cne [System.IO.Path]::GetPathRoot($ResolvedRoot)) 'WorkspaceRoot may not be a filesystem root.'
    Assert-Condition (-not (Test-Path -LiteralPath $ResolvedRoot)) "WorkspaceRoot already exists; refusing to overwrite it: $ResolvedRoot"
    New-Item -ItemType Directory -Path $ResolvedRoot | Out-Null

    foreach ($Definition in $Definitions) {
        $Manifest = $Definition.Manifest
        $Repository = Join-Path $ResolvedRoot $Definition.Id
        New-Item -ItemType Directory -Path $Repository | Out-Null

        $Replacements = @{
            '{{SOURCE_PLATFORM}}' = [string]$Manifest.source_platform
            '{{RECEIVER_PLATFORM}}' = [string]$Manifest.receiver_platform
            '{{STATUS_FILE}}' = [string]$Manifest.documents.status
            '{{SPEC_FILE}}' = [string]$Manifest.documents.spec
            '{{HANDOFF_FILE}}' = [string]$Manifest.documents.handoff
        }
        $GeneratedFiles = [ordered]@{
            'INSTRUCTIONS_TEMPLATE.md' = [string]$Manifest.instruction_file
            'STATUS_TEMPLATE.md' = [string]$Manifest.documents.status
            'SPEC_TEMPLATE.md' = [string]$Manifest.documents.spec
            'HANDOFF_TEMPLATE.md' = [string]$Manifest.documents.handoff
        }
        foreach ($Entry in $GeneratedFiles.GetEnumerator()) {
            $DestinationPath = Resolve-SafeChildPath -BasePath $Repository -RelativePath $Entry.Value -Description "Prepared fixture $($Definition.Id) path"
            Expand-Template -TemplatePath (Join-Path $TemplateRoot $Entry.Key) -DestinationPath $DestinationPath -Replacements $Replacements
        }

        New-Item -ItemType Directory -Path (Join-Path $Repository 'config') | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $Repository 'external') | Out-Null
        Copy-Item -LiteralPath (Join-Path $TemplateRoot '.gitignore') -Destination (Join-Path $Repository '.gitignore')
        Copy-Item -LiteralPath (Join-Path $TemplateRoot 'runtime.json') -Destination (Join-Path $Repository 'config\runtime.json')
        Copy-Item -LiteralPath (Join-Path $TemplateRoot 'approval.json') -Destination (Join-Path $Repository 'external\approval.json')
        Copy-Item -LiteralPath (Join-Path $TemplateRoot 'verify.ps1') -Destination (Join-Path $Repository 'verify.ps1')
        Copy-Item -LiteralPath $Definition.ManifestPath -Destination (Join-Path $Repository 'fixture.json')

        Invoke-Git -Repository $Repository -Arguments @('init', '-b', 'main') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('config', 'user.name', 'Takeover Fixture') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('config', 'user.email', 'fixture@example.invalid') | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('config', 'core.autocrlf', 'false') | Out-Null
        $TrackedFiles = @(
            '.gitignore',
            'fixture.json',
            [string]$Manifest.instruction_file,
            [string]$Manifest.documents.status,
            [string]$Manifest.documents.spec,
            [string]$Manifest.documents.handoff,
            'config/runtime.json',
            'external/approval.json',
            'verify.ps1'
        )
        Invoke-Git -Repository $Repository -Arguments (@('add', '--') + $TrackedFiles) | Out-Null
        Invoke-Git -Repository $Repository -Arguments @('commit', '-m', "fixture: initialize $($Definition.Id)") | Out-Null
        Write-Output "[PREPARED] $($Definition.Id): $Repository"
    }
    Write-Output "Prepared $($Definitions.Count) isolated takeover workspaces under $ResolvedRoot"
}

function Test-EvidenceLabel {
    param(
        [string]$Text,
        [string]$Label
    )

    $Pattern = '(?im)(?:^|\|)\s*(?:[-*]\s*)?(?:\*\*|`)?{0}(?:\*\*|`)?\s*(?::|\|)' -f [regex]::Escape($Label)
    return [regex]::IsMatch($Text, $Pattern)
}

function Test-WorkspaceResults {
    param(
        [object[]]$Definitions,
        [string]$ResultsRoot
    )

    Assert-Condition (-not [string]::IsNullOrWhiteSpace($ResultsRoot)) 'Check mode requires -WorkspaceRoot.'
    $ResolvedRoot = [System.IO.Path]::GetFullPath($ResultsRoot)
    Assert-Condition (Test-Path -LiteralPath $ResolvedRoot -PathType Container) "WorkspaceRoot does not exist: $ResolvedRoot"

    $PassCount = 0
    foreach ($Definition in $Definitions) {
        $Manifest = $Definition.Manifest
        $Repository = Join-Path $ResolvedRoot $Definition.Id
        Assert-Condition (Test-Path -LiteralPath (Join-Path $Repository '.git') -PathType Container) "Prepared fixture is not a Git repository: $Repository"

        $DocumentPaths = @(
            [string]$Manifest.documents.status,
            [string]$Manifest.documents.spec,
            [string]$Manifest.documents.handoff
        )
        $DocumentTexts = @()
        foreach ($RelativePath in $DocumentPaths) {
            $DocumentPath = Resolve-SafeChildPath -BasePath $Repository -RelativePath $RelativePath -Description "Result fixture $($Definition.Id) document"
            Assert-Condition (Test-Path -LiteralPath $DocumentPath -PathType Leaf) "Receiver did not preserve the existing document: $DocumentPath"
            $DocumentTexts += Get-Content -Raw -Encoding UTF8 -LiteralPath $DocumentPath
        }
        $CombinedText = $DocumentTexts -join "`n"
        foreach ($Label in $RequiredResultLabels) {
            Assert-Condition (Test-EvidenceLabel -Text $CombinedText -Label $Label) "Fixture $($Definition.Id) does not record evidence label '$Label'."
        }
        foreach ($StalePattern in @(
            'implementation_state:\s*in-progress',
            'runtime_mode:\s*legacy-v1',
            '(?i)Next action:\s*migrate'
        )) {
            Assert-Condition ($CombinedText -notmatch $StalePattern) "Fixture $($Definition.Id) retained stale claim '$StalePattern'."
        }
        Assert-Condition ($CombinedText -match 'durable-v3') "Fixture $($Definition.Id) does not retain the verified runtime mode."

        $MarkerPath = Join-Path $Repository '.test-artifacts\verification-ran.txt'
        Assert-Condition (Test-Path -LiteralPath $MarkerPath -PathType Leaf) "Fixture $($Definition.Id) did not execute its documented verification command."
        $MarkerText = Get-Content -Raw -Encoding UTF8 -LiteralPath $MarkerPath
        Assert-Condition ($MarkerText -match 'Fixture verification passed') "Fixture $($Definition.Id) verification marker is invalid."

        $CommitCount = [int]((Invoke-Git -Repository $Repository -Arguments @('rev-list', '--count', 'HEAD') | Select-Object -First 1).ToString().Trim())
        Assert-Condition ($CommitCount -eq 1) "Fixture $($Definition.Id) created a commit in default non-publishing mode."

        $StagedPaths = @(Invoke-Git -Repository $Repository -Arguments @('diff', '--cached', '--name-only'))
        Assert-Condition ($StagedPaths.Count -eq 0) "Fixture $($Definition.Id) staged files in default non-publishing mode."
        $UntrackedPaths = @(Invoke-Git -Repository $Repository -Arguments @('ls-files', '--others', '--exclude-standard'))
        Assert-Condition ($UntrackedPaths.Count -eq 0) "Fixture $($Definition.Id) created replacement or other untracked files: $($UntrackedPaths -join ', ')"

        $ChangedPaths = @(Invoke-Git -Repository $Repository -Arguments @('diff', '--name-only')) | Sort-Object
        $ExpectedChangedPaths = @($DocumentPaths | Sort-Object)
        $ChangedDelta = @(Compare-Object $ExpectedChangedPaths $ChangedPaths)
        Assert-Condition ($ChangedDelta.Count -eq 0) "Fixture $($Definition.Id) did not update exactly its existing status, spec, and handoff documents."

        $PassCount++
        Write-Output "[PASS] $($Definition.Id): $($Manifest.source_platform) -> $($Manifest.receiver_platform)"
    }
    Write-Output "Regression summary: $PassCount passed, 0 failed."
}

try {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'Git is not available on PATH.'
    }
    $Definitions = @(Test-CanonicalFixtures)
    switch ($Mode) {
        'Validate' {
            Write-Output "[PASS] Canonical takeover matrix contains all $($Definitions.Count) directed cross-platform fixtures."
        }
        'Prepare' {
            Prepare-Workspaces -Definitions $Definitions -DestinationRoot $WorkspaceRoot
        }
        'Check' {
            Test-WorkspaceResults -Definitions $Definitions -ResultsRoot $WorkspaceRoot
        }
    }
    exit 0
} catch {
    [Console]::Error.WriteLine("Regression $Mode failed: $($_.Exception.Message)")
    exit 1
}
