<#
.SYNOPSIS
    md-index: Generate .INDEX.md from split docs
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$dir,

    [string]$out
)

if (-not (Test-Path $dir)) {
    Write-Error "Directory '$dir' not found"
    exit 1
}

if (-not $out) {
    $out = Join-Path $dir ".INDEX.md"
}

$header = "# Index`n"
$header | Out-File -FilePath $out -Encoding utf8

$files = Get-ChildItem -Path $dir -Filter "*.md" | 
    Where-Object { $_.Name -match '^[0-9][0-9]_.+\.md$' } |
    Sort-Object Name

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -TotalCount 1
    $title = $file.Name
    if ($content -match '^# ') {
        $title = $content -replace '^# ', ''
    }
    "- [$title]($($file.Name))" | Out-File -FilePath $out -Append -Encoding utf8
}

Write-Host "Index generated at: $out"
