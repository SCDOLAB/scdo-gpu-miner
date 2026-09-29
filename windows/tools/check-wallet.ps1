param([string]$Wallet, [string]$Payout = "")
if ($Wallet -notmatch '^0x[0-9a-fA-F]{40}$' -or $Wallet -match '^0x0{40}$') {
  Write-Host ""
  Write-Host "Please open start-mining.bat with Notepad and set your wallet address on the line"
  Write-Host "    set WALLET=0x...   (42 characters: 0x + 40 hex digits, e.g. your MetaMask address)"
  Write-Host "Current value: '$Wallet'"
  exit 1
}
Write-Host "Wallet: $Wallet"
if ($Payout -eq "" -or $Payout -ieq "off") {
  Write-Host "Node service fee: not registered (PAYOUT=off)"
} elseif ($Payout -notmatch '^0x[0-9a-fA-F]{40}$' -or $Payout -match '^0x0{40}$') {
  Write-Host ""
  Write-Host "The line  set PAYOUT=...  in start-mining.bat must be empty (= same as WALLET),"
  Write-Host "a 0x address (0x + 40 hex digits) or off. Current value: '$Payout'"
  exit 1
} else {
  Write-Host "Node service fee payout address: $Payout  (https://scdoscan.io/nodes/)"
}
exit 0
