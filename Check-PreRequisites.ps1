<#
.SYNOPSIS
Checks the machine for Sitecore 9 compatibility.

.DESCRIPTION

Quickly verify Sitecore 9:
- Hardware requirements
- Operating system compatibility
- File System Permissions for System Folders
- IIS version
- .NET Framework 4.6.2 or higher.
- SQL Server 2014 SP2 or 2016 SP1
- JavaRuntime and ensures JAVA_HOME path
- Checks and registers SIF (SitecoreInstallFramework and SitecoreFundamentals)
https://www.sitecoregabe.com/2018/04/sitecore-9-machine-prerequisites-check.html

#>

$HwCoresCheckPassed = $false
$hwRAMCheckPassed = $false
$OSCheckPassed = $false
$PowershellPassed=$false
$IISCheckPassed = $false
$DotnetCheckPassed = $false
$SQLCheckPassed = $false
$JAVACheckPassed = $false
$JREEnvPathPassed = $false
$FilePermissionsTempPassed = $false
$FilePermissionsGlobalizationPassed = $false
$FilePermissionsMSCryptoPassed = $false

#Hardware setup
$noOfcores = 2
$ramInGB = 8.0

########## Checking number of cores */
Write-Host
Write-Host
Write-Host "CHECKING CORES..." -ForegroundColor Cyan
Write-Host "________________ " -ForegroundColor Cyan
$cores = Get-WmiObject –class Win32_processor
if ($cores.NumberOfCores -ge $noOfcores) {
    Write-Host "+ Minimum number of cores (4) confirmed: " $cores.NumberOfCores " cores installed." -ForegroundColor Green
    $HwCoresCheckPassed = $true
}
else {
    Write-Host "X Minimum number of cores (4) not available!" -ForegroundColor Red
    Write-Host "Currently installed: " $cores.NumberOfCores -ForegroundColor Red
}


########## Checking minimum RAM requirements */
Write-Host
Write-Host
Write-Host "CHECKING RAM..." -ForegroundColor Cyan
Write-Host "______________ " -ForegroundColor Cyan
$InstalledRAM = Get-WmiObject -Class Win32_ComputerSystem
$RAMinGB = [Math]::Round(($InstalledRAM.TotalPhysicalMemory / 1GB), 2)
if ($RAMinGB -ge $ramInGB) {
    Write-Host "+ Minimum RAM (6GB) confirmed: " $RAMinGB "GB installed." -ForegroundColor Green
    $HwRAMCheckPassed = $true
}
else {
    Write-Host "X Minimum RAM not availble!" -ForegroundColor Red
}


#$InstalledRAM = Get-WmiObject -Class Win32_ComputerSystem
#$RAMinGB = [Math]::Round(($InstalledRAM.TotalPhysicalMemory / 1GB), 2)



########## Check OS version Windows Server 2012 R2 (64-bit) / 2016 / Windows 10 / Windows 8.1 */
Write-Host
Write-Host
Write-Host "CHECKING OPERATING SYSTEM COMPATIBILITY..." -ForegroundColor Cyan
Write-Host "__________________________________________" -ForegroundColor Cyan
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
if ([Version](Get-CimInstance Win32_OperatingSystem).version -ge [Version]"10.0") {
    Write-Host "+ Operating system is compatible: "$OSVersion " | " (Get-CimInstance Win32_OperatingSystem).version -ForegroundColor Green
    $OSCheckPassed = $true
}
elseif ([Version](Get-CimInstance Win32_OperatingSystem).version -ge [Version]"6.3") {
   
    if ($OSVersion -contains "Windows Server 2008 R2") {
        # Check if 2012 R2 is running 64bit
        if ([environment]::Is64BitProcess) {
            Write-Host "✓ Operating system is compatible: " $OSVersion " | " (Get-CimInstance Win32_OperatingSystem).version -ForegroundColor Green
            $OSCheckPassed = $true
        }
        else {
            $OSCheckPassed = $false
        }

    }
    else {
        Write-Host "+ Operating system is compatible: " $OSVersion " | " (Get-CimInstance Win32_OperatingSystem).version -ForegroundColor Green
        $OSCheckPassed = $true
    }
}
else {
    Write-Host "X Operating system is not compatible." -ForegroundColor Red
}


