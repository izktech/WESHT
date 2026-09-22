<#
.SYNOPSIS
    Firewall Module

.DESCRIPTION
    Implements CIS Windows Firewall remediation
    for the Windows Enterprise Security Hardening Toolkit.

.AUTHOR
    Luis Fonseca

.VERSION
    1.0
#>

#=========================================================
# Get Current Firewall Profile State
#=========================================================

function Get-FirewallProfileState {

    [CmdletBinding()]
    param(

        [Parameter()]
        [ValidateSet("Domain","Private","Public")]
        [string]$Profile = "Domain"

    )

    Write-Log "Reading firewall state for profile: $Profile..." "INFO"

    try {

        return Get-NetFirewallProfile -Profile $Profile

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $null

    }

}

#=========================================================
# Enable Firewall Profile
#=========================================================

function Enable-FirewallProfile {

    [CmdletBinding()]
    param(

        [Parameter()]
        [ValidateSet("Domain","Private","Public")]
        [string]$Profile = "Domain"

    )

    Write-Log "Enabling firewall for profile: $Profile..." "INFO"

    try {

        Set-NetFirewallProfile -Profile $Profile -Enabled True

        Write-Log "Firewall profile '$Profile' enabled." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Test Firewall Profile
#=========================================================

function Test-FirewallProfile {

    [CmdletBinding()]
    param(

        [Parameter()]
        [ValidateSet("Domain","Private","Public")]
        [string]$Profile = "Domain"

    )

    try {

        $State = Get-FirewallProfileState -Profile $Profile

        if (-not $State) {

            return $false

        }

        if ($State.Enabled) {

            Write-Log "Firewall profile '$Profile' validation passed." "SUCCESS"

            return $true

        }

        Write-Log "Firewall profile '$Profile' validation failed." "ERROR"

        return $false

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Invoke Firewall Remediation
#=========================================================

function Invoke-FirewallRemediation {

    [CmdletBinding()]
    param(

        [Parameter()]
        [string]$ControlID = "9.1.1"

    )

    Write-Log "Starting Firewall remediation..." "INFO"

    switch ($ControlID) {

        "9.1.1" {

            Write-Log "Processing CIS Control 9.1.1" "INFO"

            Enable-FirewallProfile -Profile "Domain" | Out-Null

            if (Test-FirewallProfile -Profile "Domain") {

                Write-Log "Firewall remediation completed successfully." "SUCCESS"

            }
            else {

                Write-Log "Firewall remediation failed validation." "ERROR"

            }

        }

        default {

            Write-Log "Control $ControlID not implemented yet." "WARNING"

            return

        }

    }

}
