# scdo-gpu-miner

Scripts for the **SCDO shard 0 GPU mining package** (Windows and Linux, NVIDIA).
Download the ready-made package from https://scdoscan.io/downloads/shard0/ or from the
[Releases](https://github.com/SCDOLAB/scdo-gpu-miner/releases) of this repository.

[中文说明见下方](#中文说明)

## How it works

Everything runs on your own PC. There is no pool.

| Part | What it does |
|---|---|
| `geth` | core-geth v1.12.23 node for SCDO shard 0 (chain ID / network ID **5680**). It syncs from the public bootnode `82.223.19.88:30368`. `--miner.etherbase` is **your** wallet, so block rewards (2 SCDO + fees per block) go to your address. |
| `scdo-stratum` | Small stratum-to-getwork proxy on `127.0.0.1:3333` (ethproxy and EthereumStratum/1.0.0). It starts mining only after the node has synced and pauses if the node loses all peers. At most one block per second is submitted, so block timestamps never run ahead of the clock. |
| Rigel 1.23.2 | NVIDIA miner, downloaded on first start from its [official GitHub release](https://github.com/rigelminer/rigel/releases/tag/1.23.2) and checked against a fixed SHA256. Rigel is closed source and takes a 0.7% dev fee. Any other Ethash stratum miner (e.g. lolMiner) also works. |

Algorithm: plain **Ethash** (30,000-block epochs, not Etchash). The epoch 0 DAG is about 1 GB, so any GPU with 2 GB or more works.

## Quick start

**Windows:** unzip to a short path such as `C:\scdo-miner`, add that folder as a Windows Defender
exclusion (Defender removes every GPU miner), set `set WALLET=0x...` in `start-mining.bat`, then
double-click it. If SmartScreen shows "Windows protected your PC", click **More info** then **Run anyway**
(the files are not code-signed). **Always stop with `stop-mining.bat`** — it stops the miner and proxy and then
shuts the node down gracefully (Ctrl+C, force-kill only after 60 s). Do not close the "SCDO node" window with X.
Details: [windows/README.txt](windows/README.txt).

**Linux:**

```bash
tar xzf scdo-shard0-gpu-miner-v1.0.2-linux-amd64.tar.gz && cd scdo-shard0-gpu-miner
WALLET=0xYOUR_ADDRESS ./start-mining.sh
```

Needs an NVIDIA driver (RTX 50 series: 570+), `curl` and `sha256sum`. Stop with one Ctrl+C and wait: the
script stops the node gracefully (SIGINT, `kill -9` only after 60 s). Details: [linux/README.txt](linux/README.txt).

Your found blocks show up on https://scdoscan.io under your address. The package never asks for
or stores a private key; only your public address is used.

## Repository layout

| Path | Contents |
|---|---|
| `windows/` | `start-mining.bat`, `stop-mining.bat`, `tools/` (node, proxy, miner download, sync wait, graceful node stop), README EN/CN |
| `linux/` | `start-mining.sh`, README |
| `scdo-shard0-genesis.json` | Shard 0 genesis (chain ID 5680, genesis hash `0xbbb083…70cb12`) |
| `SHA256SUMS` | Hashes of the release archives |
| `build/core-geth-scdo-darwin-nocgo.patch` | Extra patch used for the CGO-free Windows/macOS `geth` build |

The binaries (`geth`, `scdo-stratum`) are only in the release archives, not in git. Their source is
[SCDOLAB/scdo-shard0](https://github.com/SCDOLAB/scdo-shard0) (branch `scdo`: core-geth v1.12.23 +
`cmd/scdostratum`), under the GNU GPL v3 / LGPL v3 like upstream core-geth.

## Release v1.0.2 (2026-09-29)

| File | SHA256 |
|---|---|
| `scdo-shard0-gpu-miner-v1.0.2-windows-amd64.zip` | `3464e31942085a2d0c74f95334db948ca6164435b0261e2d0f684f478f22224a` |
| `scdo-shard0-gpu-miner-v1.0.2-linux-amd64.tar.gz` | `5b2e882532b02dd69c177b8cb4dbe26dcf83568969ebbdb7679d09989aa57062` |

Also at https://scdoscan.io/downloads/shard0/ (see its `SHA256SUMS`). Changes in v1.0.2:

- The node runs with `--gcmode archive`. Before, a force-killed or crashed node on Windows could lose its
  latest state and fall back to an old block ("Head state missing"); now every block's state is on disk.
  Costs about 25 MB of extra disk per day.
- `stop-mining.bat` stops the node gracefully (`tools/stop-node.ps1` sends Ctrl+C to the node's console,
  force-kill only after 60 s, result in `logs/stop-node.log`). `start-mining.sh` does the same on Linux (SIGINT).
- README EN/CN: SmartScreen note, "stop with stop-mining.bat, don't close the node window".

Upgrade from v1.0.1: stop with the old `stop-mining.bat`, copy the new files over the old folder (keep `data\`
and your `WALLET` line), start again. The binaries are unchanged from v1.0.1.

## Release v1.0.1 (2026-09-29, previous)

| File | SHA256 |
|---|---|
| `scdo-shard0-gpu-miner-windows-amd64.zip` | `ab7689864b174112a4d1ae67f523a116cb924d0cafee86abfdc4103d403da272` |
| `scdo-shard0-gpu-miner-linux-amd64.tar.gz` | `fb8c6555f1c46a995ccdb39dbd7f80216884d154a933cc5b41429768b560b32a` |

Changes in v1.0.1: `scdo-stratum` 1.0.1
(at most one block per wall-clock second, pauses if the local head runs more than 30 blocks ahead of the network, higher submit limit, log
files), a restart loop for the miner, and `stop-mining.bat`.

Mining SCDO shard 0 has no guaranteed value. The official site is **https://scdoscan.io** only.

---

## 中文说明

SCDO shard0（chainId 5680）GPU 挖矿包的脚本。成品包请从 https://scdoscan.io/downloads/shard0/ 或本仓库的 Releases 下载。

**原理：** 全部在你自己的电脑上运行，没有矿池。

- `geth`：core-geth v1.12.23 节点，从公开引导节点 `82.223.19.88:30368` 同步 shard0；出块地址是**你自己的钱包**，所以奖励（每块 2 SCDO + 手续费）直接进你的地址。
- `scdo-stratum`：本机 `127.0.0.1:3333` 上的 stratum → getwork 小代理。节点同步完才开始挖，节点没有连接时自动暂停；每秒最多提交一个块。
- Rigel 1.23.2：NVIDIA 挖矿软件，首次启动时从官方 GitHub 下载并校验 SHA256（闭源，0.7% 开发者费用）。lolMiner 等其它 Ethash 软件也可以用。

**Windows：** 解压到 `C:\scdo-miner` 这类简单路径 → 在 Windows 安全中心把这个文件夹加入排除项 → 编辑 `start-mining.bat`，写上 `set WALLET=0x你的地址` → 双击运行。出现 SmartScreen“Windows 已保护你的电脑”时，点“更多信息”再点“仍要运行”（文件没有代码签名）。**停止时一定要双击 `stop-mining.bat`**（先停矿机和代理，再正常关闭节点，60 秒后才强制结束），不要用 X 关闭“SCDO node”窗口。v1.0.2 起节点使用 `--gcmode archive`，强制结束后不再退回到旧区块（但请不要依赖节点“自己恢复”）。详见 [windows/README-CN.txt](windows/README-CN.txt)。

**Linux：** `WALLET=0x你的地址 ./start-mining.sh`，需要 NVIDIA 驱动、curl、sha256sum。停止：按一次 Ctrl+C 并等待节点正常退出。

挖到的块可在 https://scdoscan.io 用你的地址查询。挖矿包不会要求也不会保存私钥。

二进制文件只在 Releases 压缩包里；源码在 [SCDOLAB/scdo-shard0](https://github.com/SCDOLAB/scdo-shard0)（`scdo` 分支），许可证与上游 core-geth 相同（GPL v3 / LGPL v3）。

挖 shard0 不保证有任何价值。官方网站只有 **https://scdoscan.io**。
