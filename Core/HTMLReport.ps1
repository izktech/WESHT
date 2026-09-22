<#
.SYNOPSIS
    HTML Report Engine

.DESCRIPTION
    Generates a professional HTML report after remediation.

.AUTHOR
    Luis Fonseca

.VERSION
    1.0
#>

#=========================================================
# Global Variables
#=========================================================

$Global:ReportFolder = Join-Path $PSScriptRoot "..\Reports"

#=========================================================
# Initialize Report Folder
#=========================================================

function Initialize-ReportFolder {

    if (!(Test-Path $Global:ReportFolder)) {

        New-Item `
            -ItemType Directory `
            -Path $Global:ReportFolder `
            -Force | Out-Null

    }

}

#=========================================================
# Generate HTML Report
#=========================================================

function New-HTMLReport {

    [CmdletBinding()]
    param()

    Initialize-ReportFolder

    $ReportFile = Join-Path $Global:ReportFolder ("WESHT_Report_{0}.html" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

    $Elapsed = New-TimeSpan `
        -Start $Global:ExecutionStatistics.Started `
        -End $Global:ExecutionStatistics.Finished

    $Html = @"

<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>WESHT Report</title>

<style>

body{

    font-family:Segoe UI;

    background:#f4f4f4;

    margin:30px;

}

table{

    border-collapse:collapse;

    width:100%;

}

th{

    background:#1565C0;

    color:white;

    padding:10px;

}

td{

    border:1px solid #ddd;

    padding:8px;

}

.success{

    color:green;

    font-weight:bold;

}

.failed{

    color:red;

    font-weight:bold;

}

.warning{

    color:orange;

    font-weight:bold;

}

h1{

    color:#1565C0;

}

</style>

</head>

<body>

<h1>Windows Enterprise Security Hardening Toolkit</h1>

<h2>Execution Summary</h2>

<table>

<tr><th>Metric</th><th>Value</th></tr>

<tr><td>Total Controls</td><td>$($Global:ExecutionStatistics.TotalControls)</td></tr>

<tr><td>Successful</td><td class="success">$($Global:ExecutionStatistics.Successful)</td></tr>

<tr><td>Failed</td><td class="failed">$($Global:ExecutionStatistics.Failed)</td></tr>

<tr><td>Skipped</td><td class="warning">$($Global:ExecutionStatistics.Skipped)</td></tr>

<tr><td>Execution Time</td><td>$Elapsed</td></tr>

<tr><td>Generated</td><td>$(Get-Date)</td></tr>

</table>

<br>

<h2>Failed Controls</h2>

<table>

<tr>

<th>Control ID</th>

<th>Status</th>

</tr>

"@

    foreach ($Control in $Global:FailedControls) {

        $ControlID = Get-ControlID $Control

        $Html += @"

<tr>

<td>$ControlID</td>

<td class='failed'>FAILED</td>

</tr>

"@

    }

    $Html += @"

</table>

</body>

</html>

"@

    Set-Content `
        -Path $ReportFile `
        -Value $Html `
        -Encoding UTF8

    Write-Log "HTML report generated successfully." "SUCCESS"

    Write-Log "Report: $ReportFile" "INFO"

    return $ReportFile

}