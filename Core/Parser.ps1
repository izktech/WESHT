#=========================================================
# WESHT - Wazuh Parser
#=========================================================

#---------------------------------------------------------
# Global Variables
#---------------------------------------------------------

$Global:WazuhReport     = @()
$Global:FailedControls  = @()
$Global:PassedControls  = @()
$Global:WarningControls = @()
$Global:NotApplicable   = @()

#=========================================================
# Import Wazuh Report
#=========================================================

function Import-WazuhReport {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Path

    )

    Write-Log "Loading Wazuh report..." INFO

    if (!(Test-Path $Path)) {

        Write-Log "CSV file not found: $Path" ERROR
        return $false

    }

    try {

        $Global:WazuhReport = Import-Csv -Path $Path

        if ($Global:WazuhReport.Count -eq 0) {

            Write-Log "The CSV file is empty." WARNING
            return $false

        }

        Write-Log "$($Global:WazuhReport.Count) controls imported successfully." SUCCESS

        return $true

    }

    catch {

        Write-Log $_.Exception.Message ERROR
        return $false

    }

}

#=========================================================
# Analyze Report
#=========================================================

function Get-ReportSummary {

    Write-Log "Analyzing Wazuh report..." INFO

    # Clear previous results

    $Global:FailedControls  = @()
    $Global:PassedControls  = @()
    $Global:WarningControls = @()
    $Global:NotApplicable   = @()

    #-----------------------------------------------------
    # Detect Status Column Automatically
    #-----------------------------------------------------

    $StatusColumn = $Global:WazuhReport[0].PSObject.Properties.Name |
        Where-Object { $_ -match "status|result" } |
        Select-Object -First 1

    if (-not $StatusColumn) {

        Write-Log "Unable to detect the Status column." ERROR
        return

    }

    Write-Log "Status column detected: $StatusColumn" DEBUG

    $Counter = 0

    foreach ($Control in $Global:WazuhReport) {

        $Counter++

        $Status = [string]$Control.$StatusColumn

        Write-Log "Processing Control #$Counter - Status: $Status" DEBUG

        switch ($Status.ToUpper()) {

            "FAILED" {

                $Global:FailedControls += $Control

            }

            "PASSED" {

                $Global:PassedControls += $Control

            }

            "WARNING" {

                $Global:WarningControls += $Control

            }

            "NOT APPLICABLE" {

                $Global:NotApplicable += $Control

            }

            default {

                Write-Log "Unknown status detected: $Status" WARNING

            }

        }

    }

    Write-Log "$Counter controls analyzed successfully." SUCCESS

}

#=========================================================
# Display Report Summary
#=========================================================

function Show-ReportSummary {

    $Compliance = 0

    if ($Global:WazuhReport.Count -gt 0) {

        $Compliance = [math]::Round(
            ($Global:PassedControls.Count / $Global:WazuhReport.Count) * 100,
            2
        )

    }

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "              WAZUH REPORT SUMMARY"
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host ("Total Controls : {0}" -f $Global:WazuhReport.Count)

    Write-Host ("Passed         : {0}" -f $Global:PassedControls.Count) -ForegroundColor Green

    Write-Host ("Failed         : {0}" -f $Global:FailedControls.Count) -ForegroundColor Red

    Write-Host ("Warnings       : {0}" -f $Global:WarningControls.Count) -ForegroundColor Yellow

    Write-Host ("Not Applicable : {0}" -f $Global:NotApplicable.Count)

    Write-Host ""

    Write-Host ("Compliance     : {0}%" -f $Compliance) -ForegroundColor Cyan

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

}