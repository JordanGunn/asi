param(
  [Parameter(Mandatory=$true)]
  [ValidateRange(1,3)]
  [int]$Step,
  [Parameter(Mandatory=$true)]
  [string]$Input
)

$ErrorActionPreference = "Stop"

try {
  $repoRoot = (git rev-parse --show-toplevel 2>$null)
  if (-not $repoRoot) { $repoRoot = "." }
} catch {
  $repoRoot = "."
}

Set-Location $repoRoot

$asiDir = ".asi/onboard"
$notesFile = Join-Path $asiDir "NOTES.md"
$sourcesFile = Join-Path $asiDir "SOURCES.md"
$stateFile = Join-Path $asiDir "STATE.json"

if (-not (Test-Path $Input)) { throw "Input JSON does not exist: $Input" }
if (-not (Test-Path $notesFile) -or -not (Test-Path $sourcesFile) -or -not (Test-Path $stateFile)) {
  throw "Onboarding artifacts not initialized. Run scripts/init.ps1 first."
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$json = Get-Content -Raw $Input | ConvertFrom-Json
$summary = $json.output.summary
$reasoning = $json.reasoning_trace

$log = @()
$log += ""
$log += "### Step $Step — $timestamp"
$log += ""
$log += "**Summary**"
$log += ""
$log += $summary
$log += ""

if ($json.output.key_points) {
  $log += "**Key points**"
  $log += ""
  $json.output.key_points | ForEach-Object { $log += "- $_" }
  $log += ""
}

if ($json.output.open_questions) {
  $log += "**Open questions**"
  $log += ""
  $json.output.open_questions | ForEach-Object { $log += "- $_" }
  $log += ""
}

if ($json.output.next_actions) {
  $log += "**Next actions**"
  $log += ""
  $json.output.next_actions | ForEach-Object { $log += "- $_" }
  $log += ""
}

if ($reasoning) {
  $log += "**Reasoning trace**"
  $log += ""
  $log += $reasoning
  $log += ""
}

Add-Content -Path $notesFile -Value ($log -join "`n")

if ($json.output.read) {
  $rows = $json.output.read | ForEach-Object {
    $notes = $_.notes
    if (-not $notes) { $notes = "-" }
    "| ``$($_.path)`` | $($_.why) | $notes |"
  }
  Add-Content -Path $sourcesFile -Value ($rows -join "`n")
}

if (Get-Command jq -ErrorAction SilentlyContinue) {
  $tmp = "$stateFile.tmp"
  jq --arg step "$Step" --arg ts "$timestamp" `
    '.steps[$step].status = "complete" | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' `
    $stateFile | Set-Content -Path $tmp
  Move-Item -Force $tmp $stateFile
} else {
  Write-Host "WARN: jq not found; state file not updated"
}

@{
  action = "asi-onboard-inject"
  status = "complete"
  timestamp = $timestamp
  step = $Step
  input = $Input
  updated = @($notesFile, $sourcesFile, $stateFile)
} | ConvertTo-Json -Depth 6

