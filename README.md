## Synopsis

This is a powershell script to help you initally setup [User Sync Tool from Adobe](https://github.com/adobe-apiplatform/user-sync.py) on a windows system. This tool will download & install python 3.6.2 x64, Set Environment Variable, Download [User Sync Tool 2.2](https://github.com/adobe-apiplatform/user-sync.py/releases/tag/v2.2) and example configuration files and place them in the correct location.

## Installation

Simply copy either command below to run the install script remotely.

Running from PowerShell:

```powershell
Set-ExecutionPolicy bypass; iex ((New-Object System.Net.WebClient).DownloadString('[LINK GOES HERE'))
```
Running from Command Prompt:

```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('LINK GOES HERE'))"
```

Please note: This will install UST under C:\user_sync
