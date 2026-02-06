#!/usr/bin/env pwsh
# asi-onboard skill wrapper - delegates to asi CLI
$ErrorActionPreference = "Stop"

function Show-Help {
@"
asi-onboard - Establish repository context (CLI-owned)

Commands:
  help                         Show this help message
  init                         Emit all skill reference docs (concatenated)
  validate                     Verify the skill is runnable (read-only)
  schema                       Emit JSON schema for plan input
  run --stdin                  Execute onboard via plan JSON

Execution backend: asi CLI
"@
}

function Invoke-Init {
    $skillDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $skillDir = Split-Path -Parent $skillDir
    & asi skill init --skill-dir $skillDir
}

function Invoke-Validate {
    if (-not (Get-Command asi -ErrorAction SilentlyContinue)) {
        Write-Error "error: asi CLI not found. Install from skills/cli/."
        exit 1
    }
    & asi doctor
}

function Invoke-Schema {
    & asi onboard --schema
}

function Invoke-Run {
    & asi onboard run --stdin
}

$command = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($command) {
    "help" { Show-Help }
    "init" { Invoke-Init }
    "validate" { Invoke-Validate }
    "schema" { Invoke-Schema }
    "run" { Invoke-Run }
    default {
        Write-Error "error: unknown command '$command'"
        exit 1
    }
}
