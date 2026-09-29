SCDO shard0 GPU miner for Windows (NVIDIA) v1.0.3   https://scdoscan.io/downloads/shard0/
=====================================================================================

What it does (all on this PC):
  bin\geth.exe          core-geth v1.12.23 node for SCDO shard0 (chainId/networkId 5680), syncs from
                        the public bootnode 82.223.19.88:30368. Its --miner.etherbase = YOUR wallet,
                        so block rewards (2 SCDO + fees per block) go to your address.
  bin\scdo-stratum.exe  small stratum -> getwork proxy on 127.0.0.1:3333 (ethproxy and
                        EthereumStratum/1.0.0). It starts mining only after the node has synced
                        and pauses if the node loses all peers.
  Rigel 1.23.2          NVIDIA miner (RTX 20/30/40/50 series incl. RTX 4060 and RTX 5060 Ti).
                        Downloaded on first start from the official GitHub release
                        https://github.com/rigelminer/rigel/releases/tag/1.23.2 and checked
                        against SHA256 0a35d37504e2595f2cd9bb25ae69eae39625be6f0ebbdbaf7427d4c381a7fd79.
                        Rigel is closed source and takes a 0.7% dev fee on ethash.

Steps
  1. Unzip to a short folder without spaces/Chinese characters, e.g. C:\scdo-miner
  2. Windows Security > Virus & threat protection > Manage settings > Exclusions >
     Add an exclusion > Folder > C:\scdo-miner   (Defender flags every GPU miner as a
     "potentially unwanted app"; without the exclusion rigel.exe gets deleted).
  3. Right-click start-mining.bat > Edit, set your address on the line
         set WALLET=0x...
     (a MetaMask/EVM address you control; 0x + 40 hex digits). Save.
     Node service fee (optional line  set PAYOUT=  just below): your node registers itself with
     --identity scdo-node:<address> so the SCDO bootnode can measure its online time; the node
     service fee is paid by online time (rules: https://scdoscan.io/nodes/). Leave PAYOUT empty to
     use your WALLET address, set another 0x address, or set PAYOUT=off to not register.
  4. Double-click start-mining.bat. First start: downloads Rigel (~56 MB), creates the
     chain database, starts two small windows "SCDO node" and "SCDO proxy" and waits
     until the node is synced (1-5 minutes). If Windows Firewall asks about geth.exe,
     click Allow (private networks). If a blue "Windows protected your PC" (SmartScreen)
     window appears, click "More info" and then "Run anyway" (the files are not code-signed).
  5. Rigel shows the hashrate and "accepted" shares. Blocks you find show up at
     https://scdoscan.io/#/address?address=<your address>.
  To stop: ALWAYS double-click stop-mining.bat. It stops Rigel/lolMiner and the proxy of THIS
  folder, then stops the node gracefully (sends it Ctrl+C, the node saves its state; it is
  force-killed only if it has not exited after 60 s). Result: logs\stop-node.log.
  Do NOT close the "SCDO node" window with X and do not end geth.exe in Task Manager: a
  force-killed node can lose its latest state. (v1.0.2 runs the node with --gcmode archive,
  which keeps every block's state on disk, so a force-kill no longer sends it back to block 0
  (tested) - but do not rely on the node "recovering by itself"; please use stop-mining.bat.)
  Logs: logs\rigel.log (hashrate, accepted shares), logs\proxy.log (shares, "BLOCK FOUND"),
  logs\geth.log (node). shard0 difficulty is low, so one GPU finds a block almost every
  second at first; the proxy submits at most one block per second (block timestamps must not
  run ahead of the clock, otherwise other nodes reject them) and counts the rest as shares.

Second PC (e.g. RTX 5060 Ti): copy the same folder and do the same steps (it runs its
own node; the chain is small). Alternative: on PC 1 set LISTEN=0.0.0.0:3333, on PC 2 set
POOL=<PC1-LAN-IP>:3333 - then PC 2 only runs Rigel and rewards go to PC 1's wallet.

Other miners: the proxy accepts any ethash stratum miner, e.g.
  lolMiner.exe --algo ETHASH --pool 127.0.0.1:3333 --user 0xYOURWALLET --ethstratum ETHPROXY
Algorithm is plain Ethash (30000-block epochs, NOT etchash); epoch 0 DAG is about 1 GB.

Files: data\ = chain database (+ ~2 GB ethash DAG files after the first found block),
logs\rigel.log = miner log. Nothing here holds private keys: only your public address
is used. Mining this test chain has no guaranteed value.

Changes in v1.0.3 (29 September 2026)
  - Node service fee payout address: start-mining.bat has a new line  set PAYOUT=  (empty = WALLET);
    tools\run-node.bat starts the node with --identity scdo-node:<address> (see https://scdoscan.io/nodes/).
  Upgrading from v1.0.2: stop with stop-mining.bat, copy the new files over the old folder
  (keep data\ and put your WALLET line into the new start-mining.bat), start again.

Changes in v1.0.2 (29 September 2026)
  - Node runs with --gcmode archive (tools\run-node.bat): a force-killed/crashed node no longer
    falls back to block 0 ("Head state missing"). Needs about 25 MB more disk per day.
  - stop-mining.bat stops the node gracefully (Ctrl+C, tools\stop-node.ps1) with a 60 s
    force-kill fallback, instead of killing it at once.
  Upgrading from v1.0.1: stop with the OLD stop-mining.bat, copy the new files over the old folder
  (keep data\ and your WALLET line), start again. Checksums: SHA256SUMS in this folder.
