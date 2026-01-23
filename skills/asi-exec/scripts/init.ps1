#Requires -Version 7.0
param(
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$KICKOFF_DIR = ".asi/kickoff"
$PLAN_DIR = ".asi/plan"
$EXEC_DIR = ".asi/exec"
$PLAN_FILE = "$PLAN_DIR/PLAN.md"
$TODO_FILE = "$PLAN_DIR/TODO.md"
$SCAFFOLD_FILE = "$KICKOFF_DIR/SCAFFOLD.json"
$PARSED_FILE = "$EXEC_DIR/PLAN_PARSED.json"
$STATE_FILE = "$EXEC_DIR/STATE.json"
$RECEIPT_FILE = "$EXEC_DIR/RECEIPT.md"

function Show-Usage {
    @"
Usage: init.ps1 [-Force]

Arguments:
  -Force  Reinitialize even if exec directory exists.

This script:
  1. Validates prerequisites (PLAN.md approved, TODO.md exists)
  2. Parses plan artifacts into structured JSON
  3. Creates .asi/exec/ directory
  4. Parses TODO.md tasks into structured format
  5. Computes source_plan_hash for drift detection
  6. Creates STATE.json to track execution progress
  7. Emits receipt to stdout

Exit codes:
  0  Initialization complete
  1  Initialization failed (prerequisites not met)
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

if ($Help) { Show-Usage }

Write-Host "=== Validating prerequisites ===" -ForegroundColor Cyan

if (-not (Test-Path $PLAN_DIR)) {
    Write-Error "ERROR: $PLAN_DIR does not exist. Run asi-plan first."
    exit 1
}

if (-not (Test-Path $PLAN_FILE)) {
    Write-Error "ERROR: $PLAN_FILE does not exist. Run asi-plan first."
    exit 1
}

$planStatus = Get-FrontmatterField -File $PLAN_FILE -Field "status"
if ($planStatus -ne "approved") {
    Write-Error "ERROR: PLAN.md status is '$planStatus', expected 'approved'. Approve the plan before running asi-exec."
    exit 1
}

if (-not (Test-Path $TODO_FILE)) {
    Write-Error "ERROR: $TODO_FILE does not exist. Run asi-plan first."
    exit 1
}

if (-not (Test-Path $SCAFFOLD_FILE)) {
    Write-Warning "WARN: $SCAFFOLD_FILE does not exist. Scaffolding tasks may fail."
}

Write-Host "Prerequisites validated." -ForegroundColor Green

if ((Test-Path $EXEC_DIR) -and -not $Force) {
    if (Test-Path $STATE_FILE) {
        Write-Host "INFO: Execution already initialized. Use -Force to reinitialize." -ForegroundColor Yellow
        Get-Content $STATE_FILE
        exit 0
    }
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$planHash = (Get-FileHash $PLAN_FILE -Algorithm SHA256).Hash.ToLower()
$todoHash = (Get-FileHash $TODO_FILE -Algorithm SHA256).Hash.ToLower()
$skillName = Get-FrontmatterField -File $PLAN_FILE -Field "skill_name"

New-Item -ItemType Directory -Path $EXEC_DIR -Force | Out-Null

Write-Host "=== Parsing plan artifacts ===" -ForegroundColor Cyan

$tasks = @()
Get-Content $TODO_FILE | ForEach-Object {
    if ($_ -match '^\|\s*(T\d+)\s*\|') {
        $parts = $_ -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        if ($parts.Count -ge 5) {
            $tasks += @{
                id = $parts[0]
                description = $parts[1]
                status = $parts[2]
                depends_on = $parts[3]
                source_section = $parts[4]
            }
        }
    }
}

$taskCount = $tasks.Count
$pendingCount = ($tasks | Where-Object { $_.status -eq "pending" }).Count
$doneCount = ($tasks | Where-Object { $_.status -eq "done" }).Count

$parsedContent = @{
    source = @{
        plan_path = $PLAN_FILE
        plan_hash = $planHash
        todo_path = $TODO_FILE
        todo_hash = $todoHash
        scaffold_path = $SCAFFOLD_FILE
        parsed_at = $timestamp
    }
    skill_name = $skillName
    tasks = $tasks
    summary = @{
        total = $taskCount
        pending = $pendingCount
        done = $doneCount
    }
} | ConvertTo-Json -Depth 10

Set-Content -Path $PARSED_FILE -Value $parsedContent
Write-Host "Created $PARSED_FILE" -ForegroundColor Green

$stateContent = @{
    skill_name = $skillName
    source_plan = $PLAN_FILE
    source_plan_hash = $planHash
    source_todo = $TODO_FILE
    source_todo_hash = $todoHash
    initialized_at = $timestamp
    current_task = $null
    completed_tasks = @()
    execution_log = @()
} | ConvertTo-Json -Depth 10

Set-Content -Path $STATE_FILE -Value $stateContent
Write-Host "Created $STATE_FILE" -ForegroundColor Green

if (-not (Test-Path $RECEIPT_FILE)) {
    $receiptContent = @"
---
description: "Execution receipts for $skillName"
timestamp: "$timestamp"
source_plan: "$PLAN_FILE"
---

# Execution Receipts: $skillName

## Log

<!-- Receipts appended below by scripts/append-receipt.ps1 -->

"@
    Set-Content -Path $RECEIPT_FILE -Value $receiptContent
    Write-Host "Created $RECEIPT_FILE" -ForegroundColor Green
}

@{
    action = "asi-exec-init"
    status = "complete"
    timestamp = $timestamp
    skill_name = $skillName
    source_plan = $PLAN_FILE
    source_plan_hash = $planHash
    task_summary = @{
        total = $taskCount
        pending = $pendingCount
        done = $doneCount
    }
    created = @($PARSED_FILE, $STATE_FILE, $RECEIPT_FILE)
    next_action = "Run scripts/select-task.ps1 to get next task, then execute"
} | ConvertTo-Json -Depth 5
