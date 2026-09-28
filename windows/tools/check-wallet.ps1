param([string]$Wallet)
if ($Wallet -notmatch '^0x[0-9a-fA-F]{40}$' -or $Wallet -match '^0x0{40}$') {
  Write-Host ""
  Write-Host "Please open start-mining.bat with Notepad and set your wallet address on the line"
  Write-Host "    set WALLET=0x...   (42 characters: 0x + 40 hex digits, e.g. your MetaMask address)"
  Write-Host "Current value: '$Wallet'"
  exit 1
}
Write-Host "Wallet: $Wallet"
exit 0