######### Check Folder Persmissons
Write-Host
Write-Host
Write-Host "CHECKING FOLDER PERMISSIONS..." -ForegroundColor Cyan
Write-Host "________________________________" -ForegroundColor Cyan

#### %WINDIR%\temp\ Modify To install Sitecore XP, you must assign the Modify access rights to the \temp folder for the ASP.NET and/or IUSR accounts.
$winDir = $Env:WinDir
$tempDir = $winDir + "\temp"
$Acl = Get-Acl $tempDir 
ForEach ($indProc in $Acl.Access) {
    if ($indProc.IdentityReference -match "IIS_IUSRS") {
        $FilePermissionsTempPassed = $true
    }
    
}
if ($FilePermissionsTempPassed -eq $false) {
    Write-Host "-" $tempDir "does not have IIS_IUSRS permissions..." -ForegroundColor Yellow  
    Write-Host "- Setting IIS_IUSERS Modify permissions to" $tempDir "..." -ForegroundColor Yellow
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl $tempDir $Acl
    Write-Host "+" $tempDir "IIS_IUSERS Modify permissions set!" -ForegroundColor Green
    $FilePermissionsTempPassed = $true
}
else {
    Write-Host "+" $tempDir "IIS_IUSERS Modify permissions already set!" -ForegroundColor Green
    $FilePermissionsTempPassed = $true
}

#### %WINDIR%\Globalization\ Modify Required for registering custom languages by the .NET Framework correctly
$winDir = $Env:WinDir
$globalizationDir = $winDir + "\Globalization\"
$Acl = Get-Acl $globalizationDir 
ForEach ($indProc in $Acl.Access) {
    if ($indProc.IdentityReference -match "IIS_IUSRS") {
        $FilePermissionsGlobalizationPassed = $true
    }
    
}
if ($FilePermissionsGlobalizationPassed -eq $false) {
    Write-Host "-" $globalizationDir "does not have IIS_IUSRS permissions..." -ForegroundColor Yellow  
    Write-Host "- Setting IIS_IUSERS Modify permissions to" $globalizationDir "..." -ForegroundColor Yellow
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl $globalizationDir $Acl
    Write-Host "+" $globalizationDir "IIS_IUSERS Modify permissions set!" -ForegroundColor Green
    $FilePermissionsGlobalizationPassed = $true
}
else {
    Write-Host "+" $globalizationDir "IIS_IUSERS Modify permissions already set!" -ForegroundColor Green
    $FilePermissionsGlobalizationPassed = $true
}

#### %PROGRAMDATA%\Microsoft\Crypto Modify Required for storing cryptographic keys used for encrypting/decrypting data
$ProgDataDir = $Env:ProgramData
$MicrosoftCryptoDir = $ProgDataDir + "\Microsoft\Crypto"
$Acl = Get-Acl $MicrosoftCryptoDir 
ForEach ($indProc in $Acl.Access) {
    if ($indProc.IdentityReference -match "IIS_IUSRS") {
        $FilePermissionsMSCryptoPassed = $true
    }
    
}
if ($FilePermissionsMSCryptoPassed -eq $false) {
    Write-Host "-" $MicrosoftCryptoDir "does not have IIS_IUSRS permissions..." -ForegroundColor Yellow  
    Write-Host "- Setting IIS_IUSERS Modify permissions to" $MicrosoftCryptoDir "..." -ForegroundColor Yellow
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl $MicrosoftCryptoDir $Acl
    Write-Host "+" $MicrosoftCryptoDir "IIS_IUSERS Modify permissions set!" -ForegroundColor Green
    $FilePermissionsMSCryptoPassed = $true
}
else {
    Write-Host "+" $MicrosoftCryptoDir "IIS_IUSERS Modify permissions already set!" -ForegroundColor Green
    $FilePermissionsMSCryptoPassed = $true
}


