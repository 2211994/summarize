@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion


echo ======================================
echo AutoCAD 2026 DWG TO PNG Batch Export
echo YOLO / DONUT Dataset Generator
echo ======================================
echo.


REM ================================
REM AutoCAD Core Console路径
REM ================================

set ACCORE=F:\Autodesk\AutoCAD 2026\accoreconsole.exe


REM ================================
REM 输入输出目录
REM ================================

set INPUT=F:\YOLO_Donut_Project\CAD-DWG

set OUTPUT=F:\YOLO_Donut_Project\CAD


REM ================================
REM LISP路径
REM ================================

set LISP=F:\YOLO_Donut_Project\DWG2PNG_CORE.lsp



if not exist "%OUTPUT%" (
    mkdir "%OUTPUT%"
)



set COUNT=0


for %%F in ("%INPUT%\*.dwg") do (

    set /a COUNT+=1


    set NAME=%%~nF


    echo.
    echo ======================================
    echo Processing !COUNT!
    echo File:
    echo %%~nxF
    echo ======================================



    REM -----------------------------
    REM 已存在PNG则跳过
    REM -----------------------------

    if exist "%OUTPUT%\!NAME!.png" (

        echo Already exists:
        echo %OUTPUT%\!NAME!.png
        echo Skip.

    ) else (


        REM -----------------------------
        REM 创建SCR
        REM -----------------------------

        (
        echo ^(load "F:\\YOLO_Donut_Project\\DWG2PNG_CORE.lsp"^)
        echo DWG2PNG_CORE
        echo _.QUIT
        echo Y
        )>"%~dp0temp.scr"



        echo Starting AutoCAD Core Console...



        "%ACCORE%" ^
        /i "%%~fF" ^
        /s "%~dp0temp.scr"



        echo Finished:
        echo %%~nxF


    )

)



echo.
echo ======================================
echo ALL FILES COMPLETED
echo Total:
echo %COUNT%
echo ======================================

pause