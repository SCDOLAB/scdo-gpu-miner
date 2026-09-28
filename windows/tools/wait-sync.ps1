# Waits until the local node is synced and the proxy has started getwork mining (eth_mining = true).
$ErrorActionPreference = 'SilentlyContinue'
$rpc = 'http://127.0.0.1:18545'
function Call($m) {
  $body = '{"jsonrpc":"2.0","id":1,"method":"' + $m + '","params":[]}'
  try { (Invoke-RestMethod -Uri $rpc -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 5).result } catch { $null }
}
function Net-Head {
  $body = '{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}'
  try { [Convert]::ToInt64((Invoke-RestMethod -Uri 'https://scdoscan.io/rpc/0' -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 8).result, 16) } catch { -1 }
}
Write-Host "Waiting for the node to sync with the SCDO network (first start: 1-5 minutes) ..."
$i = 0
while ($true) {
  $mining = Call 'eth_mining'
  if ($mining -eq $true) { Write-Host "Node synced, mining work is ready."; exit 0 }
  $bn = Call 'eth_blockNumber'; $pc = Call 'net_peerCount'
  if ($null -eq $bn) { $msg = 'node starting ...' } else {
    $head = [Convert]::ToInt64($bn, 16); $peers = [Convert]::ToInt64($pc, 16)
    if ($i % 3 -eq 0) { $script:net = Net-Head }
    $msg = "local block $head / network $($script:net), peers $peers"
  }
  Write-Host ("  [{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg)
  $i++
  Start-Sleep -Seconds 5
}
