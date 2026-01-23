#Requires -Version 7.0
param(
    [string]$Task,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$PLAN_DIR = ".asi/plan"
$EXEC_DIR = ".asi/exec"
$TODO_FILE = "$PLAN_DIR/TODO.md"
$PARSED_FILE = "$EXEC_DIR/PLAN_PARSED.json"
$STATE_FILE = "$EXEC_DIR/STATE.json"

function Show-Usage {
    @"
Usage: select-task.ps1 [-Task <task-id>]

Arguments:
  -Task   Optional. Select specific task by ID (e.g., T001).
          If not provided, selects next pending task.

This script:
  1. Reads PLAN_PARSED.json for task list
  2. Finds next task (in_progress > pending, or specific -Task)
  3. Validates task dependencies are satisfied
  4. Outputs task details as JSON
  5. Updates STATE.json with current task

Exit codes:
  0  Task selected successfully
  1  No tasks available or dependencies not met
  2  Invalid arguments
"@
    exit 2
}

if ($Help) { Show-Usage }

if (-not (Test-Path $PARSED_FILE)) {
    Write-Error "ERROR: $PARSED_FILE does not exist. Run init.ps1 first."
    exit 1
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$parsed = Get-Content $PARSED_FILE | ConvertFrom-Json
$tasks = $parsed.tasks

$selectedTask = $null

if ($Task) {
    $selectedTask = $tasks | Where-Object { $_.id -eq $Task }
    if (-not $selectedTask) {
        Write-Error "ERROR: Task $Task not found"
        exit 1
    }
} else {
    $selectedTask = $tasks | Where-Object { $_.status -eq "in_progress" } | Select-Object -First 1
    if (-not $selectedTask) {
        $selectedTask = $tasks | Where-Object { $_.status -eq "pending" } | Select-Object -First 1
    }
    if (-not $selectedTask) {
        Write-Host "INFO: No pending tasks remaining" -ForegroundColor Yellow
        @{
            action = "asi-exec-select-task"
            status = "all_done"
            timestamp = $timestamp
            message = "All tasks complete"
        } | ConvertTo-Json
        exit 0
    }
}

if ($selectedTask.status -eq "done") {
    Write-Error "ERROR: Task $($selectedTask.id) is already done"
    exit 1
}

$blocked = $false
$blockedBy = @()

if ($selectedTask.depends_on -and $selectedTask.depends_on -ne "-") {
    $deps = $selectedTask.depends_on -split '[,\s]+' | Where-Object { $_ }
    foreach ($dep in $deps) {
        $depTask = $tasks | Where-Object { $_.id -eq $dep }
        if ($depTask -and $depTask.status -ne "done") {
            $blocked = $true
            $blockedBy += $dep
        }
    }
}

if ($blocked) {
    Write-Error "ERROR: Task $($selectedTask.id) is blocked by: $($blockedBy -join ', ')"
    @{
        action = "asi-exec-select-task"
        status = "blocked"
        timestamp = $timestamp
        task_id = $selectedTask.id
        blocked_by = $blockedBy -join ", "
        message = "Dependencies not satisfied"
    } | ConvertTo-Json
    exit 1
}

if (Test-Path $STATE_FILE) {
    $state = Get-Content $STATE_FILE | ConvertFrom-Json
    $state.current_task = $selectedTask.id
    $state.execution_log += @{
        event = "task_selected"
        task = $selectedTask.id
        timestamp = $timestamp
    }
    $state | ConvertTo-Json -Depth 10 | Set-Content $STATE_FILE
}

@{
    action = "asi-exec-select-task"
    status = "selected"
    timestamp = $timestamp
    task = @{
        id = $selectedTask.id
        description = $selectedTask.description
        status = $selectedTask.status
        depends_on = $selectedTask.depends_on
        source_section = $selectedTask.source_section
    }
    next_action = "Execute task, then run scripts/update-status.ps1 -Task $($selectedTask.id) -Status in_progress"
} | ConvertTo-Json -Depth 5
