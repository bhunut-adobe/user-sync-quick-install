$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Expand-Targz {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
        [ValidateScript({Test-Path -path $_})]
        $Path,
        $OutPut = $Path -replace ('.tar.gz', '')

    )
    $7zipTempPath = "$env:TEMP\7zip"
    if( -not (Test-Path "$7zipTempPath\7za.exe")){
        #Create Temporary 7zip folder
        Write-Host "Creating temp 7zip Path - $7zipTempPath"
        New-Item -Path $7zipTempPath -ItemType 'Directory' -Force | Out-Null
        
        #Latest stable version of 7-zip standalone 9.2.0
        $7zURL = 'http://www.7-zip.org/a/7za920.zip'
        $7Zfilename = $7zURL.Split('/')[-1]
        $7zDownload = "$7zipTempPath\$7Zfilename"
        
        #Download 7z Command Line from 7-zip.org
        Write-Host "Downloading 7-zip Standalone ($7zURL)"
        Invoke-WebRequest -Uri $7zURL -OutFile $7zDownload

        if(Test-Path $7zDownload){
            #Extract downloaded 7-zip to 7-zip temp folder
            [System.IO.Compression.ZipFile]::ExtractToDirectory($7zDownload, $7zipTempPath)
        }

    }

   #extract tar.gz using 7zip standalone
   Start-Process cmd.exe -ArgumentList ("/c $7zipTempPath\7za.exe x $Path -so  | $7zipTempPath\7za.exe x -y -si -ttar -o`"$OutPut`"") -Wait 

}

if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Elevated."
    $DownloadFolder = "$env:TEMP\USTDownload"
    $USTFolder = "$env:SystemDrive\user_sync"
    $DownloadedItem = @()

    #Python Install
    $python362URL = "https://www.python.org/ftp/python/3.6.2/python-3.6.2-amd64.exe"
    
    $pythonInstaller = $python362URL.Split('/')[-1]
    
    #Create Temp download folder
    New-Item -Path $DownloadFolder -ItemType "Directory" -Force | Out-Null
    $pythonInstallerOutput = "$DownloadFolder\$pythonInstaller"
    Write-Host "Downloading Python from $python362URL"
    Invoke-WebRequest -Uri $python362URL -OutFile $pythonInstallerOutput

    if(Test-Path $pythonInstallerOutput){
        #Passive Install of Python. This will show progressbar and error.
        Write-Host "Begin Python Installation"
        $pythonProcess = Start-Process $pythonInstallerOutput -ArgumentList @('/passive', 'InstallAllUsers=1', 'PrependPath=1') -Wait -PassThru
        if($pythonProcess.ExitCode -eq 0){
             Write-Host "Python Installation Completed"
        }else{
             Write-Error "Python Installation Completed/Error with ExitCode: $($pythonProcess.ExitCode)"
        }
    }


    #Set Environment Variable

    [Environment]::SetEnvironmentVariable("PEX_ROOT", "$env:SystemDrive\PEX", "Machine")

    #Create UST Folder
    New-Item -Path $USTFolder -ItemType 'Directory' -Force | Out-Null
    
    #Download UST 2.2 and Extract
    $USTdownloadList = @()
    $USTdownloadList += "https://github.com/adobe-apiplatform/user-sync.py/releases/download/v2.2/user-sync-v2.2-windows-py36.tar.gz"
    $USTdownloadList += "https://github.com/adobe-apiplatform/user-sync.py/releases/download/v2.2/example-configurations.tar.gz"

    foreach($download in $USTdownloadList){
        $filename = $download.Split('/')[-1]
        $downloadfile = "$DownloadFolder\$filename"
        #Download file
        Invoke-WebRequest -Uri $download -OutFile $downloadfile
        if(Test-Path $downloadfile){
           #Extract downloaded file to UST Folder
           Write-Host "Extracting $downloadfile to $USTFolder"
           Expand-Targz -Path $downloadfile -OutPut $USTFolder
        }
    }

    
    #Copy and make it readable in windows - "config files - basic" in example to root
    $configBasicPath = "$USTFolder\examples\config files - basic"
    if(Test-Path -Path $configBasicPath){
            
        (Get-Content "$configBasicPath\1 user-sync-config.yml") | Set-Content "$USTFolder\user-sync-config.yml" -Force -Verbose
        (Get-Content "$configBasicPath\2 connector-umapi.yml") | Set-Content "$USTFolder\connector-umapi.yml" -Force -Verbose
        (Get-Content "$configBasicPath\3 connector-ldap.yml") | Set-Content "$USTFolder\connector-ldap.yml" -Force -Verbose

    }

    #Delete Temp DownloadFolder for UST, Python and Config files
    Remove-Item -Path $DownloadFolder -Recurse -Confirm:$false -Force -Verbose
    #Delete 7-zip temp folder
    Remove-Item -Path "$env:TEMP\7zip" -Recurse -Confirm:$false -Force -Verbose

    Write-Host "Completed - You can begin to edit configuration files in $USTFolder"
    Pause
}

else
{
    Write-host "Not elevated. Rerun the script with elevated permission"
}



