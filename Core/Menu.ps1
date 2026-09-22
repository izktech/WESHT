#=========================================================
# WESHT - Main Menu
#=========================================================

function Show-MainMenu {

    do {

        Clear-Host

        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host "     Windows Enterprise Security Hardening Toolkit"
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "1. Load Wazuh Report"
        Write-Host "2. Apply CIS Remediation"
        Write-Host "3. Generate HTML Report"
        Write-Host "4. Verify Compliance"
        Write-Host "5. Rollback Changes"
        Write-Host "0. Exit"

        Write-Host ""

        $Option = Read-Host "Select an option"

        switch ($Option) {

            #=================================================
            # Load Wazuh Report
            #=================================================

            "1" {

                $Path = Read-Host "Enter Wazuh CSV Report"

                if (Import-WazuhReport -Path $Path) {

                    Get-ReportSummary

                    Show-ReportSummary

                    Write-Success "Report loaded successfully."

                }
                else {

                    Write-ErrorLog "Unable to load Wazuh report."

                }

                Pause

            }

            #=================================================
            # Apply CIS Remediation
            #=================================================

            "2" {

                if (-not $Global:FailedControls -or
                    $Global:FailedControls.Count -eq 0) {

                    Write-WarningLog "No failed controls found."

                    Pause

                    continue

                }

                Start-Remediation

                Pause

            }

            #=================================================
            # Generate HTML Report
            #=================================================

            "3" {

                if (-not $Global:ExecutionStatistics -or
                    $Global:ExecutionStatistics.TotalControls -eq 0) {

                    Write-WarningLog "No execution data available."

                }
                else {

                    $Report = New-HTMLReport

                    if ($Report -and (Test-Path $Report)) {

                        Write-Success "HTML report created successfully."

                        Write-Info "Report saved to:"

                        Write-Host ""
                        Write-Host $Report -ForegroundColor Cyan
                        Write-Host ""

                    }
                    else {

                        Write-ErrorLog "Failed to generate HTML report."

                    }

                }

                Pause

            }

            #=================================================
            # Verify Compliance
            #=================================================

            "4" {

                Write-Info "Compliance verification module is coming soon."

                Pause

            }

            #=================================================
            # Rollback
            #=================================================

            "5" {

                Write-Info "Rollback module is coming soon."

                Pause

            }

            #=================================================
            # Exit
            #=================================================

            "0" {

                Write-Success "Closing WESHT..."

            }

            #=================================================
            # Invalid Option
            #=================================================

            default {

                Write-WarningLog "Invalid option."

                Pause

            }

        }

    } until ($Option -eq "0")

}