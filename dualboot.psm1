# To use this effectively:
#  1. Copy a powershell shortcut to your desktop.
#  2. Make the target of the shortcut: %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -noexit -command import-module C:\PathTo\dualboot.psm1
#  3. Launch PowerShell with that shortcut, the functions below and now available

function Confirm-IsAdmin {
    $currentUser = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin)
    {
        throw "ERROR YOU MUST BE ADMIN"
    }
}

function Get-LinuxBootManagerGuid {
    Confirm-IsAdmin

    $bcdOutput = bcdedit /enum all
    # TODO(colemick): complete this to get the actual guid instead of hardcoding it

    return "{6ee679d9-50a9-11e5-bb69-806e6f6e6963}"
}

function Start-WindowsPermanently {
    Confirm-IsAdmin
    
    $linuxBootManagerGuid = Get-LinuxBootManagerGuid
    Write-Output bcdedit /set {fwbootmgr} displayorder {bootmgr} $linuxBootManagerGuid
    Write-Output shutdown /r /t 0
}

function Start-WindowsOnce {
    Confirm-IsAdmin
    
    Write-Output bcdedit /set {fwbootmgr} bootsequence {bootmgr}
    Write-Output shutdown /r /t 0
}

function Start-LinuxPermanently {
    Confirm-IsAdmin
    
    $linuxBootManagerGuid = Get-LinuxBootManagerGuid
    Write-Output bcdedit /set {fwbootmgr} displayorder $linuxBootManagerGuid {bootmgr}
    Write-Output shutdown /r /t 0
}

function Start-LinuxOnce {
    Confirm-IsAdmin
    
    $linuxBootManagerGuid = Get-LinuxBootManagerGuid
    Write-Output bcdedit /set {fwbootmgr} bootsequence $linuxBootManagerGuid
    Write-Output shutdown /r /t 0
}

Export-ModuleMember -Function Get-LinuxBootManagerGuid
Export-ModuleMember -Function Start-WindowsPermanently
Export-ModuleMember -Function Start-WindowsOnce
Export-ModuleMember -Function Start-LinuxPermanently
Export-ModuleMember -Function Start-LinuxOnce
