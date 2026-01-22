# asi-plan validation script
# Read-only checks for skill preconditions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("--check")]
    [string]$Action,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("kickoff-approved", "plan", "todo", "kickoff-drift", "plan-drift", "traceability")]
    [string]$CheckType
)

function Test-KickoffApproved {
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
    
    if (-not ($content -match '^---')) {
        Write-Host "KICKOFF.md missing frontmatter"
        exit 1
    }
    
    if (-not ($content -match '(?m)^status:\s*approved')) {
        $statusMatch = [regex]::Match($content, '(?m)^status:\s*(\S+)')
        $status = if ($statusMatch.Success) { $statusMatch.Groups[1].Value } else { "unknown" }
        Write-Host "KICKOFF.md status is '$status', not 'approved'"
        exit 1
    }
    
    Write-Host "KICKOFF.md exists with status: approved"
    exit 0
}

function Test-Plan {
    $planFile = if ($env:TARGET_DIR) { 
        Join-Path $env:TARGET_DIR "PLAN.md" 
    } else { 
        "./PLAN.md" 
    }
    
    if (-not (Test-Path $planFile)) {
        Write-Host "PLAN.md not found"
        exit 1
    }
    
    $content = Get-Content $planFile -Raw
    
    if (-not ($content -match '^---')) {
        Write-Host "PLAN.md missing frontmatter"
        exit 1
    }
    
    if (-not ($content -match '(?m)^status:')) {
        Write-Host "PLAN.md missing status field"
        exit 1
    }
    
    Write-Host "PLAN.md exists with valid frontmatter"
    exit 0
}

function Test-Todo {
    $todoFile = if ($env:TARGET_DIR) { 
        Join-Path $env:TARGET_DIR "TODO.md" 
    } else { 
        "./TODO.md" 
    }
    
    if (-not (Test-Path $todoFile)) {
        Write-Host "TODO.md not found"
        exit 1
    }
    
    $content = Get-Content $todoFile -Raw
    
    if (-not ($content -match '^---')) {
        Write-Host "TODO.md missing frontmatter"
        exit 1
    }
    
    if (-not ($content -match '(?m)^status:')) {
        Write-Host "TODO.md missing status field"
        exit 1
    }
    
    Write-Host "TODO.md exists with valid frontmatter"
    exit 0
}

function Test-KickoffDrift {
    $planFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "PLAN.md" } else { "./PLAN.md" }
    $kickoffFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "KICKOFF.md" } else { "./KICKOFF.md" }
    
    if (-not (Test-Path $planFile)) { Write-Host "PLAN.md not found"; exit 1 }
    if (-not (Test-Path $kickoffFile)) { Write-Host "KICKOFF.md not found"; exit 1 }
    
    $planContent = Get-Content $planFile -Raw
    $storedHashMatch = [regex]::Match($planContent, '(?m)^source_kickoff_hash:\s*"([a-f0-9]{64})"')
    if (-not $storedHashMatch.Success) { Write-Host "PLAN.md missing source_kickoff_hash"; exit 1 }
    $storedHash = $storedHashMatch.Groups[1].Value
    
    $currentHash = (Get-FileHash -Path $kickoffFile -Algorithm SHA256).Hash.ToLower()
    
    if ($storedHash -ne $currentHash) {
        Write-Host "KICKOFF.md has changed since PLAN.md was created"
        Write-Host "  Stored hash:  $storedHash"
        Write-Host "  Current hash: $currentHash"
        exit 1
    }
    Write-Host "KICKOFF.md unchanged (hash matches)"
    exit 0
}

function Test-PlanDrift {
    $todoFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "TODO.md" } else { "./TODO.md" }
    $planFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "PLAN.md" } else { "./PLAN.md" }
    
    if (-not (Test-Path $todoFile)) { Write-Host "TODO.md not found"; exit 1 }
    if (-not (Test-Path $planFile)) { Write-Host "PLAN.md not found"; exit 1 }
    
    $todoContent = Get-Content $todoFile -Raw
    $storedHashMatch = [regex]::Match($todoContent, '(?m)^source_plan_hash:\s*"([a-f0-9]{64})"')
    if (-not $storedHashMatch.Success) { Write-Host "TODO.md missing source_plan_hash"; exit 1 }
    $storedHash = $storedHashMatch.Groups[1].Value
    
    $currentHash = (Get-FileHash -Path $planFile -Algorithm SHA256).Hash.ToLower()
    
    if ($storedHash -ne $currentHash) {
        Write-Host "PLAN.md has changed since TODO.md was created"
        Write-Host "  Stored hash:  $storedHash"
        Write-Host "  Current hash: $currentHash"
        exit 1
    }
    Write-Host "PLAN.md unchanged (hash matches)"
    exit 0
}

function Test-Traceability {
    $todoFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "TODO.md" } else { "./TODO.md" }
    if (-not (Test-Path $todoFile)) { Write-Host "TODO.md not found"; exit 1 }
    
    $content = Get-Content $todoFile
    $taskCount = 0
    $missingTrace = 0
    
    foreach ($line in $content) {
        if ($line -match '^\|\s*T\d+') {
            $taskCount++
            $columns = $line -split '\|'
            $sourceSection = if ($columns.Count -ge 6) { $columns[5].Trim() } else { "" }
            if ([string]::IsNullOrWhiteSpace($sourceSection)) {
                Write-Host "Task missing source_section: $line"
                $missingTrace++
            }
        }
    }
    
    if ($taskCount -eq 0) { Write-Host "No tasks found in TODO.md"; exit 1 }
    if ($missingTrace -gt 0) { Write-Host "$missingTrace of $taskCount tasks missing source_section"; exit 1 }
    
    Write-Host "All $taskCount tasks have source_section (traceability verified)"
    exit 0
}

switch ($CheckType) {
    "kickoff-approved" { Test-KickoffApproved }
    "plan" { Test-Plan }
    "todo" { Test-Todo }
    "kickoff-drift" { Test-KickoffDrift }
    "plan-drift" { Test-PlanDrift }
    "traceability" { Test-Traceability }
}