########## Check IIS version 8.5+ */
Write-Host
Write-Host
Write-Host "CHECKING FOR IIS VERSION 8.5+..." -ForegroundColor Cyan
Write-Host "________________________________" -ForegroundColor Cyan
$iisversion = get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\
if ($iisversion.MajorVersion -ge 8.5) {
    Write-Host "+ IIS version 8.5+ installed." -ForegroundColor Green
    $IISCheckPassed = $true
}
else {
    Write-Host "X IIS version 8.5+  not installed!" -ForegroundColor Red
}

########## Check Powershell version 5.1+ */
Write-Host 
Write-Host
Write-Host "CHECKING POWERSHELL COMPATIBILITY..." -ForegroundColor Cyan
Write-Host "________________________________________" -ForegroundColor Cyan
if(($PSVersionTable.PSVersion.Major -ge 5) -and ($PSVersionTable.PSVersion.Minor -ge 1)){
    Write-Host "+ POWERSHELL version 5.1+ installed." -ForegroundColor Green
    $PowershellPassed=$true
}
else{
    Write-Host "X Powershell version 5.1+  not installed!" -ForegroundColor Red
}

########## .NET COMPATIBILITY CHECK
Write-Host 
Write-Host
Write-Host "CHECKING .NET FRAMEWORK COMPATIBILITY..." -ForegroundColor Cyan
Write-Host "________________________________________" -ForegroundColor Cyan
if (Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 394802}) {
    Write-Host "+ Valid .NET Framework (4.6.2+) detected." -ForegroundColor Green
    $DotnetCheckPassed = $true
}

########## SQL COMPATIBILITY CHECK
Write-Host 
Write-Host
Write-Host "CHECKING SQL SERVER COMPATIBILITY..." -ForegroundColor Cyan
Write-Host "____________________________________" -ForegroundColor Cyan
$inst = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
$sqlCorrect = $false
foreach ($i in $inst) {
    $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$i
    $sqlV = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Version
    Write-Host  

    if ([Version]$sqlV -ge [Version]"13.0.4001.0") {
        Write-Host "+ Valid SQL Version detected: " $sqlV "|" $i "|" $p  -ForegroundColor Green
        Write-Host "Microsoft SQL Server 2016 SP1+: This version supports the XM databases and is the required and only supported version for the Experience Database (xDB)." -ForegroundColor DarkGreen
        $sqlCorrect = $true
        $SQLCheckPassed = $true
    }

    elseif ([Version]$sqlV -ge [Version]"12.0.5000.0") {
        Write-Host "+ Valid SQL Version detected: " $sqlV "|" $i "|" $p -ForegroundColor Green
        Write-Host "Microsoft SQL Server 2014 SP2: This version only supports XM databases and does not support the Experience Database (xDB)." -ForegroundColor DarkGreen
        $sqlCorrect = $true
        $SQLCheckPassed = $true
    }
    else {
        Write-Host "X Invalid SQL Version detected: " $sqlV "|" $i "|" $p -ForegroundColor Red
    }

}

if ($sqlCorrect -ne $true) {
    Write-Host "X SQL Server 2014 SP2 or 2016 SP1 or not installed." -ForegroundColor Red
}

