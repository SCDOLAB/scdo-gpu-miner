@echo off
rem Stops the miner (Rigel / lolMiner), the stratum proxy and the node started from THIS folder.
cd /d "%~dp0"
if not exist logs mkdir logs
rem The flag tells the Rigel restart loop in start-mining.bat not to restart the miner.
echo stop> "logs\stop.flag"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$root=(Resolve-Path '.').Path; foreach ($n in 'rigel','lolMiner','scdo-stratum','geth') { Get-Process -Name $n -ErrorAction SilentlyContinue | Where-Object { $_.Path -like ($root + '\*') } | ForEach-Object { Write-Host ('stopping ' + $_.Name + ' (pid ' + $_.Id + ')'); Stop-Process -Id $_.Id -Force } }; Start-Sleep 1; Get-CimInstance Win32_Process -Filter \"Name='cmd.exe'\" | Where-Object { $_.CommandLine -like ('*' + $root + '\tools\run-*') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
echo Done.
ping -n 4 127.0.0.1 >nul
