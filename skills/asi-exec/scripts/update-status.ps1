#Requires -Version 7.0
param(
    [Parameter(Mandatory=$true)]
    [string]$Task,
    [Parameter(Mandatory=$true)]
    [ValidateSet("pending", "in_progress", "done")]
    [string]$Status,
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
Usage: update-status.ps1 -Task <task-id> -Status <status>

Arguments:
  -Task     Required. Task ID to update (e.g., T001).
  -Status   Required. New status: pending, in_progress, or done.

This script:
  1. Validates task exists
  2. Updates task status in TODO.md
  3. Updates PLAN_PARSED.json
  4. Logs event to STATE.json
  5. Emits receipt

Exit codes:
  0  Status updated successfully
  1  Update failed
  2  Invalid arguments
"@
    exit 2
}

if ($Help) { Show-Usage }

if (-not (Test-Path $TODO_FILE)) {
    Write-Error "ERROR: $TODO_FILE does not exist"
    exit 1
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$todoContent = Get-Content $TODO_FILE
$taskLine = $todoContent | Where-Object { $_ -match "^\|\s*$Task\s*\|" }

if (-not $taskLine) {
    Write-Error "ERROR: Task $Task not found in $TODO_FILE"
    exit 1
}

$parts = $taskLine -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$currentStatus = $parts[2]

if ($currentStatus -eq $Status) {
    Write-Host "INFO: Task $Task is already $Status" -ForegroundColor Yellow
    @{
        action = "asi-exec-update-status"
        status = "no_change"
        timestamp = $timestamp
        task_id = $Task
        task_status = $Status
    } | ConvertTo-Json
    exit 0
}

$updatedContent = $todoContent -replace "^\|\s*$Task\s*\|([^|]+)\|\s*$currentStatus\s*\|", "| $Task |`$1| $Status |"
Set-Content -Path $TODO_FILE -Value $updatedContent

Write-Host "Updated $Task: $currentStatus -> $Status" -ForegroundColor Green

if (Test-Path $PARSED_FILE) {
    $parsed = Get-Content $PARSED_FILE | ConvertFrom-Json
    $parsed.tasks | Where-Object { $_.id -eq $Task } | ForEach-Object { $_.status = $Status }
    $parsed.summary.pending = ($parsed.tasks | Where-Object { $_.status -eq "pending" }).Count
    $parsed.summary.done = ($parsed.tasks | Where-Object { $_.status -eq "done" }).Count
    $parsed | ConvertTo-Json -Depth 10 | Set-Content $PARSED_FILE
}

if (Test-Path $STATE_FILE) {
    $state = Get-Content $STATE_FILE | ConvertFrom-Json
    $event = @{
        event = "status_changed"
        task = $Task
        from = $currentStatus
        to = $Status
        timestamp = $timestamp
    }
    $state.execution_log += $event
    
    if ($Status -eq "done") {
        if ($state.current_task -eq $Task) { $state.current_task = $null }
        if ($state.completed_tasks -notcontains $Task) { $state.completed_tasks += $Task }
    }
    if ($Status -eq "in_progress") {
        $state.current_task = $Task
    }
    $state | ConvertTo-Json -Depth 10 | Set-Content $STATE_FILE
}

@{
    action = "asi-exec-update-status"
    status = "updated"
    timestamp = $timestamp
    task_id = $Task
    previous_status = $currentStatus
    new_status = $Status
} | ConvertTo-Json
