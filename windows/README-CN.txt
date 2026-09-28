SCDO shard0 GPU 挖矿包（Windows / NVIDIA）
=========================================
1. 解压到简单路径，例如 C:\scdo-miner（不要有空格或中文）。
2. Windows 安全中心 > 病毒和威胁防护 > 管理设置 > 排除项 > 添加排除项 > 文件夹 > C:\scdo-miner
   （Defender 会把所有挖矿软件当作“可能不需要的应用”删除）。
3. 右键 start-mining.bat > 编辑，把这一行改成你自己的地址并保存：
       set WALLET=0x你的钱包地址
4. 双击 start-mining.bat。首次会下载 Rigel 挖矿程序（官方 GitHub，自动校验 SHA256），
   打开“SCDO node”和“SCDO proxy”两个小窗口，等待节点同步（约 1-5 分钟）后自动开始挖矿。
   防火墙询问 geth.exe 时点“允许”。
5. 出块奖励（每块 2 SCDO）直接进入你的地址，可在 https://scdoscan.io 查询。
停止：双击 stop-mining.bat（只停止本文件夹里的 Rigel/lolMiner、proxy 和节点），或者先关 Rigel 窗口，再关 SCDO proxy 和 SCDO node 窗口。
日志：logs\rigel.log（算力、接受的份额）、logs\proxy.log（份额、"BLOCK FOUND" 出块）、logs\geth.log（节点）。
第二台电脑（RTX 5060 Ti）：复制同一个文件夹，做同样的步骤即可。
