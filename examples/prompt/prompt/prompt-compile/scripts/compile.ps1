#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $PSCommandPath
$IncludeDir = Join-Path $ScriptDir "include"

$ConfigPath = Join-Path $ScriptDir ".config.ps1"
if (Test-Path $ConfigPath) {
    . $ConfigPath
}

$env:PYTHONPATH = $IncludeDir
uv run --project $IncludeDir python (Join-Path $IncludeDir "prompt_compile_cli.py") $args
