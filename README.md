## Synopsis

This is a powershell script to help you initally setup [User Sync Tool from Adobe](https://github.com/adobe-apiplatform/user-sync.py) on a windows system. This tool will download & install python 3.6.3 x64, Set Environment Variable, Download [User Sync Tool](https://github.com/adobe-apiplatform/user-sync.py/releases) and example configuration files and place them in the correct location.

## Installation

Simply copy either command below to run the install script remotely.

Running from PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process; `
iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/vbItN'))
```
Running from Command Prompt:

```dos
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" ^
-NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
"iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/vbItN'))"
```

## Note

This script downloaded the following into temp folder C:\Users\\[Username]\Appdata\Local\Temp\USTDownload

[Standalone 7-zip](http://www.7-zip.org/a/7za920.zip)<br/>
[Python 3.6.3 x64](https://www.python.org/ftp/python/3.6.3/python-3.6.3-amd64.exe)<br />
[OpenSSL Win32 Binary 1.0.1l](https://indy.fulgan.com/SSL/openssl-1.0.2l-x64_86-win64.zip)<br />
[User Sync Tool 2.2.2 PY3.6 for Windows](https://github.com/adobe-apiplatform/user-sync.py/releases/download/v2.2.2/user-sync-v2.2.2-windows-py363.tar.gz)<br/>
[User Sync Tool Example Configuration Files](https://github.com/adobe-apiplatform/user-sync.py/releases/download/v2.2.1/example-configurations.tar.gz)
