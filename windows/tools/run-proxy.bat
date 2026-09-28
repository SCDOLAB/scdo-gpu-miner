@echo off
rem Started by start-mining.bat. Stratum (ethproxy + EthereumStratum/1.0.0) -> getwork proxy.
rem -autostart: starts mining on the node only once it has peers and has caught up with
rem https://scdoscan.io/rpc/0, and pauses if the node loses all peers (no private forks).
cd /d "%~dp0.."
title SCDO proxy - keep open
if "%LISTEN%"=="" set LISTEN=127.0.0.1:3333
"bin\scdo-stratum.exe" -rpc http://127.0.0.1:18545 -listen %LISTEN% -autostart -ref-rpc https://scdoscan.io/rpc/0 -log "logs\proxy.log"
echo.
echo The proxy stopped. Close this window, then run start-mining.bat again.
