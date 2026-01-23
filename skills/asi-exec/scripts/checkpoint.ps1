#Requires -Version 7.0
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("init", "drift", "task-ready", "task-complete", "all-done", "state")]
    [string]$Check,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$KICKOFF_DIR = ".asi/kickoff"
$PLAN_DIR = ".asi/plan"
$EXEC_DIR = ".asi/exec"
$PLAN_FILE = "$PLAN_DIR/PLAN.md"
$TODO_FILE = "$PLAN_DIR/TODO.md"
$PARSED_FILE = "$EXEC_DIR/PLAN_PARSED.json"
$STATE_FILE = "$EXEC_DIR/STATE.json"
$RECEIPT_FILE = "$EXEC_DIR/RECEIPT.md"

function Show-Usage {
    @"
Usage: checkpoint.ps1 -Check <check-type>

Check types:
  init              Verify initialization complete
  drift             Check for upstream artifact drift
  task-ready        Verify task can be executed (deps satisfied)
  task-complete     Verify task execution complete
  all-done          Verify all tasks complete
  state             Show current execution state

Exit codes:
  0  Check passed
  1  Check failed
  2  Invalid arguments
"@
    exit 2
}

function Get-FrontmatterField {
    param([string]$File, [string]$Field)
    $content = Get-Content $File -Raw
    if ($content -match "(?ms)^---\s*\n(.*?)\n---") {
        $frontmatter = $Matches[1]
        if ($frontmatter -match "(?m)^${Field}:\s*(.+)$") {
            $value = $Matches[1].Trim()
            $value = $value -replace '^["'']|["'']$', ''
            return $value
        }
    }
    return ""
}

function Test-Init {
    Write-Host "=== Checking initialization ===" -ForegroundColor Cyan
    $failed = 0
    
    if (-not (Test-Path $EXEC_DIR)) {
        Write-Host "FAIL: $EXEC_DIR does not exist" -ForegroundColor Red
        return 1
    }
    Write-Host "PASS: $EXEC_DIR exists" -ForegroundColor Green
    
    if (-not (Test-Path $PARSED_FILE)) {
        Write-Host "FAIL: $PARSED_FILE does not exist" -ForegroundColor Red
        $failed = 1
    } else {
        Write-Host "PASS: $PARSED_FILE exists" -ForegroundColor Green
    }
    
    if (-not (Test-Path $STATE_FILE)) {
        Write-Host "FAIL: $STATE_FILE does not exist" -ForegroundColor Red
        $failed = 1
    } else {
        Write-Host "PASS: $STATE_FILE exists" -ForegroundColor Green
    }
    
    if ($failed -eq 0) {
        Write-Host "=== Initialization: PASSED ===" -ForegroundColor Green
    } else {
        Write-Host "=== Initialization: FAILED ===" -ForegroundColor Red
    }
    return $failed
}

function Test-Drift {
    Write-Host "=== Checking for drift ===" -ForegroundColor Cyan
    
    if (-not (Test-Path $STATE_FILE)) {
        Write-Host "FAIL: $STATE_FILE does not exist" -ForegroundColor Red
        return 1
    }
    
    $failed = 0
    $state = Get-Content $STATE_FILE | ConvertFrom-Json
    
    if ($state.source_plan_hash -and (Test-Path $PLAN_FILE)) {
        $currentHash = (Get-FileHash $PLAN_FILE -Algorithm SHA256).Hash.ToLower()
        if ($state.source_plan_hash -ne $currentHash) {
            Write-Host "FAIL: PLAN.md has changed (drift detected)" -ForegroundColor Red
            $failed = 1
        } else {
            Write-Host "PASS: PLAN.md unchanged" -ForegroundColor Green
        }
    }
    
    if ($failed -eq 0) {
        Write-Host "=== Drift check: PASSED ===" -ForegroundColor Green
    } else {
        Write-Host "=== Drift check: FAILED ===" -ForegroundColor Red
    }
    return $failed
}

