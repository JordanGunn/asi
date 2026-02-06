#!/usr/bin/env pwsh
# asi-creator skill wrapper - delegates to asi CLI
$ErrorActionPreference = "Stop"

function Show-Help {
@"
asi-creator - Create ASI-compliant skills (CLI-owned)

Commands:
  help                         Show this help message
  init                         Emit all skill reference docs (concatenated)
  validate                     Verify the skill is runnable (read-only)
  schema [run|suggest|apply]   Emit JSON schema (default: run)
  run --stdin                  Execute creator via plan JSON
  next                         Emit next questions (interactive loop)
  suggest --stdin              Validate agent suggestions
  apply --stdin                Apply user answers

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
    param(
        [string]$Target = "run"
    )

    switch ($Target) {
        "run" { & asi creator --schema }
        "suggest" { & asi creator suggest --schema }
        "apply" { & asi creator apply --schema }
        default {
            Write-Error "error: unknown schema target '$Target' (expected: run|suggest|apply)"
            exit 1
        }
    }
}

function Invoke-Run {
    & asi creator run --stdin
}

function Invoke-Next {
    & asi creator next
}

function Invoke-Suggest {
    & asi creator suggest --stdin
}

function Invoke-Apply {
    & asi creator apply --stdin
}

$command = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($command) {
    "help" { Show-Help }
    "init" { Invoke-Init }
    "validate" { Invoke-Validate }
    "schema" {
        $target = if ($args.Count -gt 1) { $args[1] } else { "run" }
        Invoke-Schema -Target $target
    }
    "run" { Invoke-Run }
    "next" { Invoke-Next }
    "suggest" { Invoke-Suggest }
    "apply" { Invoke-Apply }
    default {
        Write-Error "error: unknown command '$command'"
        exit 1
    }
}
