@echo off
rem SCDO shard0 GPU miner v1.0.3 - stops the miner (Rigel / lolMiner), the stratum proxy and the node
rem started from THIS folder. The node (geth) is stopped GRACEFULLY (Ctrl+C, it saves its state);
rem only if it does not exit within 60 s it is force-killed.
cd /d "%~dp0"
if not exist logs mkdir logs
rem The flag tells the Rigel restart loop in start-mining.bat not to restart the miner.
echo stop> "logs\stop.flag"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$root=(Resolve-Path '.').Path; foreach ($n in 'rigel','lolMiner','scdo-stratum') { Get-Process -Name $n -ErrorAction SilentlyContinue | Where-Object { $_.Path -like ($root + '\*') } | ForEach-Object { Write-Host ('stopping ' + $_.Name + ' (pid ' + $_.Id + ')'); Stop-Process -Id $_.Id -Force } }"
echo Stopping the SCDO node gracefully (can take up to a minute) ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\stop-node.ps1"
if exist "logs\stop-node.log" type "logs\stop-node.log"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$root=(Resolve-Path '.').Path; Get-CimInstance Win32_Process -Filter \"Name='cmd.exe'\" | Where-Object { $_.CommandLine -like ('*' + $root + '\tools\run-*') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
echo Done.
ping -n 4 127.0.0.1 >nul
