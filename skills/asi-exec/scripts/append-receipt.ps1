#Requires -Version 7.0
param(
    [Parameter(Mandatory=$true)]
    [string]$Input,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$EXEC_DIR = ".asi/exec"
$RECEIPT_FILE = "$EXEC_DIR/RECEIPT.md"
$STATE_FILE = "$EXEC_DIR/STATE.json"

function Show-Usage {
    @"
Usage: append-receipt.ps1 -Input <json-file>

Arguments:
  -Input   Required. Path to receipt JSON file conforming to exec_receipt_v1.schema.json.

This script:
  1. Validates receipt JSON
  2. Formats receipt as markdown
  3. Appends to RECEIPT.md
  4. Logs event to STATE.json
  5. Emits confirmation

Exit codes:
  0  Receipt appended successfully
  1  Append failed
  2  Invalid arguments
"@
    exit 2
}

if ($Help) { Show-Usage }

if (-not (Test-Path $Input)) {
    Write-Error "ERROR: Input file does not exist: $Input"
    exit 1
}

$receipt = Get-Content $Input | ConvertFrom-Json

$taskId = $receipt.task_id
$status = $receipt.status
$timestamp = if ($receipt.timestamp) { $receipt.timestamp } else { (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }

if (-not $taskId) {
    Write-Error "ERROR: Receipt missing task_id"
    exit 1
}

if (-not $status) {
    Write-Error "ERROR: Receipt missing status"
    exit 1
}

$artifactsCreated = if ($receipt.artifacts_created) { $receipt.artifacts_created -join ", " } else { "" }
$artifactsModified = if ($receipt.artifacts_modified) { $receipt.artifacts_modified -join ", " } else { "" }
$errorMsg = if ($receipt.error) { $receipt.error } else { "" }
$notes = if ($receipt.notes) { $receipt.notes } else { "" }

if (-not (Test-Path $RECEIPT_FILE)) {
    New-Item -ItemType Directory -Path $EXEC_DIR -Force | Out-Null
    $header = @"
---
description: "Execution receipts"
timestamp: "$timestamp"
---

# Execution Receipts

## Log

"@
    Set-Content -Path $RECEIPT_FILE -Value $header
}

$entry = @"
### $taskId - $status

- **Timestamp:** $timestamp
"@

if ($artifactsCreated) { $entry += "`n- **Created:** $artifactsCreated" }
if ($artifactsModified) { $entry += "`n- **Modified:** $artifactsModified" }
if ($errorMsg) { $entry += "`n- **Error:** $errorMsg" }
if ($notes) { $entry += "`n- **Notes:** $notes" }

$entry += "`n`n---`n"

Add-Content -Path $RECEIPT_FILE -Value $entry

Write-Host "Appended receipt for $taskId to $RECEIPT_FILE" -ForegroundColor Green

if (Test-Path $STATE_FILE) {
    $state = Get-Content $STATE_FILE | ConvertFrom-Json
    $state.execution_log += @{
        event = "receipt_appended"
        task = $taskId
        status = $status
        timestamp = $timestamp
    }
    $state | ConvertTo-Json -Depth 10 | Set-Content $STATE_FILE
}

@{
    action = "asi-exec-append-receipt"
    status = "appended"
    timestamp = $timestamp
    task_id = $taskId
    task_status = $status
    receipt_file = $RECEIPT_FILE
} | ConvertTo-Json
