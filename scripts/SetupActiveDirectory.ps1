# Variables
$dns_domain_name = "dstrobel.local"
$safe_mode_password = "secretpassword123"

# Process
$requiredFeatures = @("AD-Domain-Services", "RSAT-ADDS")
$features = Get-WindowsFeature -Name $requiredFeatures
$unavailableFeatures = Compare-Object -ReferenceObject $requiredFeatures -DifferenceObject $features.Name -PassThru

if ($unavailableFeatures) {
    Write-Error -Message "Windows Features are missing and unavailable."
    exit 1
}

$missingFeatures = $features | Where-Object InstallState -NE Installed
if ($missingFeatures) {
    $res = Install-WindowsFeature -Name $missingFeatures
}

try {
    $forestContext = New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList @(
        'Forest', $dns_domain_name
    )
    $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($forestContext)
}
catch [System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFoundException] {
    $forest = $null
}
catch [System.DirectoryServices.ActiveDirectory.ActiveDirectoryOperationException] {
    $forest = $null
}

if (-not $forest) {
    $installParams = @{
        DomainName                    = $dns_domain_name
        SafeModeAdministratorPassword = (ConvertTo-SecureString $safe_mode_password -AsPlainText -Force)
        Confirm                       = $false
        SkipPreChecks                 = $true
        InstallDns                    = $true
        NoRebootOnCompletion          = $true
    }

    $res = $null
    try {
        $res = Install-ADDSForest @installParams
    }
    catch [Microsoft.DirectoryServices.Deployment.DCPromoExecutionException] {
        Write-Error -Message "Failed to install ADDSForest, DCPromo exited with $($_.Exception.ExitCode): $($_.Exception.Message)", $_
    }
    finally {
        try {
            Start-Service -Name Netlogon
        }
        catch {
            $msg = -join @(
                "Failed to start the Netlogon service after promoting the host, "
                "Ansible may be unable to connect until the host is manually rebooting: $($_.Exception.Message)"
            )
            Write-Error -Message $msg
            exit 1
        }
    }
}
