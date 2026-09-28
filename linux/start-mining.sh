#!/usr/bin/env bash
# SCDO shard0 GPU miner (NVIDIA, Linux) - edit ONLY the next line (or run: WALLET=0x... ./start-mining.sh)
WALLET="${WALLET:-0xYOUR_WALLET_ADDRESS}"
# Optional: POOL=host:port mines against another stratum proxy instead of a local node
# (rewards then go to THAT node's wallet). LISTEN=0.0.0.0:3333 lets LAN PCs use this proxy.
POOL="${POOL:-}"
LISTEN="${LISTEN:-127.0.0.1:3333}"
WORKER="${WORKER:-$(hostname -s)}"

set -u
cd "$(dirname "$(readlink -f "$0")")"
mkdir -p logs miner
RIGEL_VER=1.23.2
RIGEL_SHA=eae492ffb64aeb4ab4ba7e66631567984a31d5adb1ef547bda6601aee1793f0d
RIGEL_URL="https://github.com/rigelminer/rigel/releases/download/${RIGEL_VER}/rigel-${RIGEL_VER}-linux.tar.gz"
RIGEL="miner/rigel-${RIGEL_VER}-linux/rigel"
BOOT=enode://1d2c370db7c419349e2313f20023f6b379f946990042b9b42df45cb56e4c3487df0d36c52cd81308fcdf312450f758a6213fcac21213e94a71af4a3c9392601f@82.223.19.88:30368
RPC=http://127.0.0.1:18545

if ! [[ "$WALLET" =~ ^0x[0-9a-fA-F]{40}$ ]] || [[ "$WALLET" =~ ^0x0{40}$ ]]; then
  echo "Set your wallet address: edit WALLET= in $0 or run WALLET=0x... $0"; exit 1
fi
echo "Wallet: $WALLET"

if [ ! -x "$RIGEL" ]; then
  tgz="miner/rigel-${RIGEL_VER}-linux.tar.gz"
  if [ ! -f "$tgz" ] || ! echo "$RIGEL_SHA  $tgz" | sha256sum -c --status; then
    echo "Downloading Rigel $RIGEL_VER from $RIGEL_URL ..."
    curl -fL --retry 3 -o "$tgz" "$RIGEL_URL" || { echo "Download failed; fetch it manually into $tgz"; exit 1; }
  fi
  echo "$RIGEL_SHA  $tgz" | sha256sum -c || { echo "SHA256 mismatch - deleting $tgz"; rm -f "$tgz"; exit 1; }
  tar -xzf "$tgz" -C miner
fi

pids=()
cleanup() { for p in "${pids[@]}"; do kill "$p" 2>/dev/null; done; wait; }
trap cleanup EXIT
trap 'exit 130' INT TERM

if [ -z "$POOL" ]; then
  if [ ! -d data/geth/chaindata ]; then
    ./bin/geth --datadir data init scdo-shard0-genesis.json > logs/geth-init.log 2>&1 || { cat logs/geth-init.log; exit 1; }
  fi
  # No --mine: the proxy calls miner_start(0) (getwork only) once the node is synced.
  ./bin/geth --datadir data --networkid 5680 --syncmode full --port 30368 --bootnodes "$BOOT" \
    --http --http.addr 127.0.0.1 --http.port 18545 --http.api eth,net,web3,miner \
    --authrpc.port 18551 --ipcdisable \
    --miner.etherbase "$WALLET" --miner.gaslimit 30000000 --miner.gasprice 1000000 --txpool.pricelimit 1000000 \
    --ethash.dagdir data/ethash-dag --ethash.cachedir data/ethash-cache >> logs/geth.log 2>&1 &
  pids+=($!)
  ./bin/scdo-stratum -rpc "$RPC" -listen "$LISTEN" -autostart -ref-rpc https://scdoscan.io/rpc/0 >> logs/proxy.log 2>&1 &
  pids+=($!)
  echo "Node + proxy started (logs/geth.log, logs/proxy.log). Waiting for sync ..."
  while true; do
    m=$(curl -s -m 5 -H 'content-type: application/json' --data '{"jsonrpc":"2.0","id":1,"method":"eth_mining","params":[]}' $RPC | grep -o '"result":[a-z]*' | cut -d: -f2)
    [ "$m" = "true" ] && break
    bn=$(curl -s -m 5 -H 'content-type: application/json' --data '{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}' $RPC | grep -o '0x[0-9a-f]*' | head -1)
    echo "  $(date +%T) local block $((${bn:-0})) - $(tail -1 logs/proxy.log | cut -c21-)"
    sleep 5
  done
  STRATUM="127.0.0.1:${LISTEN##*:}"
else
  STRATUM="$POOL"
fi
echo "Starting Rigel against ethproxy+tcp://$STRATUM (Ctrl+C stops everything; Rigel is restarted if it exits)"
while true; do
  "./$RIGEL" -a ethash -o "ethproxy+tcp://$STRATUM" -u "$WALLET" -w "$WORKER" --log-file logs/rigel.log
  rc=$?
  echo "$(date '+%F %T') Rigel exited with code $rc, restarting in 10 s" | tee -a logs/rigel-restarts.log
  sleep 10
done
