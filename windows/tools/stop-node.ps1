# SCDO shard0 GPU miner v1.0.2: stop the geth node of this folder GRACEFULLY.
# geth runs in its own console window ("SCDO node"). We attach to that console and send Ctrl+C,
# exactly like pressing Ctrl+C in the window: geth then writes its state to disk and exits.
# Fallback after -TimeoutSec: force-kill (safe too, because run-node.bat uses --gcmode archive).
# Output goes to logs\stop-node.log (after FreeConsole this script has no console to print to).
param([int]$TimeoutSec = 60)
$ErrorActionPreference = 'SilentlyContinue'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$log = Join-Path $root 'logs\stop-node.log'
function L($m) { Add-Content -Path $log -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' ' + $m) }
Set-Content -Path $log -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' stop-node.ps1 (SCDO miner v1.0.2)')
Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public static class ScdoCon {
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool AttachConsole(uint pid);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool FreeConsole();
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool SetConsoleCtrlHandler(IntPtr h, bool add);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool GenerateConsoleCtrlEvent(uint ev, uint group);
}
'@
$procs = @(Get-Process -Name geth | Where-Object { $_.Path -like ($root + '\*') })
if ($procs.Count -eq 0) { L 'node (geth) of this folder is not running'; exit 0 }
foreach ($p in $procs) {
  $sent = $false
  [void][ScdoCon]::FreeConsole()
  if ([ScdoCon]::AttachConsole([uint32]$p.Id)) {
    [void][ScdoCon]::SetConsoleCtrlHandler([IntPtr]::Zero, $true)   # ignore the Ctrl+C ourselves
    $sent = [ScdoCon]::GenerateConsoleCtrlEvent(0, 0)                 # CTRL_C_EVENT to that console
    [void][ScdoCon]::FreeConsole()
  }
  if ($sent) { L ("sent Ctrl+C to geth (pid " + $p.Id + "), waiting up to $TimeoutSec s") } else { L ("could not attach to the console of geth (pid " + $p.Id + ")") }
  if ($sent -and $p.WaitForExit($TimeoutSec * 1000)) { L ("geth (pid " + $p.Id + ") exited cleanly") }
  else { Stop-Process -Id $p.Id -Force; L ("geth (pid " + $p.Id + ") force-killed (fallback)") }
}
