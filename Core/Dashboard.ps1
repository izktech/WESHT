function Show-Dashboard {

Clear-Host

Write-Host ""

Write-Host "==============================================" -ForegroundColor Cyan

Write-Host " Windows Enterprise Security Hardening Toolkit"

Write-Host "==============================================" -ForegroundColor Cyan

Write-Host ""

Write-Host ("Computer Name : " + $env:COMPUTERNAME)

Write-Host ("User          : " + $env:USERNAME)

Write-Host ("Windows       : " + (Get-CimInstance Win32_OperatingSystem).Caption)

Write-Host ("Build         : " + (Get-CimInstance Win32_OperatingSystem).BuildNumber)

Write-Host ("PowerShell    : " + $PSVersionTable.PSVersion)

Write-Host ""

}