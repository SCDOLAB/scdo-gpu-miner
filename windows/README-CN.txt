SCDO shard0 GPU 挖矿包（Windows / NVIDIA）v1.0.3
================================================
1. 解压到简单路径，例如 C:\scdo-miner（不要有空格或中文）。
2. Windows 安全中心 > 病毒和威胁防护 > 管理设置 > 排除项 > 添加排除项 > 文件夹 > C:\scdo-miner
   （Defender 会把所有挖矿软件当作“可能不需要的应用”删除）。
3. 右键 start-mining.bat > 编辑，把这一行改成你自己的地址并保存：
       set WALLET=0x你的钱包地址
   节点服务费（可选，下面的 set PAYOUT= 一行）：节点启动时会带上 --identity scdo-node:<地址>，
   SCDO 引导节点据此统计在线时长，节点服务费按在线时长支付（规则见 https://scdoscan.io/nodes/）。
   PAYOUT 留空 = 使用 WALLET 地址；也可填写另一个 0x 地址；填 off 表示不登记。只填公开地址，切勿填私钥或助记词。
4. 双击 start-mining.bat。首次会下载 Rigel 挖矿程序（官方 GitHub，自动校验 SHA256），
   打开“SCDO node”和“SCDO proxy”两个小窗口，等待节点同步（约 1-5 分钟）后自动开始挖矿。
   防火墙询问 geth.exe 时点“允许”。如果出现蓝色的“Windows 已保护你的电脑”（SmartScreen）窗口，
   请点“更多信息”（More info），再点“仍要运行”（Run anyway）——这些文件没有代码签名。
5. 出块奖励（每块 2 SCDO）直接进入你的地址，可在 https://scdoscan.io 查询。
停止：请务必双击 stop-mining.bat。它先停止本文件夹里的 Rigel/lolMiner 和 proxy，再“正常关闭”节点
（向节点发送 Ctrl+C，节点会先把数据写入硬盘再退出；60 秒内没退出才强制结束）。结果见 logs\stop-node.log。
不要用 X 直接关闭“SCDO node”窗口，也不要在任务管理器里结束 geth.exe：强制结束的节点可能丢失最新状态。
（v1.0.2 的节点使用 --gcmode archive，每个区块的状态都会写入硬盘，强制结束后不再退回到 0 号区块（已测试）；
但节点并不是每次强制关闭后都能“自己恢复”，所以请用 stop-mining.bat 停止。）
日志：logs\rigel.log（算力、接受的份额）、logs\proxy.log（份额、"BLOCK FOUND" 出块）、logs\geth.log（节点）。
第二台电脑（RTX 5060 Ti）：复制同一个文件夹，做同样的步骤即可。

v1.0.3 更新（2026 年 9 月 29 日）
- 新增节点服务费收款地址：start-mining.bat 中新增 set PAYOUT= 一行（留空 = 使用 WALLET），
  tools\run-node.bat 启动节点时带上 --identity scdo-node:<地址>（见 https://scdoscan.io/nodes/）。
从 v1.0.2 升级：先用 stop-mining.bat 停止，把新文件复制覆盖到原文件夹（保留 data\ 文件夹，并把你的 WALLET 那一行填到新的 start-mining.bat 中），再启动。

v1.0.2 更新（2026 年 9 月 29 日）
- 节点加上 --gcmode archive（tools\run-node.bat），强制结束或崩溃后不会再退回到 0 号区块（"Head state missing"）。每天多占约 25 MB 硬盘。
- stop-mining.bat 改为正常关闭节点（Ctrl+C，tools\stop-node.ps1），60 秒后才强制结束。
从 v1.0.1 升级：先用旧的 stop-mining.bat 停止，把新文件复制覆盖到原文件夹（保留 data\ 文件夹和你的 WALLET 那一行），再启动。校验值见本文件夹的 SHA256SUMS。
