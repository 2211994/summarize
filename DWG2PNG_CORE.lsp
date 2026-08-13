(defun c:DWG2PNG_CORE ( / dwgname outfile)

  (princ "\n====== DWG2PNG CORE V4 ======")


  ;; 当前DWG名字
  (setq dwgname
    (vl-filename-base
      (getvar "DWGNAME")
    )
  )


  ;; 输出PNG路径
  (setq outfile
    (strcat
      "F:\\YOLO_Donut_Project\\CAD\\"
      dwgname
      ".png"
    )
  )


  ;; ==========================
  ;; 导入页面设置
  ;; ==========================

  (princ "\nImport YOLO_EXPORT...")


  (command
    "_.-PSETUPIN"
    "F:\\YOLO_Donut_Project\\YOLO_EXPORT.dwt"
    "YOLO_EXPORT"
  )


  ;; ==========================
  ;; 模型空间
  ;; ==========================

  (command "_.MODEL")


  ;; ==========================
  ;; 显示全部
  ;; ==========================

  (command
    "_.ZOOM"
    "_E"
  )


  ;; ==========================
  ;; 关闭后台打印
  ;; ==========================

  (setvar "BACKGROUNDPLOT" 0)


  ;; ==========================
  ;; 打印
  ;; ==========================

  (princ "\nStart Plot...")


  (command
    "-PLOT"

    "N"                 ;详细设置

    "MODEL"             ;布局

    "YOLO_EXPORT"       ;页面设置

    "PublishToWeb PNG.pc3"

    outfile

    "N"                 ;保存页面设置修改

    "Y"                 ;继续打印
  )


  (princ
    (strcat
      "\n完成:"
      outfile
    )
  )


  (princ)

)