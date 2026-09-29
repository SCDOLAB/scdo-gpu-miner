@echo off
setlocal EnableExtensions
rem ===================================================================
rem  SCDO shard0 GPU miner (NVIDIA) v1.0.3  -  edit ONLY the next line:
set WALLET=0xYOUR_WALLET_ADDRESS
rem ===================================================================
rem  Node service fee payout address (see https://scdoscan.io/nodes/):
rem   empty = same as WALLET (normal). 0x... = pay the node service fee to
rem   another address. off = do not register this node. The node is started
rem   with --identity scdo-node:ADDRESS so the SCDO bootnode can measure its
rem   online time. Only a PUBLIC address - never a private key or phrase.
set PAYOUT=
rem ===================================================================
rem  Optional, normally leave as is:
rem   POOL   empty = run your own node here, block rewards go to WALLET.
rem          host:port = only run the miner against another stratum proxy,
rem          e.g. 192.168.1.10:3333 (another PC running this package with
rem          LISTEN=0.0.0.0:3333) - rewards then go to THAT node's wallet.
set POOL=
rem   LISTEN 127.0.0.1:3333 = only this PC; 0.0.0.0:3333 = allow LAN PCs.
set LISTEN=127.0.0.1:3333
set WORKER=%COMPUTERNAME%
rem ===================================================================

cd /d "%~dp0"
title SCDO shard0 GPU miner
if not exist logs mkdir logs
if exist "logs\stop.flag" del "logs\stop.flag"

if "%PAYOUT%"=="" set "PAYOUT=%WALLET%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\check-wallet.ps1" -Wallet "%WALLET%" -Payout "%PAYOUT%"
if errorlevel 1 goto fail
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\get-miner.ps1"
if errorlevel 1 goto fail

if not "%POOL%"=="" (
  set "STRATUM=%POOL%"
  goto miner
)

if not exist "data\geth\chaindata" (
  echo Initialising the SCDO shard0 chain database ...
  "bin\geth.exe" --datadir "data" init "scdo-shard0-genesis.json" > "logs\geth-init.log" 2>&1
  if errorlevel 1 (
    type "logs\geth-init.log"
    goto fail
  )
)

echo Starting the SCDO node (window "SCDO node") and the stratum proxy (window "SCDO proxy") ...
start "SCDO node - keep open" /min cmd /k call "%~dp0tools\run-node.bat"
start "SCDO proxy - keep open" /min cmd /k call "%~dp0tools\run-proxy.bat"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\wait-sync.ps1"
if errorlevel 1 goto fail
set "STRATUM=127.0.0.1:3333"

:miner
echo.
echo Starting Rigel (NVIDIA miner, 0.7%% dev fee) against ethproxy+tcp://%STRATUM% ...
echo Block rewards: 2 SCDO per block to the wallet of the node (%WALLET% when POOL is empty).
echo To stop everything: run stop-mining.bat. Do NOT close the "SCDO node" window with X.
echo Rigel is restarted automatically if it exits or crashes.
echo.
:rigelloop
"%~dp0miner\rigel-1.23.2-win\rigel.exe" -a ethash -o ethproxy+tcp://%STRATUM% -u %WALLET% -w %WORKER% --log-file "%~dp0logs\rigel.log"
set RC=%errorlevel%
if exist "logs\stop.flag" goto stopped
echo %date% %time% Rigel exited with code %RC%, restarting in 10 s>> "logs\rigel-restarts.log"
echo.
echo Rigel exited (code %RC%) - restarting in 10 seconds. Run stop-mining.bat to stop.
ping -n 11 127.0.0.1 >nul
if exist "logs\stop.flag" goto stopped
if not exist "%~dp0miner\rigel-1.23.2-win\rigel.exe" (
  echo rigel.exe is missing - Windows Defender probably quarantined it. See README.txt step 2.
  goto fail
)
goto rigelloop

:stopped
echo Stopped by stop-mining.bat.
exit /b 0

:fail
echo.
echo *** Stopped - see the message above. ***
pause
exit /b 1
