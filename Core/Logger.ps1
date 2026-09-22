<#
.SYNOPSIS
    Writes messages to the console and to the Toolkit log file.

.DESCRIPTION
    Centralized logging function used across all modules of the
    Windows Enterprise Security Hardening Toolkit (WESHT).

.AUTHOR
    Luis Fonseca

.VERSION
    1.1
#>

function Initialize-Logger {

    [CmdletBinding()]
    param()

    #----------------------------------------------------
    # Ensure Logs folder exists before the first write
    #----------------------------------------------------

    $LogFolder = Join-Path $PSScriptRoot "..\Logs"

    if (!(Test-Path $LogFolder)) {

        New-Item `
            -ItemType Directory `
            -Path $LogFolder `
            -Force | Out-Null

    }

    #----------------------------------------------------
    # Mark the start of a new session in the daily log
    #----------------------------------------------------

    $LogFile = Join-Path $LogFolder ("WESHT_{0}.log" -f (Get-Date -Format "yyyyMMdd"))

    $SessionHeader = "===== New WESHT session started: {0} =====" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

    Add-Content -Path $LogFile -Value $SessionHeader

}

function Write-Log {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet("INFO","SUCCESS","WARNING","ERROR","DEBUG","VERBOSE")]
        [string]$Level = "INFO"

    )

    #----------------------------------------------------
    # Ensure Logs folder exists
    #----------------------------------------------------

    $LogFolder = Join-Path $PSScriptRoot "..\Logs"

    if (!(Test-Path $LogFolder)) {

        New-Item `
            -ItemType Directory `
            -Path $LogFolder `
            -Force | Out-Null

    }

    #----------------------------------------------------
    # Log File
    # Creates one log per day
    # Example:
    # WESHT_20260720.log
    #----------------------------------------------------

    $LogFile = Join-Path $LogFolder ("WESHT_{0}.log" -f (Get-Date -Format "yyyyMMdd"))

    #----------------------------------------------------
    # Log Entry
    #----------------------------------------------------

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $Entry = "{0} [{1}] {2}" -f $Timestamp, $Level, $Message

    Add-Content `
        -Path $LogFile `
        -Value $Entry

    #----------------------------------------------------
    # Console Output
    #----------------------------------------------------

    switch ($Level) {

        "INFO" {

            Write-Host $Entry -ForegroundColor White

        }

        "SUCCESS" {

            Write-Host $Entry -ForegroundColor Green

        }

        "WARNING" {

            Write-Host $Entry -ForegroundColor Yellow

        }

        "ERROR" {

            Write-Host $Entry -ForegroundColor Red

        }

        "DEBUG" {

            Write-Host $Entry -ForegroundColor Cyan

        }

        "VERBOSE" {

            Write-Host $Entry -ForegroundColor DarkGray

        }

    }

}

#=========================================================
# Convenience Wrappers
#
# The rest of the toolkit (Main.ps1, Menu.ps1, etc.) calls
# these short helper names instead of repeating
# "Write-Log ... -Level ..." everywhere. They all funnel
# into Write-Log so every message still gets written to
# the console AND to the daily log file.
#=========================================================

function Write-Success {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Log -Message $Message -Level "SUCCESS"

}

function Write-Info {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Log -Message $Message -Level "INFO"

}

function Write-WarningLog {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Log -Message $Message -Level "WARNING"

}

function Write-ErrorLog {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Log -Message $Message -Level "ERROR"

}