########## JavaRuntime 1.8+   
Write-Host 
Write-Host
Write-Host "CHECKING FOR JAVARUNTIME 1.8+ ..." -ForegroundColor Cyan
Write-Host "_________________________________" -ForegroundColor Cyan
$javaver = Get-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment" -Name CurrentVersion
if ($javaver.CurrentVersion -ge 1.8) {
    Write-Host "+ JavaRuntime 1.8+ installed" -ForegroundColor Green
    $javaCheckPassed = $true
    Write-Host     
    Write-Host 
    Write-Host "Checking JAVA_HOME environment variable..." -ForegroundColor Cyan
    # Ensure Java environment variable
    $jreVal = [Environment]::GetEnvironmentVariable("JAVA_HOME", [EnvironmentVariableTarget]::Machine)
    if ($jreVal -eq $null) {
        $jrew = java -version  2>&1 | foreach-object {$_.tostring()} | Select-String -Pattern 'java version' 
        $JREVersion = $jrew -replace "[^0-9._$]"

        $javaPrgPath = "C:\Program Files\Java\"
        if (!(Test-Path $javaPrgPath -PathType Container)) { 
            write-host "C:\Program Files\Java\ not found. Trying C:\Program Files (x86)\Java\" -ForegroundColor Yellow
            $javaPrgPath = "C:\Program Files (x86)\Java\"
            if (!(Test-Path $javaPrgPath -PathType Container)) { 
                write-host "-- Path not found" -ForegroundColor Red
            }
            else {
                write-host "C:\Program Files (x86)\Java\  found." -ForegroundColor Green
            }
        }

        $JREPath = "C:\Program Files (x86)\Java\jre$JREVersion"
        if ($javaver -ne $JREPath) {
            Write-Host "Setting JAVA_HOME environment variable..." -ForegroundColor Yellow
            [Environment]::SetEnvironmentVariable("JAVA_HOME", $JREPath, [EnvironmentVariableTarget]::Machine)
            Write-Host "+ JAVA_HOME environment variable set: "  $JREPath -ForegroundColor Green
            $JREEnvPathPassed = $true
        }
    }
    else {
        Write-Host "+ JAVA_HOME environment variable set: " $jreVal  -ForegroundColor Green
        $JREEnvPathPassed = $true
    }
    
    
}
else {
    Write-Host "X JavaRuntime 1.8+ not installed!" -ForegroundColor Red
}

########## Register Sitecore Powershell NuGet feed    
Write-Host 
Write-Host
Write-Host "CHECKING SIF..." -ForegroundColor Cyan
Write-Host "_______________" -ForegroundColor Cyan

# Register Sitecore Powershell NuGet feed
# Add the Sitecore MyGet repository to PowerShell
# NOTE: I've been running into an issue registering HTTPS based repositories in what appears to be a PowerShell bug.
# The work around is to register the Register-PSRepositoryFix function as answered here and use it below https://stackoverflow.com/questions/35296482/invalid-web-uri-error-on-register-psrepository 
#.\Register-PSRepositoryFix -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2
 if(-Not (Get-PSRepository -Name SitecoreGallery -ErrorAction SilentlyContinue)){ 
 Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2
 }
# Install the Sitecore Install Framwork module
if (Get-Module -ListAvailable -Name  SitecoreInstallFramework) {
    Write-Host "+ SitecoreInstallFramework module is already registered!" -ForegroundColor Green
} 
else {
   
    Write-Host "Registering SitecoreInstallFramework module..." -ForegroundColor Yellow
    Install-Module -Name SitecoreInstallFramework -Repository SitecoreGallery -RequiredVersion 1.2.1
    Write-Host "+ SitecoreInstallFramework registered!" -ForegroundColor Green
}
# Install the Sitecore Fundamentals module (provides additional functionality for local installations like creating self-signed certificates)
if (Get-Module -ListAvailable -Name SitecoreFundamentals) {
    Write-Host "+ SitecoreInstallFramework module already registered!" -ForegroundColor Green
} 
else {
    Write-Host "Registering SitecoreFundamentals module..." -ForegroundColor Yellow
    Install-Module SitecoreFundamentals
    Write-Host "+ SitecoreFundamentals registered!" -ForegroundColor Green
}

 
Write-Host
Write-Host "______________________________________________" -ForegroundColor Cyan 
Write-Host
if ($HwCoresCheckPassed -and $HwRAMCheckPassed -and $OSCheckPassed -and $IISCheckPassed -and $PowershellPassed -and $DotnetCheckPassed -and $SQLCheckPassed -and $JAVACheckPassed -and $JREEnvPathPassed -and $FilePermissionsTempPassed -and $FilePermissionsGlobalizationPassed -and $FilePermissionsMSCryptoPassed) {
    Write-Host "+ This machine is ready to for Sitecore 9!" -ForegroundColor Green
}
else {
    Write-Host "X This machine may not be ready to for Sitecore 9..." -ForegroundColor Red
}

Write-Host 
Write-Host
