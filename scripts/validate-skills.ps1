<#
.SYNOPSIS
Validate all skills in ry-workflow: YAML frontmatter, naming consistency, description token budget, relative links, and cross-file catalog sync.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$skillsRoot = Join-Path $repoRoot 'skills'

$maxDescChars = 200
$maxTotalDescChars = 3500
$maxSkillBytes = 20480

$errors = [System.Collections.Generic.List[string]]::new()
$skillDirs = Get-ChildItem -LiteralPath $skillsRoot -Directory | Sort-Object Name

if ($skillDirs.Count -eq 0) {
    $errors.Add("No skill directories found under $skillsRoot")
}

$summary = @()
$totalDescChars = 0
$skillNames = [System.Collections.Generic.List[string]]::new()

foreach ($dir in $skillDirs) {
    $skillNames.Add($dir.Name)
    $skillMd = Join-Path $dir.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillMd)) {
        $errors.Add("Missing SKILL.md in $($dir.Name)")
        continue
    }

    $raw = Get-Content -LiteralPath $skillMd -Raw -Encoding UTF8
    $lines = (Get-Content -LiteralPath $skillMd -Encoding UTF8).Count
    $bytes = (Get-Item -LiteralPath $skillMd).Length

    if ($raw -notmatch '(?s)^---\r?\n(.*?)\r?\n---') {
        $errors.Add("$($dir.Name)/SKILL.md: missing YAML frontmatter")
        continue
    }

    $fm = $Matches[1]
    $nameMatch = [regex]::Match($fm, '(?m)^name:\s*(.+?)\s*$')
    $descMatch = [regex]::Match($fm, '(?m)^description:\s*(.+?)\s*$')
    $collMatch = [regex]::Match($fm, '(?m)^\s+collection:\s*(.+?)\s*$')

    if (-not $nameMatch.Success) {
        $errors.Add("$($dir.Name)/SKILL.md: missing 'name' in frontmatter")
    } elseif ($nameMatch.Groups[1].Value.Trim('"''') -ne $dir.Name) {
        $errors.Add("$($dir.Name)/SKILL.md: frontmatter name '$($nameMatch.Groups[1].Value)' != folder '$($dir.Name)'")
    }

    $descLen = 0
    if (-not $descMatch.Success) {
        $errors.Add("$($dir.Name)/SKILL.md: missing 'description' in frontmatter")
    } else {
        $descVal = $descMatch.Groups[1].Value.Trim('"''')
        $descLen = $descVal.Length
        $totalDescChars += $descLen
        if ($descLen -gt $maxDescChars) {
            $errors.Add("$($dir.Name)/SKILL.md: description exceeds $maxDescChars chars ($descLen chars) — keep frontmatter tight for always-loaded context")
        }
    }

    if (-not $collMatch.Success -or $collMatch.Groups[1].Value.Trim('"''') -ne 'ry-workflow') {
        $errors.Add("$($dir.Name)/SKILL.md: missing or invalid metadata.collection (expected 'ry-workflow')")
    }

    if ($bytes -gt $maxSkillBytes) {
        $errors.Add("$($dir.Name)/SKILL.md: exceeds 20 KB ($bytes bytes) — move branch details to references/")
    }

    # Verify all relative markdown links outside fenced code blocks across SKILL.md and references/*.md
    $mdFiles = Get-ChildItem -LiteralPath $dir.FullName -Recurse -Filter '*.md'
    foreach ($md in $mdFiles) {
        $content = Get-Content -LiteralPath $md.FullName -Raw -Encoding UTF8
        $stripped = [regex]::Replace($content, '(?s)```.*?```', '')
        $links = [regex]::Matches($stripped, '\[[^\]]+\]\(([^)#]+)\)')
        foreach ($m in $links) {
            $href = $m.Groups[1].Value.Trim()
            if ($href -match '^(https?://|mailto:)' -or $href -match '[<>]') { continue }
            $resolved = Join-Path $md.DirectoryName $href
            if (-not (Test-Path -LiteralPath $resolved)) {
                $rel = $md.FullName.Replace($repoRoot + '\', '')
                $errors.Add("${rel}: broken relative link '$href'")
            }
        }
    }

    $refCount = (Get-ChildItem -LiteralPath (Join-Path $dir.FullName 'references') -Filter '*.md' -ErrorAction SilentlyContinue).Count
    $summary += [PSCustomObject]@{
        Skill     = $dir.Name
        DescChars = $descLen
        Lines     = $lines
        Bytes     = $bytes
        Refs      = $refCount
    }
}

if ($totalDescChars -gt $maxTotalDescChars) {
    $errors.Add("Total always-loaded description length ($totalDescChars chars) exceeds budget ($maxTotalDescChars chars)")
}

# Verify README links (excluding fenced code blocks) and catalog sync
$readmePath = Join-Path $repoRoot 'README.md'
$readmeContent = Get-Content -LiteralPath $readmePath -Raw -Encoding UTF8
$readmeStripped = [regex]::Replace($readmeContent, '(?s)```.*?```', '')
foreach ($m in [regex]::Matches($readmeStripped, '\[[^\]]+\]\(([^)#]+)\)')) {
    $href = $m.Groups[1].Value.Trim()
    if ($href -match '^(https?://|mailto:)') { continue }
    $resolved = Join-Path $repoRoot $href
    if (-not (Test-Path -LiteralPath $resolved)) {
        $errors.Add("README.md: broken relative link '$href'")
    }
}

# Verify README, ry-flow/SKILL.md, and upstream-lock.json stay in sync with skills/
$ryFlowContent = Get-Content -LiteralPath (Join-Path $skillsRoot 'ry-flow\SKILL.md') -Raw -Encoding UTF8
$lockJson = Get-Content -LiteralPath (Join-Path $repoRoot 'upstream-lock.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$lockKeys = @($lockJson.integrations.PSObject.Properties.Name)

foreach ($name in $skillNames) {
    if ($readmeStripped -notmatch [regex]::Escape("skills/$name/SKILL.md")) {
        $errors.Add("README.md: missing catalog link for '$name'")
    }
    if ($name -ne 'ry-flow' -and $ryFlowContent -notmatch [regex]::Escape("``$name``")) {
        $errors.Add("skills/ry-flow/SKILL.md: missing catalog entry for '$name'")
    }
    if ($lockKeys -notcontains $name) {
        $errors.Add("upstream-lock.json: missing integrations entry for '$name'")
    }
}

foreach ($k in $lockKeys) {
    if ($skillNames -notcontains $k) {
        $errors.Add("upstream-lock.json: stale integrations entry '$k' (not found under skills/)")
    }
}

$summary | Format-Table -AutoSize
Write-Host "Total always-loaded description chars: $totalDescChars / $maxTotalDescChars"

if ($errors.Count -gt 0) {
    Write-Host "VALIDATION FAILED ($($errors.Count) issues):" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "ALL CHECKS PASSED: $($skillDirs.Count) skills validated, 0 broken links, catalog in sync." -ForegroundColor Green
