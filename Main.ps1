#=========================================================
# WESHT - Main Entry Point
# Windows Enterprise Security Hardening Toolkit
#=========================================================

#region Banner

Clear-Host

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   Windows Enterprise Security Hardening Toolkit (WESHT)"
Write-Host "   Version 1.0"
Write-Host "   Author : Luis Fonseca"
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

#endregion

#region Root Path

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

#endregion

#region Import Configuration

. "$Root\Config\Config.ps1"

#endregion

#region Import Core Modules

$CoreModules = @(

    "Logger.ps1",
    "Helpers.ps1",
    "Dashboard.ps1",
    "Parser.ps1",
    "RemediationEngine.ps1",
    "ExecutionManager.ps1",
    "HTMLReport.ps1",
    "Menu.ps1"

)

foreach ($Module in $CoreModules) {

    $ModulePath = Join-Path "$Root\Core" $Module

    if (Test-Path $ModulePath) {

        . $ModulePath

    }
    else {

        Write-Host "Unable to load $Module" -ForegroundColor Red
        exit

    }

}

#endregion

#region Import Remediation Modules

$RemediationModules = @(

    "PasswordPolicy.ps1",
    "AccountPolicy.ps1",
    "Firewall.ps1",
    "Defender.ps1"

)

foreach ($Module in $RemediationModules) {

    $ModulePath = Join-Path "$Root\Modules" $Module

    if (Test-Path $ModulePath) {

        . $ModulePath

    }
    else {

        Write-Host "Unable to load $Module" -ForegroundColor Yellow

    }

}

#endregion

#region Initialize Toolkit

Initialize-Logger

Write-Success "Logger initialized."

Initialize-Toolkit

#endregion

#region Load CIS Mappings

$MappingsFile = Join-Path "$Root\Config" "CISMappings.json"

Load-CISMappings -Path $MappingsFile | Out-Null

#endregion

#region Dashboard

Show-Dashboard

#endregion

#region Main Menu

Show-MainMenu

#endregion