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
$script:PassCount = 0
$script:FailureCount = 0
$script:WarningCount = 0

function Add-Pass {
    param([string]$Message)

    $script:PassCount++
    Write-Output "[PASS] $Message"
}

function Add-Failure {
    param([string]$Message)

    $script:FailureCount++
    Write-Output "[FAIL] $Message"
}

function Add-Warning {
    param([string]$Message)

    $script:WarningCount++
    Write-Output "[WARN] $Message"
}

function Test-SkillFrontmatter {
    param(
        [string]$SkillName,
        [string]$SkillPath,
        [string[]]$RequiredDescriptionTerms
    )

    $FailureCountBefore = $script:FailureCount
    if (-not (Test-Path -LiteralPath $SkillPath -PathType Leaf)) {
        Add-Failure "Canonical skill entry is missing: $SkillPath"
        return
    }

    $Lines = @(Get-Content -Encoding UTF8 -LiteralPath $SkillPath)
    if ($Lines.Count -lt 4 -or $Lines[0] -cne '---') {
        Add-Failure "$SkillName has no valid opening frontmatter delimiter."
        return
    }

    $ClosingIndex = -1
    for ($Index = 1; $Index -lt $Lines.Count; $Index++) {
        if ($Lines[$Index] -ceq '---') {
            $ClosingIndex = $Index
            break
        }
    }
    if ($ClosingIndex -lt 2) {
        Add-Failure "$SkillName has no valid closing frontmatter delimiter."
        return
    }

    $Values = @{}
    $Keys = New-Object System.Collections.Generic.List[string]
    for ($Index = 1; $Index -lt $ClosingIndex; $Index++) {
        $Line = $Lines[$Index]
        if ([string]::IsNullOrWhiteSpace($Line)) {
            continue
        }
        if ($Line -notmatch '^([A-Za-z0-9_-]+):\s*(.*)$') {
            Add-Failure "$SkillName has unsupported frontmatter syntax on line $($Index + 1)."
            continue
        }

        $Key = $Matches[1]
        if ($Values.ContainsKey($Key)) {
            Add-Failure "$SkillName repeats frontmatter key '$Key'."
            continue
        }
        $Keys.Add($Key)
        $Values[$Key] = $Matches[2].Trim().Trim('"').Trim("'")
    }

    $ExpectedKeys = @('name', 'description')
    $UnexpectedKeys = @($Keys | Where-Object { $_ -notin $ExpectedKeys })
    if ($Keys.Count -ne 2 -or $UnexpectedKeys.Count -gt 0 -or
        -not $Values.ContainsKey('name') -or -not $Values.ContainsKey('description')) {
        Add-Failure "$SkillName frontmatter must contain only name and description."
    }

    if ($Values.ContainsKey('name') -and $Values['name'] -cne $SkillName) {
        Add-Failure "$SkillName frontmatter name is '$($Values['name'])'."
    }

    if ($Values.ContainsKey('description')) {
        $Description = [string]$Values['description']
        if ([string]::IsNullOrWhiteSpace($Description)) {
            Add-Failure "$SkillName frontmatter description is empty."
        }
        foreach ($Term in $RequiredDescriptionTerms) {
            if ($Description.IndexOf($Term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                Add-Failure "$SkillName description is missing required trigger term '$Term'."
            }
        }
    }

    if ($script:FailureCount -eq $FailureCountBefore) {
        Add-Pass "$SkillName frontmatter and trigger description are valid."
    }
}

function Test-OpenAiMetadata {
    param(
        [string]$SkillName,
        [string]$MetadataPath
    )

    $FailureCountBefore = $script:FailureCount
    if (-not (Test-Path -LiteralPath $MetadataPath -PathType Leaf)) {
        Add-Failure "$SkillName OpenAI metadata is missing: $MetadataPath"
        return
    }

    $Values = @{}
    foreach ($Line in Get-Content -Encoding UTF8 -LiteralPath $MetadataPath) {
        if ($Line -match '^\s{2}(display_name|short_description|default_prompt):\s+"(.*)"\s*$') {
            $Values[$Matches[1]] = $Matches[2]
        }
    }
    foreach ($RequiredKey in @('display_name', 'short_description', 'default_prompt')) {
        if (-not $Values.ContainsKey($RequiredKey) -or [string]::IsNullOrWhiteSpace($Values[$RequiredKey])) {
            Add-Failure "$SkillName OpenAI metadata is missing quoted '$RequiredKey'."
        }
    }
    if ($Values.ContainsKey('short_description')) {
        $Length = $Values['short_description'].Length
        if ($Length -lt 25 -or $Length -gt 64) {
            Add-Failure "$SkillName short_description length is $Length; expected 25-64 characters."
        }
    }
    if ($Values.ContainsKey('default_prompt')) {
        $SkillToken = '$' + $SkillName
        if ($Values['default_prompt'].IndexOf($SkillToken, [System.StringComparison]::Ordinal) -lt 0) {
            Add-Failure "$SkillName default_prompt does not mention $SkillToken."
        }
    }

    if ($script:FailureCount -eq $FailureCountBefore) {
        Add-Pass "$SkillName OpenAI metadata is complete and aligned with UI constraints."
    }
}

function Test-SkillInstallation {
    param(
        [string]$PlatformName,
        [string]$SkillRoot,
        [string]$SkillName
    )

    $SourceRoot = Join-Path $ProjectRoot $SkillName
    $DestinationRoot = Join-Path $SkillRoot $SkillName
    $DestinationEntry = Join-Path $DestinationRoot 'SKILL.md'
    if (Test-Path -LiteralPath $DestinationEntry -PathType Leaf) {
        Add-Pass "$PlatformName $SkillName entry exists."
    } else {
        Add-Failure "$PlatformName $SkillName entry is missing: $DestinationEntry"
    }

    $SourceFiles = @(Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -ErrorAction Stop)
    $AllFilesMatch = $true
    foreach ($SourceFile in $SourceFiles) {
        $RelativePath = $SourceFile.FullName.Substring($SourceRoot.Length).TrimStart('\')
        $DestinationFile = Join-Path $DestinationRoot $RelativePath
        if (-not (Test-Path -LiteralPath $DestinationFile -PathType Leaf)) {
            Add-Failure "$PlatformName $SkillName file is missing: $RelativePath"
            $AllFilesMatch = $false
            continue
        }

        $SourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourceFile.FullName).Hash
        $DestinationHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $DestinationFile).Hash
        if ($SourceHash -ne $DestinationHash) {
            Add-Failure "$PlatformName $SkillName hash mismatch: $RelativePath"
            $AllFilesMatch = $false
        }
    }

    if ($AllFilesMatch) {
        Add-Pass "$PlatformName $SkillName matches all $($SourceFiles.Count) canonical files."
    }

    if (Test-Path -LiteralPath $DestinationRoot -PathType Container) {
        $CanonicalRelativePaths = @($SourceFiles | ForEach-Object {
            $_.FullName.Substring($SourceRoot.Length).TrimStart('\')
        })
        $ExtraFiles = @(Get-ChildItem -LiteralPath $DestinationRoot -Recurse -File | Where-Object {
            $RelativePath = $_.FullName.Substring($DestinationRoot.Length).TrimStart('\')
            $RelativePath -notin $CanonicalRelativePaths -and $_.Name -notlike '*.backup-*'
        })
        if ($ExtraFiles.Count -gt 0) {
            Add-Warning "$PlatformName $SkillName contains $($ExtraFiles.Count) extra file(s); they were preserved."
        }
    }
}

function Test-ManagedRule {
    param(
        [string]$PlatformName,
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $BeginMarker = '<!-- BEGIN wrap-up-bootstrap: response-language -->'
    $EndMarker = '<!-- END wrap-up-bootstrap: response-language -->'
    $Pattern = '(?s)' + [regex]::Escape($BeginMarker) + '.*?' + [regex]::Escape($EndMarker)

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
        Add-Failure "$PlatformName canonical rule is missing: $SourcePath"
        return
    }
    if (-not (Test-Path -LiteralPath $DestinationPath -PathType Leaf)) {
        Add-Failure "$PlatformName global rule file is missing: $DestinationPath"
        return
    }

    $SourceBlock = (Get-Content -Raw -Encoding UTF8 -LiteralPath $SourcePath).Trim()
    $DestinationText = Get-Content -Raw -Encoding UTF8 -LiteralPath $DestinationPath
    $ManagedBlocks = [regex]::Matches($DestinationText, $Pattern)
    if ($ManagedBlocks.Count -ne 1) {
        Add-Failure "$PlatformName global rule contains $($ManagedBlocks.Count) managed blocks; expected exactly one."
        return
    }
    if ($ManagedBlocks[0].Value.Trim() -cne $SourceBlock) {
        Add-Failure "$PlatformName managed global-preferences block differs from the canonical source."
        return
    }

    Add-Pass "$PlatformName has exactly one matching managed global-preferences block."
}

function Test-CanonicalGlobalRules {
    $FailureCountBefore = $script:FailureCount
    $RulePaths = @(
        (Join-Path $ProjectRoot 'global-rules\AGENTS.md'),
        (Join-Path $ProjectRoot 'global-rules\CLAUDE.md'),
        (Join-Path $ProjectRoot 'global-rules\GEMINI.md')
    )
    $TraditionalChineseText = -join @([char]0x7E41, [char]0x9AD4, [char]0x4E2D, [char]0x6587)
    $RequiredFragments = @(
        "Use Traditional Chinese ($TraditionalChineseText) for all user-facing prose by default.",
        'When creating or materially updating the primary `README.md` for a GitHub repository',
        "a complete English version and a complete Traditional Chinese ($TraditionalChineseText) version",
        'Place the English version first and the Traditional Chinese version below it'
    )
    $ReferenceText = $null

    foreach ($RulePath in $RulePaths) {
        if (-not (Test-Path -LiteralPath $RulePath -PathType Leaf)) {
            Add-Failure "Canonical global preference rule is missing: $RulePath"
            continue
        }

        $RuleText = (Get-Content -Raw -Encoding UTF8 -LiteralPath $RulePath).Trim()
        foreach ($RequiredFragment in $RequiredFragments) {
            if ($RuleText.IndexOf($RequiredFragment, [System.StringComparison]::Ordinal) -lt 0) {
                Add-Failure "$RulePath is missing required global preference text: $RequiredFragment"
            }
        }

        if ($null -eq $ReferenceText) {
            $ReferenceText = $RuleText
        } elseif ($RuleText -cne $ReferenceText) {
            Add-Failure "$RulePath differs from the other canonical global preference rules."
        }
    }

    if ($script:FailureCount -eq $FailureCountBefore) {
        Add-Pass 'Canonical global preference rules are aligned and require Traditional Chinese responses plus bilingual GitHub READMEs.'
    }
}

function Test-ProjectContextArtifacts {
    $FailureCountBefore = $script:FailureCount
    $SchemaPath = Join-Path $ProjectRoot 'PROJECT_CONTEXT.schema.json'
    $ExamplePath = Join-Path $ProjectRoot 'PROJECT_CONTEXT.example.yaml'

    if (-not (Test-Path -LiteralPath $SchemaPath -PathType Leaf)) {
        Add-Failure "Project context schema is missing: $SchemaPath"
    } else {
        try {
            $Schema = Get-Content -Raw -Encoding UTF8 -LiteralPath $SchemaPath | ConvertFrom-Json
            if ($Schema.properties.schema_version.const -ne 1) {
                Add-Failure 'Project context schema must require schema_version 1.'
            }
            $RequiredProperties = @($Schema.required)
            foreach ($RequiredProperty in @('schema_version', 'project_name')) {
                if ($RequiredProperty -notin $RequiredProperties) {
                    Add-Failure "Project context schema does not require '$RequiredProperty'."
                }
            }
            $PublishPolicies = @($Schema.properties.git.properties.publish_policy.enum)
            foreach ($PublishPolicy in @('skill-default', 'explicit', 'never')) {
                if ($PublishPolicy -notin $PublishPolicies) {
                    Add-Failure "Project context schema is missing publish policy '$PublishPolicy'."
                }
            }
        } catch {
            Add-Failure "Project context schema is not valid JSON: $($_.Exception.Message)"
        }
    }

    if (-not (Test-Path -LiteralPath $ExamplePath -PathType Leaf)) {
        Add-Failure "Project context example is missing: $ExamplePath"
    } else {
        $ExampleText = Get-Content -Raw -Encoding UTF8 -LiteralPath $ExamplePath
        foreach ($Pattern in @(
            '(?m)^schema_version:\s*1\s*$',
            '(?m)^project_name:\s*\S+',
            '(?m)^documents:\s*$',
            '(?m)^verification:\s*$',
            '(?m)^git:\s*$',
            '(?m)^cautions:\s*$',
            '(?m)^exclusions:\s*$'
        )) {
            if ($ExampleText -notmatch $Pattern) {
                Add-Failure "Project context example is missing expected pattern '$Pattern'."
            }
        }
    }

    if ($script:FailureCount -eq $FailureCountBefore) {
        Add-Pass 'PROJECT_CONTEXT schema and example have the required version 1 structure.'
    }
}

function Test-RegressionArtifacts {
    $FailureCountBefore = $script:FailureCount
    $EvidenceLabels = @('Verified', 'Observed', 'Assumption', 'Not run', 'Blocked')
    foreach ($SkillName in @('wrap-up', 'bootstrap')) {
        $SkillPath = Join-Path $ProjectRoot "$SkillName\SKILL.md"
        if (-not (Test-Path -LiteralPath $SkillPath -PathType Leaf)) {
            Add-Failure "Evidence contract cannot be checked because $SkillName is missing."
            continue
        }
        $SkillText = Get-Content -Raw -Encoding UTF8 -LiteralPath $SkillPath
        foreach ($EvidenceLabel in $EvidenceLabels) {
            if ($SkillText.IndexOf("``$EvidenceLabel``", [System.StringComparison]::Ordinal) -lt 0) {
                Add-Failure "$SkillName evidence contract is missing label '$EvidenceLabel'."
            }
        }
    }

    $RegressionScript = Join-Path $ProjectRoot 'test-regressions.ps1'
    if (-not (Test-Path -LiteralPath $RegressionScript -PathType Leaf)) {
        Add-Failure "Regression runner is missing: $RegressionScript"
    }

    $FixtureRoot = Join-Path $ProjectRoot 'tests\fixtures\takeover'
    $ExpectedFixtures = [ordered]@{
        'codex-to-claude' = @('Codex', 'Claude Code')
        'codex-to-antigravity' = @('Codex', 'Antigravity')
        'claude-to-codex' = @('Claude Code', 'Codex')
        'claude-to-antigravity' = @('Claude Code', 'Antigravity')
        'antigravity-to-codex' = @('Antigravity', 'Codex')
        'antigravity-to-claude' = @('Antigravity', 'Claude Code')
    }
    if (-not (Test-Path -LiteralPath $FixtureRoot -PathType Container)) {
        Add-Failure "Takeover fixture root is missing: $FixtureRoot"
    } else {
        $ActualFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Directory | Where-Object { $_.Name -cne 'template' } | ForEach-Object { $_.Name } | Sort-Object)
        $ExpectedFixtureNames = @($ExpectedFixtures.Keys | Sort-Object)
        $FixtureDelta = @(Compare-Object $ExpectedFixtureNames $ActualFixtures)
        if ($FixtureDelta.Count -gt 0) {
            Add-Failure 'Takeover fixture matrix does not contain exactly the six directed platform pairs.'
        }
        foreach ($FixtureName in $ExpectedFixtures.Keys) {
            $ManifestPath = Join-Path $FixtureRoot "$FixtureName\fixture.json"
            if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
                Add-Failure "Takeover fixture manifest is missing: $ManifestPath"
                continue
            }
            try {
                $Manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $ManifestPath | ConvertFrom-Json
                $ExpectedPair = $ExpectedFixtures[$FixtureName]
                if ($Manifest.id -cne $FixtureName -or
                    $Manifest.source_platform -cne $ExpectedPair[0] -or
                    $Manifest.receiver_platform -cne $ExpectedPair[1]) {
                    Add-Failure "Takeover fixture manifest is inconsistent: $ManifestPath"
                }
            } catch {
                Add-Failure "Takeover fixture manifest is invalid JSON: $ManifestPath"
            }
        }
    }

    if ($script:FailureCount -eq $FailureCountBefore) {
        Add-Pass 'Evidence labels and all six directed takeover fixture manifests are present.'
    }
}

