# Downloads Rigel (NVIDIA GPU miner) from its official GitHub release and verifies SHA256.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$ver = '1.23.2'
$sha = '0a35d37504e2595f2cd9bb25ae69eae39625be6f0ebbdbaf7427d4c381a7fd79'
$url = "https://github.com/rigelminer/rigel/releases/download/$ver/rigel-$ver-win.zip"
$root = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $root 'miner'
$exe = Join-Path $dir "rigel-$ver-win\rigel.exe"
$zip = Join-Path $dir "rigel-$ver-win.zip"
if (Test-Path $exe) { Write-Host "Rigel $ver found."; exit 0 }
New-Item -ItemType Directory -Force -Path $dir | Out-Null
function Hash($p) { (Get-FileHash -Algorithm SHA256 -Path $p).Hash.ToLower() }
if (-not ((Test-Path $zip) -and ((Hash $zip) -eq $sha))) {
  Write-Host "Downloading Rigel $ver from $url (about 56 MB) ..."
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
  } catch {
    Write-Host "Download failed: $($_.Exception.Message)"
    Write-Host "Download it with a browser from $url"
    Write-Host "and save it as: $zip   then run start-mining.bat again."
    exit 1
  }
}
$h = Hash $zip
if ($h -ne $sha) {
  Write-Host "SHA256 mismatch for $zip"
  Write-Host "  expected $sha"
  Write-Host "  got      $h"
  Remove-Item -Force $zip
  exit 1
}
Write-Host "SHA256 OK ($sha). Extracting ..."
Expand-Archive -Path $zip -DestinationPath $dir -Force
Start-Sleep -Seconds 2
if (-not (Test-Path $exe)) {
  Write-Host ""
  Write-Host "rigel.exe is missing after extraction. Windows Defender most likely quarantined it"
  Write-Host "(miners are flagged as 'potentially unwanted' even when you run them on purpose)."
  Write-Host "Windows Security > Virus & threat protection > Manage settings > Exclusions >"
  Write-Host "Add an exclusion > Folder:  $root"
  Write-Host "Then restore the file from 'Protection history' or delete the 'miner' folder and run start-mining.bat again."
  exit 1
}
Write-Host "Rigel $ver ready."
exit 0
