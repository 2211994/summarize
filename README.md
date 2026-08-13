基于AutoCad的命令行工具accoreconsole.exe执行自动化批量的的DWG文件转化为PNG文件并导出。

仅作为练手，由于是初学者，大部分代码由ai代劳，该项目只作为记录。

核心流程为启动DWG2PNG_BATCH.bat——建立临时temp.scr——启动accoreconsole.exe——加载DWG2PNG_CORE.lsp——设置页面、发布PNG并保存。

准备工作包括创建页面设置文件，并另存为YOLO_EXPORT.dwt，方便后续调用，PublishToWeb PNG.pc3则为AutoCad自带的打印设置。

bat流程：

由于文件中有中文名，所以设置chcp 65001 >nul避免中文乱码并且隐藏chcp的输出；

setlocal enabledelayedexpansion开启延迟变量展开，因为后续会使用!COUNT!这类变量；

设置AutoCAD Core Console 路径；

设置DWG输入文件夹和PNG输出文件夹；

定义了lsp路径（实际上没发挥作用，因为后续scr中重新写了lsp路径）；

设置如果不存在输出路径，则创建；

初始化计数器（set COUNT=0），每处理一个DWG，计数器+1（set /a COUNT+=1）；

遍历 INPUT 文件夹下所有 .dwg 文件，获取当前 DWG 的文件名（以便后续输出PNG文件使用相同名称）；

检查PNG是否存在，存在则跳过；

创建临时scr：加载lsp，调用DWG2PNG_CORE，完成后quit并确认；

启动accoreconsole.exe，打开dwg，执行scr；

循环：处理完成切换下一个dwg；

结束后暂停，按任意键退出。


lsp流程：

(defun c:DWG2PNG_CORE ( / dwgname outfile)定义DWG2PNG_CORE命令；

(setq dwgname
  (vl-filename-base
    (getvar "DWGNAME")
  )
)获取DWG文件名字，去掉后缀，保存到变量；

(setq outfile
  (strcat
    "F:\\YOLO_Donut_Project\\CAD\\"
    dwgname
    ".png"
  )
)拼接输出路径；

(command
  "_.-PSETUPIN"
  "F:\\YOLO_Donut_Project\\YOLO_EXPORT.dwt"
  "YOLO_EXPORT"
)导入页面设置；

切换模型空间；

(command
  "_.ZOOM"
  "_E"
)自动缩放，使所有图形尽可能完整地显示在视图范围内；

关闭后台打印，保证批处理稳定性；

开始打印"-PLOT"；
  (command
    "-PLOT"

    "N"                 ;详细设置

    "MODEL"             ;布局

    "YOLO_EXPORT"       ;页面设置

    "PublishToWeb PNG.pc3"

    outfile

    "N"                 ;保存页面设置修改

    "Y"                 ;继续打印
  )AutoCad会按顺序执行上述指令，完成一次打印工作。


关于修改：需要将bat和lsp文件中的路径改为需要真实路径，我代码中的路径为我项目过程中使用的路径，如果要转换别的内容，或者AutoCAD的路径发生变化，要把相对应的bat和lsp中路径改变。




resize_png.bat是一个图片尺寸转换脚本，基于ImageMagick-7.1.2-Q16-HDRI程序实现该功能。由于导出的图片尺寸基本为16K，对标注程序来说过大，所以我压缩了尺寸调整到了3000x长度左右。
