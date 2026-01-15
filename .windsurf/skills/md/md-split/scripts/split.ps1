<#
.SYNOPSIS
    md-split: Split a markdown file by H2 headings
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$in,

    [string]$out,

    [string]$prefix = "01",

    [switch]$dryRun,

    [switch]$force,

    [switch]$noIntro,

    [switch]$manifest = $true
)

if (-not (Test-Path $in)) {
    Write-Error "Input file '$in' not found"
    exit 1
}

if (-not $out) {
    $item = Get-Item $in
    $baseName = $item.BaseName.ToLower()
    $parentDir = $item.DirectoryName
    $out = Join-Path $parentDir $baseName
}

if (-not (Test-Path $out)) {
    New-Item -ItemType Directory -Path $out | Out-Null
}

function Get-Slug {
    param([string]$title)
    $slug = $title.ToUpper()
    $slug = $slug -replace '[ -]', '_'
    $slug = $slug -replace '[^A-Z0-9_]', ''
    $slug = $slug -replace '_+', '_'
    $slug = $slug.Trim('_')
    if ($slug.Length -gt 60) { $slug = $slug.Substring(0, 60) }
    return $slug
}

$generatedFiles = New-Object System.Collections.Generic.List[string]
$manifestEntries = New-Object System.Collections.Generic.List[string]
$buffer = ""
$introBuffer = ""
$firstH2Found = $false
$index = [int]$prefix

function Intro-HasMeaningfulContent {
    param([string]$text)
    if ([string]::IsNullOrWhiteSpace($text)) { return $false }

    # Remove leading whitespace
    $t = $text -replace '^\s+', ''
    # If it's exactly one H1 line plus optional whitespace, treat as not meaningful
    if ($t -match '^#\s[^\r\n]+(\r?\n\s*)*$') { return $false }
    return $true
}

$content = Get-Content -Path $in -Raw
$lines = $content -split "`r?`n"

foreach ($line in $lines) {
    if ($line -match '^## ') {
        $h2Title = $line -replace '^## ', ''
        
        if ($firstH2Found) {
            if (-not $dryRun) {
                if ((Test-Path $currentPath) -and (-not $force)) {
                    Write-Error "File '$currentPath' already exists. Use -force to overwrite."
                    exit 1
                }
                $buffer | Out-File -FilePath $currentPath -Encoding utf8
            }
            $generatedFiles.Add($currentFilename)
            $manifestEntries.Add("{`"index`": $($index-1), `"filename`": `"$currentFilename`", `"title`": `"$currentTitle`", `"source_heading`": `"## $currentTitle`"}")
        } else {
            if ((-not $noIntro) -and (Intro-HasMeaningfulContent $introBuffer)) {
                $introFilename = "00_INTRO.md"
                $introPath = Join-Path $out $introFilename
                if (-not $dryRun) {
                    if ((Test-Path $introPath) -and (-not $force)) {
                        Write-Error "File '$introPath' already exists. Use -force to overwrite."
                        exit 1
                    }
                    $introBuffer | Out-File -FilePath $introPath -Encoding utf8
                }
                $generatedFiles.Add($introFilename)
                $manifestEntries.Add("{`"index`": 0, `"filename`": `"$introFilename`", `"title`": `"Intro`", `"source_heading`": null}")
            }
            $firstH2Found = $true
        }

        $slug = Get-Slug $h2Title
        $nn = $index.ToString("00")
        $currentFilename = "${nn}_${slug}.md"
        $currentPath = Join-Path $out $currentFilename
        $currentTitle = $h2Title
        $buffer = "# $h2Title"
        $index++
    } else {
        if ($firstH2Found) {
            if ($buffer) { $buffer += "`n" }
            $buffer += $line
        } else {
            if ($introBuffer) { $introBuffer += "`n" }
            $introBuffer += $line
        }
    }
}

if ($firstH2Found) {
    if (-not $dryRun) {
        if ((Test-Path $currentPath) -and (-not $force)) {
            Write-Error "File '$currentPath' already exists. Use -force to overwrite."
            exit 1
        }
        $buffer | Out-File -FilePath $currentPath -Encoding utf8
    }
    $generatedFiles.Add($currentFilename)
    $manifestEntries.Add("{`"index`": $($index-1), `"filename`": `"$currentFilename`", `"title`": `"$currentTitle`", `"source_heading`": `"## $currentTitle`"}")
} else {
    # No H2 found at all. Handle intro/entire content.
    if ((-not $noIntro) -and (-not [string]::IsNullOrWhiteSpace($introBuffer))) {
        $introFilename = "00_INTRO.md"
        $introPath = Join-Path $out $introFilename
        if (-not $dryRun) {
            if ((Test-Path $introPath) -and (-not $force)) {
                Write-Error "File '$introPath' already exists. Use -force to overwrite."
                exit 1
            }
            $introBuffer | Out-File -FilePath $introPath -Encoding utf8
        }
        $generatedFiles.Add($introFilename)
        $manifestEntries.Add("{`"index`": 0, `"filename`": `"$introFilename`", `"title`": `"Intro`", `"source_heading`": null}")
    }
}

if ($manifest -and (-not $dryRun)) {
    $manifestPath = Join-Path $out ".SPLIT.json"
    $timestamp = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    $json = "{"
    $json += "`n  `"version`": `"1.0`","
    $json += "`n  `"input`": `"$($in -replace '\\', '/')`","
    $json += "`n  `"output_dir`": `"$($out -replace '\\', '/')`","
    $json += "`n  `"created_at`": `"$timestamp`","
    $json += "`n  `"rules`": {"
    $json += "`n    `"split_on`": `"h2`","
    $json += "`n    `"promote_heading`": `"h2_to_h1`","
    $json += "`n    `"naming`": `"<NN>_<NAME_UPPERCASE>.md`","
    $json += "`n    `"intro_file`": `"00_INTRO.md`""
    $json += "`n  },"
    $json += "`n  `"files`": ["
    $json += "`n    " + ($manifestEntries -join ",`n    ")
    $json += "`n  ]"
    $json += "`n}"
    $json | Out-File -FilePath $manifestPath -Encoding utf8
}

Write-Host "Split complete."
Write-Host "Input: $in"
Write-Host "Output: $out"
Write-Host "Count: $($generatedFiles.Count)"
Write-Host "Files:"
foreach ($f in $generatedFiles) {
    Write-Host "  - $f"
}
