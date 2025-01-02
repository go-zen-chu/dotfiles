# Windows

## setup

1. git clone this repository to WSL2 instance $HOME
2. open wsl2 $HOME directory via explorer
3. copy path to dotfiles
4. open powershell with admin privilege

```powershell
cd <paste path to dotfiles>
# required for loading profile.ps1
Set-ExecutionPolicy RemoteSigned
PowerShell -ExecutionPolicy Unrestricted .\os-windows\setup.ps1
```
