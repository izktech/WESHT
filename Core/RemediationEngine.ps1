#=========================================================
# WESHT - Remediation Engine
#=========================================================

#---------------------------------------------------------
# Global Variables
#---------------------------------------------------------

$Global:CISMappings = @{}

#=========================================================
# Load CIS Mappings
#=========================================================

function Load-CISMappings {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Path

    )

    Write-Log "Loading CIS mappings..." "INFO"

    if (!(Test-Path $Path)) {

        Write-Log "Mapping file not found: $Path" "ERROR"

        return $false

    }

    try {

        $Global:CISMappings = Get-Content -Path $Path -Raw | ConvertFrom-Json

        Write-Log "Mappings loaded successfully." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}

#=========================================================
# Get Control ID
#=========================================================

function Get-ControlID {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [psobject]$Control

    )

    $PossibleColumns = @(

        "ControlID",
        "Control ID",
        "ID",
        "Rule ID",
        "Rule",
        "Recommendation"

    )

    foreach ($Column in $PossibleColumns) {

        if ($Control.PSObject.Properties.Name -contains $Column) {

            return $Control.$Column

        }

    }

    return $null

}

#=========================================================
# Get Remediation Mapping
#=========================================================

function Get-Remediation {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$ControlID

    )

    return $Global:CISMappings.$ControlID

}

#=========================================================
# Invoke Remediation
#=========================================================

function Invoke-Remediation {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [psobject]$Control

    )

    #-----------------------------------------------------
    # Detect Control ID
    #-----------------------------------------------------

    $ControlID = Get-ControlID -Control $Control

    if (-not $ControlID) {

        Write-Log "Unable to determine Control ID." "ERROR"

        return $false

    }

    #-----------------------------------------------------
    # Load Mapping
    #-----------------------------------------------------

    $Mapping = Get-Remediation -ControlID $ControlID

    if (-not $Mapping) {

        Write-Log "No remediation mapping found for Control ID: $ControlID" "WARNING"

        return $false

    }

    Write-Log "==================================================" "DEBUG"
    Write-Log "Processing Control : $ControlID" "INFO"
    Write-Log "Module             : $($Mapping.Module)" "INFO"
    Write-Log "Function           : $($Mapping.Function)" "INFO"

    if ($Mapping.Description) {

        Write-Log "Description        : $($Mapping.Description)" "DEBUG"

    }

    if ($Mapping.Severity) {

        Write-Log "Severity           : $($Mapping.Severity)" "DEBUG"

    }

    #-----------------------------------------------------
    # Verify Function Exists
    #-----------------------------------------------------

    $Command = Get-Command -Name $Mapping.Function -ErrorAction SilentlyContinue

    if (-not $Command) {

        Write-Log "Function $($Mapping.Function) was not found." "ERROR"

        return $false

    }

    #-----------------------------------------------------
    # Execute Remediation
    #-----------------------------------------------------

    try {

        Write-Log "Executing remediation..." "INFO"

        & $Mapping.Function -ControlID $ControlID

        Write-Log "Remediation completed." "SUCCESS"

        return $true

    }

    catch {

        Write-Log $_.Exception.Message "ERROR"

        return $false

    }

}