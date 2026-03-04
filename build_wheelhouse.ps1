param(
  [string]$WheelhouseDir = "wheelhouse",
  [string]$PythonExe = "python"
)

$ErrorActionPreference = "Stop"

Write-Host "== Wheelhouse Builder (with PyYAML) ==" -ForegroundColor Cyan

# Create/activate venv
if (-not (Test-Path ".venv")) { & $PythonExe -m venv .venv }
. .\.venv\Scripts\Activate.ps1

python -m pip install --upgrade pip setuptools wheel

# Clean wheelhouse
if (Test-Path $WheelhouseDir) { Remove-Item $WheelhouseDir -Recurse -Force }
New-Item -ItemType Directory -Path $WheelhouseDir | Out-Null

# Build wheels (best for locked env)
# Explicitly include PyYAML so it's definitely in wheelhouse
python -m pip wheel boto3 pre-commit PyYAML -w $WheelhouseDir

# Verify PyYAML wheel exists (using *pyyaml*.whl to handle case insensitivity issues)
$pyyamlWheel = Get-ChildItem $WheelhouseDir -Filter "*pyyaml*.whl" -ErrorAction SilentlyContinue

if (-not $pyyamlWheel) {
  throw "PyYAML wheel was NOT created. This usually means your Python version has no PyYAML wheel available (or build tools are missing)."
}

Write-Host "Wheelhouse ready: $WheelhouseDir" -ForegroundColor Green
Get-ChildItem $WheelhouseDir | Sort-Object Name | Select-Object Name
