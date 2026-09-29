@echo off
rem Started by start-mining.bat (inherits WALLET). Runs the local core-geth node.
rem --gcmode archive: every block's state is written to disk at once, so a crash, power cut or
rem force-kill cannot make the node lose its state ("Head state missing") and fall back to block 0.
rem No --mine flag: the proxy starts getwork-only mining (miner_start 0) once the node is synced.
cd /d "%~dp0.."
title SCDO node - keep open
"bin\geth.exe" --datadir "data" --networkid 5680 --syncmode full --gcmode archive --port 30368 ^
  --bootnodes enode://1d2c370db7c419349e2313f20023f6b379f946990042b9b42df45cb56e4c3487df0d36c52cd81308fcdf312450f758a6213fcac21213e94a71af4a3c9392601f@82.223.19.88:30368 ^
  --http --http.addr 127.0.0.1 --http.port 18545 --http.api eth,net,web3,miner ^
  --authrpc.port 18551 --ipcdisable ^
  --miner.etherbase %WALLET% --miner.gaslimit 30000000 --miner.gasprice 1000000 --txpool.pricelimit 1000000 ^
  --ethash.dagdir "data\ethash-dag" --ethash.cachedir "data\ethash-cache" ^
  --log.rotate --log.file "logs\geth.log" --log.maxsize 20 --log.maxbackups 2
echo.
echo The node stopped. Close this window, then run start-mining.bat again.