function Test-TaskReady {
    Write-Host "=== Checking task readiness ===" -ForegroundColor Cyan
    
    if (-not (Test-Path $STATE_FILE)) {
        Write-Host "FAIL: $STATE_FILE does not exist" -ForegroundColor Red
        return 1
    }
    
    $state = Get-Content $STATE_FILE | ConvertFrom-Json
    
    if (-not $state.current_task) {
        Write-Host "INFO: No current task selected" -ForegroundColor Yellow
        Write-Host "Run scripts/select-task.ps1 first"
        return 1
    }
    
    Write-Host "Current task: $($state.current_task)" -ForegroundColor Cyan
    
    $parsed = Get-Content $PARSED_FILE | ConvertFrom-Json
    $task = $parsed.tasks | Where-Object { $_.id -eq $state.current_task }
    
    if ($task.status -eq "done") {
        Write-Host "INFO: Task $($state.current_task) is already done" -ForegroundColor Yellow
        return 1
    }
    
    Write-Host "Task status: $($task.status)" -ForegroundColor Cyan
    Write-Host "=== Task ready: PASSED ===" -ForegroundColor Green
    return 0
}

function Test-TaskComplete {
    Write-Host "=== Checking task completion ===" -ForegroundColor Cyan
    
    if (-not (Test-Path $STATE_FILE)) {
        Write-Host "FAIL: $STATE_FILE does not exist" -ForegroundColor Red
        return 1
    }
    
    $state = Get-Content $STATE_FILE | ConvertFrom-Json
    
    if (-not $state.current_task) {
        if ($state.completed_tasks -and $state.completed_tasks.Count -gt 0) {
            $last = $state.completed_tasks[-1]
            Write-Host "Last completed task: $last" -ForegroundColor Cyan
            Write-Host "=== Task completion: PASSED ===" -ForegroundColor Green
            return 0
        }
        Write-Host "INFO: No current or recently completed task" -ForegroundColor Yellow
        return 1
    }
    
    $todoContent = Get-Content $TODO_FILE
    $taskLine = $todoContent | Where-Object { $_ -match "^\|\s*$($state.current_task)\s*\|" }
    $parts = $taskLine -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $taskStatus = $parts[2]
    
    if ($taskStatus -eq "done") {
        Write-Host "Task $($state.current_task): done" -ForegroundColor Green
        Write-Host "=== Task completion: PASSED ===" -ForegroundColor Green
        return 0
    } else {
        Write-Host "Task $($state.current_task): $taskStatus (expected: done)" -ForegroundColor Yellow
        Write-Host "=== Task completion: PENDING ===" -ForegroundColor Yellow
        return 1
    }
}

function Test-AllDone {
    Write-Host "=== Checking all tasks ===" -ForegroundColor Cyan
    
    if (-not (Test-Path $TODO_FILE)) {
        Write-Host "FAIL: $TODO_FILE does not exist" -ForegroundColor Red
        return 1
    }
    
    $content = Get-Content $TODO_FILE
    $pending = ($content | Select-String '\| pending \|').Count
    $inProgress = ($content | Select-String '\| in_progress \|').Count
    $done = ($content | Select-String '\| done \|').Count
    
    Write-Host "Pending: $pending"
    Write-Host "In progress: $inProgress"
    Write-Host "Done: $done"
    
    if ($pending -eq 0 -and $inProgress -eq 0) {
        Write-Host "=== All tasks: COMPLETE ===" -ForegroundColor Green
        return 0
    } else {
        Write-Host "=== All tasks: INCOMPLETE ===" -ForegroundColor Yellow
        return 1
    }
}

function Show-State {
    Write-Host "=== Current execution state ===" -ForegroundColor Cyan
    
    if (-not (Test-Path $STATE_FILE)) {
        Write-Host "Not initialized. Run scripts/init.ps1 first." -ForegroundColor Yellow
        return 1
    }
    
    Get-Content $STATE_FILE | ConvertFrom-Json | ConvertTo-Json -Depth 10
    return 0
}

if ($Help) { Show-Usage }

switch ($Check) {
    "init" { exit (Test-Init) }
    "drift" { exit (Test-Drift) }
    "task-ready" { exit (Test-TaskReady) }
    "task-complete" { exit (Test-TaskComplete) }
    "all-done" { exit (Test-AllDone) }
    "state" { exit (Show-State) }
}
