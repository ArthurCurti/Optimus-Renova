
@echo off
cd /d "%~dp0"

for %%F in (*.inp) do (
    echo Running TurbSim with %%F
    TurbSim.exe "%%F"
)

pause