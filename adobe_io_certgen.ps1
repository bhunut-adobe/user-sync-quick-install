$ErrorActionPreference = "Stop"

function Get-USTFolder{
    param(

        $USTFolder = "$env:SystemDrive\user_sync"
    )
 
    if(Test-Path $USTFolder){

        return $USTFolder

    }else{
        $selectedFolder = Get-Folder
        if($selectedFolder){
            return Get-USTFolder -USTFolder $selectedFolder
        }
    }

}

Function Get-Folder(){
    Add-Type -AssemblyName System.Windows.Forms

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $form = New-Object System.Windows.Forms.Form -Property @{TopMost = $True}
    $foldername.Description = "Select User-Sync-Tool folder:"
    $foldername.rootfolder = "MyComputer"
    $foldername.ShowNewFolderButton = $false

    if($foldername.ShowDialog($form) -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}


Write-Host "Generate Adobe.IO Self-Signed Certifcation"
$defaulExpirationDate = (Get-Date).AddYears(5).ToString("d")
$prompt = Read-Host -Prompt "Enter Certificate Expiring Date [$defaulExpirationDate]" 
[datetime]$date = ($defaulExpirationDate,$prompt)[[bool]$prompt]
$expirationDay = ($date - (Get-Date)).Days
$USTFolder = Get-USTFolder
$OpenSSL = "$USTFolder\Utils\openSSL\openssl.exe"

if(Test-Path $OpenSSL){
    $argslist = @("/c $OpenSSL",'req',
                '-x509',
                '-sha256',
                '-nodes',
                "-days $expirationDay",
                "-newkey rsa`:2048",
                "-keyout $USTFolder\private.key",
                "-out $USTFolder\certificate_pub.crt")

    $process = Start-Process -FilePath cmd.exe -ArgumentList $argslist -PassThru -Wait
    if($process.ExitCode -eq 0){
        Write-Host "Completed - Certificate located in $USTFolder."
        Pause
        & explorer.exe "https://www.adobe.io/console"
    }else{
        Write-Error "Error Generating Certificate"
    }

}else{

    Write-Error "Unable to Locate $OpenSSL"

}