Write-Output "Verifying wrap-up-bootstrap in $ProjectRoot"
Write-Output "User root: $ResolvedUserRoot"

$VersionPath = Join-Path $ProjectRoot 'VERSION'
if (-not (Test-Path -LiteralPath $VersionPath -PathType Leaf)) {
    Add-Failure "VERSION is missing: $VersionPath"
} else {
    $Version = (Get-Content -Raw -Encoding UTF8 -LiteralPath $VersionPath).Trim()
    if ($Version -match '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$') {
        Add-Pass "VERSION is valid: $Version"
    } else {
        Add-Failure "VERSION is not a supported semantic version: $Version"
    }
}

Test-SkillFrontmatter -SkillName 'wrap-up' -SkillPath (Join-Path $ProjectRoot 'wrap-up\SKILL.md') -RequiredDescriptionTerms @('wrap-up', 'commit', 'push', 'publish', 'ncp')
Test-SkillFrontmatter -SkillName 'bootstrap' -SkillPath (Join-Path $ProjectRoot 'bootstrap\SKILL.md') -RequiredDescriptionTerms @('bootstrap', 'initialize', 'resume', 'take over')
Test-OpenAiMetadata -SkillName 'wrap-up' -MetadataPath (Join-Path $ProjectRoot 'wrap-up\agents\openai.yaml')
Test-OpenAiMetadata -SkillName 'bootstrap' -MetadataPath (Join-Path $ProjectRoot 'bootstrap\agents\openai.yaml')
Test-CanonicalGlobalRules
Test-ProjectContextArtifacts
Test-RegressionArtifacts

