@echo off

echo  ----------  ---------- Starting Script ----------  ---------- 
setlocal enabledelayedexpansion

@REM Define path to abaqus executable.
set abaqus_path="abaqus.bat"
set numCPUs=2
set numGPUs=0
set interactiveFlag=true
set userSubroutine=
set delete_files=true


set argCount=0
for %%x in (%*) do (
   set /A argCount+=1
   set "argVec[!argCount!]=%%~x"
)

set next_cpu=0;
set next_gpu=0;
set next_user=0;
set next_askDelete=0;
for /L %%i in (1,1,%argCount%) do (
    set param=!argVec[%%i]!
    if  !next_cpu! equ 1 (
        set numCPUs=!param!
        set next_cpu=0;
    )
    if  !next_gpu! equ 1 (
        set numGPUs=!param!
        set next_gpu=0;
    )
    if  !next_user! equ 1 (
        set userSubroutine=!param!
        set next_user=0;
    )
    if  !next_askDelete! equ 1 (
        if "!param!" == "OFF" ( 
             set delete_files=true)
        if "!param!" == "ON" ( 
            set delete_files=false)
        
        set next_askDelete=0;
    )
    if "!param!" == "cpus" (
        set next_cpu=1
    )
    if "!param!" == "gpus" (
        set next_gpu=1
    )
    if "!param!" == "user" (
        set next_user=1
    )
    if "!param!" == "ask_delete" (
        set next_askDelete=1
    )
    
)
set "tab=    "
echo The following input files will be processed:
for %%f in (*.inp) do (
    if "%%~xf"==".inp" (
    echo  !tab! %%~nf
    )
    )
set /p "choice=Would you like to continue? (Y/N): "
if /i "%choice%"=="N" (  goto :exit_script )
if /i not "%choice%"=="Y" ( goto :exit_script)
for %%f in (*.inp) do (
    if "%%~xf"==".inp" (

        set job_name=%%~nf
        echo ---------- starting job  !job_name! ----------
        @REM Basic abaqus command 
        set abaqus_cmd=!abaqus_path! job=!job_name! cpus=!numCPUs!

        @REM Check if GPUs are to be included
        if !numGPUs! gtr 0 (
            set abaqus_cmd=!abaqus_cmd! gpus=!numGPUs!
        )

        @REM Check if interactive mode is enabled
        if /I "!interactiveFlag!"=="true" (
            set abaqus_cmd=!abaqus_cmd! int
        )

        @REM Check if ask_delete is OFF mode is enabled
        if /I "!delete_files!"=="true" (
            set abaqus_cmd=!abaqus_cmd! ask_delete=OFF
        )

        @REM Check if user subroutine is provided
        if not "!userSubroutine!"=="" (
            set abaqus_cmd=!abaqus_cmd! user="!userSubroutine!"
        )
        echo Executing the following commad
        echo !abaqus_cmd!

        @REM Runs the prepared abaqus commad
        call  !abaqus_cmd!

	)
)

:exit_script

echo ----------  ---------- Done Executing Script ----------  ----------

exit 0