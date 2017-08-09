## Synopsis

This is a powershell script to help you initally setup [User Sync Tool from Adobe](https://github.com/adobe-apiplatform/user-sync.py) on a windows system. This tool will download & install python 3.6.2 x64, Set Environment Variable, Download [User Sync Tool 2.2](https://github.com/adobe-apiplatform/user-sync.py/releases/tag/v2.2) and example configuration files and place them in the correct location.

## Installation

Simply copy either command below to run the install script remotely.

Running from PowerShell:

```powershell
Set-ExecutionPolicy bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/bhunut-adobe/user-sync-quick-install/master/install.ps1'))
```
Running from Command Prompt:

```dos
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/bhunut-adobe/user-sync-quick-install/master/install.ps1'))"
```

This will install User Sync Tool under C:\user_sync

## Note

This script downloaded the following into temp folder C:\Users\\[Username]\Appdata\Local\Temp\USTDownload

[Standalone 7-zip](http://www.7-zip.org/a/7za920.zip)<br>
[Python 3.6.2 x64](https://www.python.org/ftp/python/3.6.2/python-3.6.2-amd64.exe)<br>
[User Sync Tool 2.2 PY3.6 for Windows](https://github.com/adobe-apiplatform/user-sync.py/releases/download/v2.2/user-sync-v2.2-windows-py36.tar.gz)<br>
[User Sync Tool 2.2 Example Configuration Files](https://github.com/adobe-apiplatform/user-sync.py/releases/download/v2.2/example-configurations.tar.gz)
