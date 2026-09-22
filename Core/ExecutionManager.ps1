<#
.SYNOPSIS
    Execution Manager

.DESCRIPTION
    Executes remediation modules for every failed CIS control.

.AUTHOR
    Luis Fonseca

.VERSION
    1.0
#>

#=========================================================
# Global Statistics
#=========================================================

$Global:ExecutionStatistics = [ordered]@{

    TotalControls = 0
    Successful    = 0
    Failed        = 0
    Skipped       = 0
    Started       = $null
    Finished      = $null

}

#=========================================================
# Reset Statistics
#=========================================================

function Reset-ExecutionStatistics {

    $Global:ExecutionStatistics.TotalControls = 0
    $Global:ExecutionStatistics.Successful = 0
    $Global:ExecutionStatistics.Failed = 0
    $Global:ExecutionStatistics.Skipped = 0
    $Global:ExecutionStatistics.Started = Get-Date
    $Global:ExecutionStatistics.Finished = $null

}

#=========================================================
# Execute Failed Controls
#=========================================================

function Start-Remediation {

    [CmdletBinding()]
    param()

    Reset-ExecutionStatistics

    Write-Log "==============================================" "INFO"
    Write-Log "Starting Automatic Remediation..." "INFO"
    Write-Log "==============================================" "INFO"

    if ($Global:FailedControls.Count -eq 0) {

        Write-Log "No failed controls detected." "SUCCESS"

        return

    }

    foreach ($Control in $Global:FailedControls) {

        $Global:ExecutionStatistics.TotalControls++

        try {

            $Result = Invoke-Remediation -Control $Control

            if ($Result) {

                $Global:ExecutionStatistics.Successful++

            }
            else {

                $Global:ExecutionStatistics.Failed++

            }

        }

        catch {

            Write-Log $_.Exception.Message "ERROR"

            $Global:ExecutionStatistics.Failed++

        }

    }

    $Global:ExecutionStatistics.Finished = Get-Date

    Show-ExecutionSummary

}


#=========================================================
# Execution Summary
#=========================================================

function Show-ExecutionSummary {

    $Elapsed = New-TimeSpan `
        -Start $Global:ExecutionStatistics.Started `
        -End $Global:ExecutionStatistics.Finished

    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "         REMEDIATION SUMMARY"
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host ("Controls Processed : {0}" -f $Global:ExecutionStatistics.TotalControls)

    Write-Host ("Successful         : {0}" -f $Global:ExecutionStatistics.Successful) -ForegroundColor Green

    Write-Host ("Failed             : {0}" -f $Global:ExecutionStatistics.Failed) -ForegroundColor Red

    Write-Host ("Skipped            : {0}" -f $Global:ExecutionStatistics.Skipped) -ForegroundColor Yellow

    Write-Host ("Execution Time     : {0}" -f $Elapsed)

    Write-Host ""

}


