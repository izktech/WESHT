<#
.SYNOPSIS
    Password Policy Module

.DESCRIPTION
    Implements CIS Password Policy remediation
    for the Windows Enterprise Security Hardening Toolkit.

.AUTHOR
    Luis Fonseca

.VERSION
    1.1
#>

#=========================================================
# Global Variables
#=========================================================

$Global:PasswordBackup = @{}

#=========================================================
# Backup Current Password Policy
#=========================================================

function Backup-PasswordPolicy {

    [CmdletBinding()]
    param()

    Write-Log "Backing up current password policy..." "INFO"

    try {

        $TempFile = Join-Path $env:TEMP "secpol_backup.inf"

        secedit /export /cfg $TempFile | Out-Null

        $Global:PasswordBackup = Get-Content $TempFile

        Remove-Item $TempFile -Force -ErrorAction SilentlyContinue

        Write-Log "Password policy backup completed." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Get Current Password Policy
#=========================================================

function Get-PasswordPolicy {

    [CmdletBinding()]
    param()

    Write-Log "Reading password policy..." "INFO"

    try {

        return net accounts

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $null

    }

}

#=========================================================
# Set Minimum Password Length
#=========================================================

function Set-MinimumPasswordLength {

    [CmdletBinding()]
    param(

        [Parameter()]
        [ValidateRange(8,128)]
        [int]$Length = 14

    )

    Write-Log "Configuring minimum password length to $Length..." "INFO"

    try {

        net accounts /minpwlen:$Length | Out-Null

        Write-Log "Minimum password length configured." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Test Minimum Password Length
#=========================================================

function Test-MinimumPasswordLength {

    [CmdletBinding()]
    param(

        [Parameter()]
        [int]$Expected = 14

    )

    try {

        $Policy = Get-PasswordPolicy

        if (-not $Policy) {

            return $false

        }

        foreach ($Line in $Policy) {

            if ($Line -match "Minimum password length") {

                if ($Line -match "\b$Expected\b") {

                    Write-Log "Password length validation passed." "SUCCESS"

                    return $true

                }

            }

        }

        Write-Log "Password length validation failed." "ERROR"

        return $false

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Set Password History Size
#=========================================================

function Set-PasswordHistorySize {

    [CmdletBinding()]
    param(

        [Parameter()]
        [ValidateRange(0,24)]
        [int]$Size = 24

    )

    Write-Log "Configuring password history size to $Size..." "INFO"

    try {

        net accounts /uniquepw:$Size | Out-Null

        Write-Log "Password history size configured." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Test Password History Size
#=========================================================

function Test-PasswordHistorySize {

    [CmdletBinding()]
    param(

        [Parameter()]
        [int]$Expected = 24

    )

    try {

        $Policy = Get-PasswordPolicy

        if (-not $Policy) {

            return $false

        }

        foreach ($Line in $Policy) {

            if ($Line -match "password history") {

                if ($Line -match "\b$Expected\b") {

                    Write-Log "Password history validation passed." "SUCCESS"

                    return $true

                }

            }

        }

        Write-Log "Password history validation failed." "ERROR"

        return $false

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Invoke Password Policy Remediation
#=========================================================

function Invoke-PasswordPolicyRemediation {

    [CmdletBinding()]
    param(

        [Parameter()]
        [string]$ControlID = "1.1.1"

    )

    Write-Log "Starting Password Policy remediation..." "INFO"

    if (-not (Backup-PasswordPolicy)) {

        Write-Log "Unable to create password policy backup." "ERROR"

        return

    }

    switch ($ControlID) {

        "1.1.1" {

            Write-Log "Processing CIS Control 1.1.1" "INFO"

            Set-MinimumPasswordLength -Length 14 | Out-Null

            if (Test-MinimumPasswordLength -Expected 14) {

                Write-Log "Password Policy remediation completed successfully." "SUCCESS"

            }
            else {

                Write-Log "Password Policy remediation failed validation." "ERROR"

            }

        }

        "1.1.2" {

            Write-Log "Processing CIS Control 1.1.2" "INFO"

            Set-PasswordHistorySize -Size 24 | Out-Null

            if (Test-PasswordHistorySize -Expected 24) {

                Write-Log "Password Policy remediation completed successfully." "SUCCESS"

            }
            else {

                Write-Log "Password Policy remediation failed validation." "ERROR"

            }

        }

        default {

            Write-Log "Control $ControlID not implemented yet." "WARNING"

            return

        }

    }

}