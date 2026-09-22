<#
.SYNOPSIS
    Account Policy Module

.DESCRIPTION
    Implements CIS Account Lockout Policy remediation
    for the Windows Enterprise Security Hardening Toolkit.

.AUTHOR
    Luis Fonseca

.VERSION
    1.0
#>

#=========================================================
# Get Current Account Policy
#=========================================================

function Get-AccountPolicy {

    [CmdletBinding()]
    param()

    Write-Log "Reading account lockout policy..." "INFO"

    try {

        return net accounts

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $null

    }

}

#=========================================================
# Set Account Lockout Threshold
#=========================================================

function Set-AccountLockoutThreshold {

    [CmdletBinding()]
    param(

        [Parameter()]
        [ValidateRange(1,999)]
        [int]$Threshold = 5

    )

    Write-Log "Configuring account lockout threshold to $Threshold..." "INFO"

    try {

        net accounts /lockoutthreshold:$Threshold | Out-Null

        Write-Log "Account lockout threshold configured." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Test Account Lockout Threshold
#=========================================================

function Test-AccountLockoutThreshold {

    [CmdletBinding()]
    param(

        [Parameter()]
        [int]$Expected = 5

    )

    try {

        $Policy = Get-AccountPolicy

        if (-not $Policy) {

            return $false

        }

        foreach ($Line in $Policy) {

            if ($Line -match "Lockout threshold") {

                if ($Line -match "\b$Expected\b") {

                    Write-Log "Account lockout threshold validation passed." "SUCCESS"

                    return $true

                }

            }

        }

        Write-Log "Account lockout threshold validation failed." "ERROR"

        return $false

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Invoke Account Policy Remediation
#=========================================================

function Invoke-AccountPolicyRemediation {

    [CmdletBinding()]
    param(

        [Parameter()]
        [string]$ControlID = "1.2.1"

    )

    Write-Log "Starting Account Policy remediation..." "INFO"

    switch ($ControlID) {

        "1.2.1" {

            Write-Log "Processing CIS Control 1.2.1" "INFO"

            Set-AccountLockoutThreshold -Threshold 5 | Out-Null

            if (Test-AccountLockoutThreshold -Expected 5) {

                Write-Log "Account Policy remediation completed successfully." "SUCCESS"

            }
            else {

                Write-Log "Account Policy remediation failed validation." "ERROR"

            }

        }

        default {

            Write-Log "Control $ControlID not implemented yet." "WARNING"

            return

        }

    }

}
