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
function Show-SaveDialog(){
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName PresentationCore,PresentationFramework

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $form = New-Object System.Windows.Forms.Form -Property @{TopMost = $True}
    $foldername.Description = "Select User-Sync-Tool installation folder:"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog($form) -eq "OK")
    {
        $folder = $foldername.SelectedPath
        if((Get-ChildItem -Recurse $folder).Count -gt 0){

            $ButtonType = [System.Windows.MessageBoxButton]::YesNo
            $MessageboxTitle = "Warning!"
            $Messageboxbody = “Selected Folder is not empty! Are you sure you want to continue?”
            $MessageIcon = [System.Windows.MessageBoxImage]::Warning
            $result = [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)

            if($result -ne "Yes"){
                Write-Error "UST Installation aborted"
            }
    
        }

    }else{
        Write-Error "UST Installation aborted"
    }
    return $folder
}

if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Host "Elevated."
    $DownloadFolder = "$env:TEMP\USTDownload"
    $USTFolder = Show-SaveDialog

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

    
    #Make example config files readable in windows and Copy "config files - basic" to root
    $configExamplePath = "$USTFolder\examples"
    if(Test-Path -Path $configExamplePath){    
        Get-ChildItem -Path $configExamplePath -Recurse -Filter '*.yml' | % { ( $_ |  Get-Content ) | Set-Content $_.pspath -Force }
        #Copy config files
        $configBasicPath = "$configExamplePath\config files - basic"
        Copy-Item -Path "$configBasicPath\3 connector-ldap.yml" -Destination $USTFolder\connector-ldap.yml -Force
        Copy-Item -Path "$configBasicPath\2 connector-umapi.yml" -Destination $USTFolder\connector-umapi.yml -Force
        Copy-Item -Path "$configBasicPath\1 user-sync-config.yml" -Destination $USTFolder\user-sync-config.yml -Force

    }

    #Download OpenSSL 1.0.2l binary for Windows and extract to utils folder
    $openSSLBinURL = "https://indy.fulgan.com/SSL/openssl-1.0.2l-x64_86-win64.zip"
    $openSSLBinFileName = $openSSLBinURL.Split('/')[-1]
    $openSSLOutputPath = "$DownloadFolder\$openSSLBinFileName"
    $openSSLUSTFolder = "$USTFolder\Utils\openSSL"
    Write-Host "Downloading OpenSSL Win32 Binary from $openSSLBinURL"
    Invoke-WebRequest -Uri $openSSLBinURL -OutFile $openSSLOutputPath

    if(Test-Path $openSSLOutputPath){
        #Extracting downloaded file to UST folder.
        Write-Host "Extracting $openSSLBinFileName to $openSSLUSTFolder"
        try{
            New-Item -Path $openSSLUSTFolder -ItemType Directory -Force
            [System.IO.Compression.ZipFile]::ExtractToDirectory($openSSLOutputPath, $openSSLUSTFolder)
            Write-Host "Completed extracting $openSSLBinFileName to $openSSLUSTFolder"
        }catch{
            
            Write-Error "Unable to extract openSSL"
        }
    }

    #Download Adobe.IO Cert generation Script and put it into utils\openSSL folder
    $adobeIOCertScriptURL = "https://raw.githubusercontent.com/bhunut-adobe/user-sync-quick-install/master/adobe_io_certgen.ps1"
    $adobeIOCertScript = $adobeIOCertScriptURL.Split('/')[-1]
    $adobeIOCertScriptOutputPath = "$USTFolder\Utils\openSSL\$adobeIOCertScript"
    Write-Host "Downloading Adobe.IO Cert Generation Script from $adobeIOCertScriptURL"
    Invoke-WebRequest -Uri $adobeIOCertScriptURL -OutFile $adobeIOCertScriptOutputPath

    if(Test-Path $adobeIOCertScriptOutputPath){
        
       $batchfile = '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -file ' + $adobeIOCertScriptOutputPath

       $batchfile | Out-File "$openSSLUSTFolder\Adobe_IO_Cert_Generation.bat" -Force -Encoding ascii
        
    }


    #Delete Temp DownloadFolder for UST, Python and Config files
    Remove-Item -Path $DownloadFolder -Recurse -Confirm:$false -Force -Verbose
    #Delete 7-zip temp folder
    Remove-Item -Path "$env:TEMP\7zip" -Recurse -Confirm:$false -Force -Verbose

    Write-Host "Completed - You can begin to edit configuration files in $USTFolder"
    Pause

    #Open UST Install Folder

    & explorer.exe $USTFolder
}else{
    Write-host "Not elevated. Rerun the script with elevated permission"
}


