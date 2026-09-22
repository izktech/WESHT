function Test-IsAdministrator {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

}

function Initialize-Toolkit {

    if (!(Test-IsAdministrator)) {

        Write-Host ""

        Write-Host "ERROR: Execute PowerShell as Administrator." -ForegroundColor Red

        Pause

        Exit

    }

    New-Item -ItemType Directory -Force -Path ".\Logs" | Out-Null

    New-Item -ItemType Directory -Force -Path ".\Reports" | Out-Null

    New-Item -ItemType Directory -Force -Path ".\Rollback" | Out-Null

}