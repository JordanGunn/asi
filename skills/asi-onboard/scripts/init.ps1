param(
  [string]$Topic = "repo-context"
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

$notesTemplate = "skills/asi-onboard/assets/templates/NOTES.template.md"
$sourcesTemplate = "skills/asi-onboard/assets/templates/SOURCES.template.md"

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

New-Item -ItemType Directory -Force -Path $asiDir | Out-Null

function Render-Template($templatePath, $outPath, $topic, $timestamp) {
  $content = Get-Content -Raw $templatePath
  $content = $content.Replace('${timestamp}', $timestamp).Replace('${topic}', $topic)
  Set-Content -Path $outPath -Value $content -NoNewline
}

if (-not (Test-Path $notesFile)) {
  Render-Template $notesTemplate $notesFile $Topic $timestamp
}

if (-not (Test-Path $sourcesFile)) {
  Render-Template $sourcesTemplate $sourcesFile $Topic $timestamp
}

if (-not (Test-Path $stateFile)) {
  $state = @{
    topic = $Topic
    initialized_at = $timestamp
    current_step = 0
    steps = @{
      "0" = @{ name = "init"; status = "complete"; completed_at = $timestamp }
      "1" = @{ name = "entrypoints"; status = "pending"; completed_at = $null }
      "2" = @{ name = "deepening"; status = "pending"; completed_at = $null }
      "3" = @{ name = "handoff"; status = "pending"; completed_at = $null }
    }
  }
  $state | ConvertTo-Json -Depth 10 | Set-Content -Path $stateFile
}

@{
  action = "asi-onboard-init"
  status = "complete"
  timestamp = $timestamp
  topic = $Topic
  target_directory = (Get-Location).Path
  created_or_verified = @($notesFile, $sourcesFile, $stateFile)
  next_step = 1
  next_action = "Read entrypoints, then write .asi/onboard/step_1_output.json and run: scripts/inject.sh --step 1 --input .asi/onboard/step_1_output.json"
} | ConvertTo-Json -Depth 6

