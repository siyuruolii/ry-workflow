<#
.SYNOPSIS
Link (or unlink) all ry-workflow skills into local Codex, Antigravity, and/or Claude Code skill directories using Windows directory junctions (no admin privileges required).

.EXAMPLE
.\scripts\link-skills.ps1
.\scripts\link-skills.ps1 -Targets codex,antigravity,claude
.\scripts\link-skills.ps1 -Unlink
#>
[CmdletBinding()]
param(
    [ValidateSet('codex', 'antigravity', 'claude')]
    [string[]]$Targets = @('codex', 'antigravity'),
    [switch]$Unlink,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$skillsRoot = Join-Path $repoRoot 'skills'

$targetMap = @{
    'codex'       = Join-Path $HOME '.agents\skills'
    'antigravity' = Join-Path $HOME '.gemini\config\skills'
    'claude'      = Join-Path $HOME '.claude\skills'
}

$skillDirs = Get-ChildItem -LiteralPath $skillsRoot -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
} | Sort-Object Name

if ($skillDirs.Count -eq 0) {
    throw "No skills found under $skillsRoot"
}

foreach ($t in $Targets) {
    $dest = $targetMap[$t]

    if (Test-Path -LiteralPath $dest) {
        $destItem = Get-Item -LiteralPath $dest -Force
        if ($destItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $resolvedDest = (Resolve-Path -LiteralPath $dest).Path
            if ($resolvedDest.StartsWith($repoRoot, [StringComparison]::OrdinalIgnoreCase)) {
                throw "Refusing to modify $dest because it points inside this repository ($resolvedDest)."
            }
        }
    } elseif (-not $Unlink) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    } else {
        continue
    }

    foreach ($skill in $skillDirs) {
        $linkPath = Join-Path $dest $skill.Name
        $exists = Test-Path -LiteralPath $linkPath

        if ($Unlink) {
            if ($exists) {
                $item = Get-Item -LiteralPath $linkPath -Force
                if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                    cmd /c rmdir "$linkPath" | Out-Null
                    Write-Host "unlinked [$t] $($skill.Name)"
                } else {
                    Write-Warning "skipped [$t] $linkPath (not a junction/symlink)"
                }
            }
            continue
        }

        if ($exists) {
            $item = Get-Item -LiteralPath $linkPath -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                cmd /c rmdir "$linkPath" | Out-Null
            } elseif ($Force) {
                Remove-Item -LiteralPath $linkPath -Recurse -Force
            } else {
                Write-Warning "skipped [$t] $linkPath (real directory exists; pass -Force to replace)"
                continue
            }
        }

        New-Item -ItemType Junction -Path $linkPath -Target $skill.FullName | Out-Null
        Write-Host "linked   [$t] $($skill.Name) -> $($skill.FullName)"
    }
}

Write-Host "`nDone. Restart your agent session to pick up updated skills."
