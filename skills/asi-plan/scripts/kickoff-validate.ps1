# asi-kickoff validation script
# Read-only checks for skill preconditions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("--check")]
    [string]$Action,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("kickoff", "questions")]
    [string]$CheckType
)

function Test-Questions {
    $questionsFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "QUESTIONS.md" } else { "./QUESTIONS.md" }
    
    if (-not (Test-Path $questionsFile)) { Write-Host "QUESTIONS.md not found"; exit 1 }
    
    $content = Get-Content $questionsFile -Raw
    $unresolved = ([regex]::Matches($content, '^- \[ \]', 'Multiline')).Count
    $resolved = ([regex]::Matches($content, '^- \[x\]', 'Multiline')).Count
    
    $statusMatch = [regex]::Match($content, '(?m)^status:\s*(\S+)')
    $status = if ($statusMatch.Success) { $statusMatch.Groups[1].Value } else { "unknown" }
    
    Write-Host "QUESTIONS.md: $resolved resolved, $unresolved unresolved (status: $status)"
    
    if ($unresolved -gt 0) { Write-Host "Unresolved questions remain"; exit 1 }
    
    exit 0
}

function Test-Kickoff {
    $kickoffFile = if ($env:TARGET_DIR) { 
        Join-Path $env:TARGET_DIR "KICKOFF.md" 
    } else { 
        "./KICKOFF.md" 
    }
    
    if (-not (Test-Path $kickoffFile)) {
        Write-Host "KICKOFF.md not found"
        exit 1
    }
    
    $content = Get-Content $kickoffFile -Raw
    
    # Check for valid frontmatter
    if (-not ($content -match '^---')) {
        Write-Host "KICKOFF.md missing frontmatter"
        exit 1
    }
    
    # Check for required frontmatter fields
    if (-not ($content -match '(?m)^status:')) {
        Write-Host "KICKOFF.md missing status field"
        exit 1
    }
    
    Write-Host "KICKOFF.md exists with valid frontmatter"
    exit 0
}

switch ($CheckType) {
    "kickoff" { Test-Kickoff }
    "questions" { Test-Questions }
}