$Platforms = @(
    [pscustomobject]@{
        Name = 'Codex'
        SkillRoot = Join-Path $ResolvedUserRoot '.agents\skills'
        RuleSource = Join-Path $ProjectRoot 'global-rules\AGENTS.md'
        RuleDestination = Join-Path $ResolvedUserRoot '.codex\AGENTS.md'
    },
    [pscustomobject]@{
        Name = 'Claude Code'
        SkillRoot = Join-Path $ResolvedUserRoot '.claude\skills'
        RuleSource = Join-Path $ProjectRoot 'global-rules\CLAUDE.md'
        RuleDestination = Join-Path $ResolvedUserRoot '.claude\CLAUDE.md'
    },
    [pscustomobject]@{
        Name = 'Antigravity'
        SkillRoot = Join-Path $ResolvedUserRoot '.gemini\antigravity\skills'
        RuleSource = Join-Path $ProjectRoot 'global-rules\GEMINI.md'
        RuleDestination = Join-Path $ResolvedUserRoot '.gemini\GEMINI.md'
    }
)

foreach ($Platform in $Platforms) {
    foreach ($SkillName in @('wrap-up', 'bootstrap')) {
        Test-SkillInstallation -PlatformName $Platform.Name -SkillRoot $Platform.SkillRoot -SkillName $SkillName
    }
    Test-ManagedRule -PlatformName $Platform.Name -SourcePath $Platform.RuleSource -DestinationPath $Platform.RuleDestination
}

Write-Output '[INFO] Codex, Claude Code, and Antigravity may require a restart or new session after skill installation or updates.'
Write-Output "Verification summary: $($script:PassCount) passed, $($script:WarningCount) warning(s), $($script:FailureCount) failed."

if ($script:FailureCount -gt 0) {
    exit 1
}

exit 0
