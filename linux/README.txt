SCDO shard0 GPU miner for Linux (NVIDIA) v1.0.3     https://scdoscan.io/downloads/shard0/
Same design as the Windows package: bin/geth (core-geth v1.12.23, static) syncs SCDO shard0
(chainId 5680) from the bootnode with --miner.etherbase = your wallet; bin/scdo-stratum
(stratum -> getwork proxy on 127.0.0.1:3333) starts mining only after sync; Rigel 1.23.2
(NVIDIA, official GitHub release, SHA256-verified on download, 0.7% dev fee) mines ethash.

  tar xzf scdo-shard0-gpu-miner-linux-amd64.tar.gz && cd scdo-shard0-gpu-miner
  WALLET=0xYOUR_ADDRESS ./start-mining.sh        (or edit the WALLET= line once)

Node service fee (节点服务费): the node registers itself with --identity scdo-node:<PAYOUT> so the SCDO
bootnode can measure its online time; the fee is paid by online time, see https://scdoscan.io/nodes/ .
PAYOUT defaults to your WALLET. Other address: PAYOUT=0xOTHER ./start-mining.sh (or edit the PAYOUT= line);
PAYOUT=off does not register. Only the public address is sent (visible to peers), never a private key.

Needs: NVIDIA driver (RTX 50 series: 570+), curl, sha256sum. Logs in logs/ (proxy.log shows shares and "BLOCK FOUND").
To stop: press Ctrl+C once in the terminal (or kill <script pid>) and wait: the script stops the
miner and proxy, then stops the node gracefully (SIGINT, the node saves its state; kill -9 only if it
has not exited after 60 s). Do not kill -9 geth yourself and do not just close the terminal. Other miners work too (plain Ethash, 30000-block epochs), e.g.
  lolMiner --algo ETHASH --pool 127.0.0.1:3333 --user 0xYOUR_ADDRESS --ethstratum ETHPROXY

Changes in v1.0.3 (29 September 2026): node service fee payout address (PAYOUT, default = WALLET) is
passed to the node as --identity scdo-node:<address>. Upgrade: stop the old script (Ctrl+C), copy the new
files over the old folder (keep data/ and your WALLET line), start again.

Changes in v1.0.2 (29 September 2026): the node runs with --gcmode archive (a crashed or killed node
no longer falls back to block 0; ~25 MB more disk per day) and the script stops the node gracefully
with a 60 s fallback. Upgrade: stop the old script, copy the new files over the old folder (keep data/).
