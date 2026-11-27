
@echo off
cd /d "%~dp0"

set "TurbSim_Path=E:\Optimus-Renova\loads_and_dynamics"

for %%F in (*.inp) do (
    echo Running TurbSim with %%F
    "%TurbSim_Path%\TurbSim.exe" "%%F"
)

pause
