@echo off

set INPUT=F:\YOLO_Donut_Project\CAD
set OUTPUT=F:\YOLO_Donut_Project\CAD1

if not exist "%OUTPUT%" mkdir "%OUTPUT%"

for %%f in ("%INPUT%\*.png") do (

    echo 正在处理:
    echo %%~nxf

    magick "%%f" -resize 3000x "%OUTPUT%\%%~nxf"

)

echo ======================
echo 全部完成
echo ======================

pause