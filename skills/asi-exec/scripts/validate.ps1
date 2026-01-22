# asi-exec validation script
# Read-only checks for skill preconditions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("--check")]
    [string]$Action,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("plan-approved", "plan-drift", "todo", "task-pending", "deps-satisfied", "lock-check", "lock-acquire", "lock-release")]
    [string]$CheckType
)

function Test-PlanApproved {
    $planFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "PLAN.md" } else { "./PLAN.md" }
    
    if (-not (Test-Path $planFile)) { Write-Host "PLAN.md not found"; exit 1 }
    
    $content = Get-Content $planFile -Raw
    
    if (-not ($content -match '^---')) { Write-Host "PLAN.md missing frontmatter"; exit 1 }
    
    if (-not ($content -match '(?m)^status:\s*approved')) {
        $statusMatch = [regex]::Match($content, '(?m)^status:\s*(\S+)')
        $status = if ($statusMatch.Success) { $statusMatch.Groups[1].Value } else { "unknown" }
        Write-Host "PLAN.md status is '$status', not 'approved'"
        exit 1
    }
    
    Write-Host "PLAN.md exists with status: approved"
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
        Write-Host "PLAN.md has changed since TODO.md was created (drift detected)"
        Write-Host "  Stored hash:  $storedHash"
        Write-Host "  Current hash: $currentHash"
        exit 1
    }
    Write-Host "PLAN.md unchanged (no drift)"
    exit 0
}

function Test-Todo {
    $todoFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "TODO.md" } else { "./TODO.md" }
    
    if (-not (Test-Path $todoFile)) { Write-Host "TODO.md not found"; exit 1 }
    
    $content = Get-Content $todoFile -Raw
    
    if (-not ($content -match '^---')) { Write-Host "TODO.md missing frontmatter"; exit 1 }
    if (-not ($content -match '(?m)^status:')) { Write-Host "TODO.md missing status field"; exit 1 }
    
    Write-Host "TODO.md exists with valid frontmatter"
    exit 0
}

function Test-TaskPending {
    $todoFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR "TODO.md" } else { "./TODO.md" }
    
    if (-not (Test-Path $todoFile)) { Write-Host "TODO.md not found"; exit 1 }
    
    $content = Get-Content $todoFile
    foreach ($line in $content) {
        if ($line -match '^\|\s*T\d+.*\|\s*(pending|in_progress|blocked)\s*\|') {
            Write-Host "Pending tasks found"
            exit 0
        }
    }
    
    Write-Host "No pending tasks (all done or no tasks)"
    exit 1
}

function Test-DepsSatisfied {
    Write-Host "Dependency check requires task context (use agent reasoning)"
    exit 0
}

function Test-Lock {
    $lockFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR ".asi-exec.lock" } else { "./.asi-exec.lock" }
    $staleThreshold = 3600  # 1 hour in seconds
    
    if (-not (Test-Path $lockFile)) {
        Write-Host "No lock file - execution allowed"
        exit 0
    }
    
    $lockAge = [int]((Get-Date) - (Get-Item $lockFile).LastWriteTime).TotalSeconds
    
    if ($lockAge -gt $staleThreshold) {
        Write-Host "Stale lock detected (age: ${lockAge}s) - removing"
        Remove-Item $lockFile -Force
        exit 0
    }
    
    Write-Host "Execution locked (age: ${lockAge}s)"
    Get-Content $lockFile
    exit 1
}

function Invoke-AcquireLock {
    $lockFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR ".asi-exec.lock" } else { "./.asi-exec.lock" }
    $taskId = if ($env:TASK_ID) { $env:TASK_ID } else { "unknown" }
    $staleThreshold = 3600
    
    if (Test-Path $lockFile) {
        $lockAge = [int]((Get-Date) - (Get-Item $lockFile).LastWriteTime).TotalSeconds
        if ($lockAge -le $staleThreshold) {
            Write-Host "Cannot acquire lock - execution in progress"
            exit 1
        }
        Write-Host "Removing stale lock"
    }
    
    @"
timestamp: $(Get-Date -Format "o")
task_id: $taskId
pid: $PID
"@ | Set-Content $lockFile
    
    Write-Host "Lock acquired for task: $taskId"
    exit 0
}

function Invoke-ReleaseLock {
    $lockFile = if ($env:TARGET_DIR) { Join-Path $env:TARGET_DIR ".asi-exec.lock" } else { "./.asi-exec.lock" }
    
    if (-not (Test-Path $lockFile)) {
        Write-Host "No lock to release"
        exit 0
    }
    
    Remove-Item $lockFile -Force
    Write-Host "Lock released"
    exit 0
}

switch ($CheckType) {
    "plan-approved" { Test-PlanApproved }
    "plan-drift" { Test-PlanDrift }
    "todo" { Test-Todo }
    "task-pending" { Test-TaskPending }
    "deps-satisfied" { Test-DepsSatisfied }
    "lock-check" { Test-Lock }
    "lock-acquire" { Invoke-AcquireLock }
    "lock-release" { Invoke-ReleaseLock }
}
