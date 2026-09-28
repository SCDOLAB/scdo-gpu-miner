SCDO shard0 GPU miner for Linux (NVIDIA)            https://scdoscan.io/downloads/shard0/
Same design as the Windows package: bin/geth (core-geth v1.12.23, static) syncs SCDO shard0
(chainId 5680) from the bootnode with --miner.etherbase = your wallet; bin/scdo-stratum
(stratum -> getwork proxy on 127.0.0.1:3333) starts mining only after sync; Rigel 1.23.2
(NVIDIA, official GitHub release, SHA256-verified on download, 0.7% dev fee) mines ethash.

  tar xzf scdo-shard0-gpu-miner-linux-amd64.tar.gz && cd scdo-shard0-gpu-miner
  WALLET=0xYOUR_ADDRESS ./start-mining.sh        (or edit the WALLET= line once)

Needs: NVIDIA driver (RTX 50 series: 570+), curl, sha256sum. Logs in logs/ (proxy.log shows shares and "BLOCK FOUND"). Ctrl+C stops
miner, proxy and node. Other miners work too (plain Ethash, 30000-block epochs), e.g.
  lolMiner --algo ETHASH --pool 127.0.0.1:3333 --user 0xYOUR_ADDRESS --ethstratum ETHPROXY
