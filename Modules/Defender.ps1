<#
.SYNOPSIS
    Defender Module

.DESCRIPTION
    Implements CIS Windows Defender remediation
    for the Windows Enterprise Security Hardening Toolkit.

.AUTHOR
    Luis Fonseca

.VERSION
    1.0
#>

#=========================================================
# Get Current Defender Preferences
#=========================================================

function Get-DefenderPreferences {

    [CmdletBinding()]
    param()

    Write-Log "Reading Windows Defender preferences..." "INFO"

    try {

        return Get-MpPreference

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $null

    }

}

#=========================================================
# Enable Cloud Protection
#=========================================================

function Enable-CloudProtection {

    [CmdletBinding()]
    param()

    Write-Log "Enabling Windows Defender cloud protection..." "INFO"

    try {

        Set-MpPreference -MAPSReporting Advanced
        Set-MpPreference -SubmitSamplesConsent SendSafeSamples

        Write-Log "Cloud protection enabled." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Test Cloud Protection
#=========================================================

function Test-CloudProtection {

    [CmdletBinding()]
    param()

    try {

        $Preferences = Get-DefenderPreferences

        if (-not $Preferences) {

            return $false

        }

        if ($Preferences.MAPSReporting -ne 0) {

            Write-Log "Cloud protection validation passed." "SUCCESS"

            return $true

        }

        Write-Log "Cloud protection validation failed." "ERROR"

        return $false

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Invoke Defender Remediation
#=========================================================

function Invoke-DefenderRemediation {

    [CmdletBinding()]
    param(

        [Parameter()]
        [string]$ControlID = "18.10.43"

    )

    Write-Log "Starting Defender remediation..." "INFO"

    switch ($ControlID) {

        "18.10.43" {

            Write-Log "Processing CIS Control 18.10.43" "INFO"

            Enable-CloudProtection | Out-Null

            if (Test-CloudProtection) {

                Write-Log "Defender remediation completed successfully." "SUCCESS"

            }
            else {

                Write-Log "Defender remediation failed validation." "ERROR"

            }

        }

        default {

            Write-Log "Control $ControlID not implemented yet." "WARNING"

            return

        }

    }

}
