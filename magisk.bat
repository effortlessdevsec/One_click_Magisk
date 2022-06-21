@echo off





 if '%~1' =='install' (goto :install_modules) else (goto :CheckApiVersion)


:CheckApiVersion
SetLocal EnableDelayedExpansion

	echo [-] Pushing All Modules placed in the Modules folder
    

     for /f "delims=" %%A in ('adb shell getprop ro.build.version.sdk' ) do (
				echo [-] Your device api Version %%A
                set version=%%A
                goto :list_images %%A
				)  

	ENDLOCAL
exit /B 0  


:list_images 
setlocal EnableExtensions EnableDelayedExpansion

    set HOME="%LOCALAPPDATA%\"
	set SYSIM_DIR_W=Android\Sdk\system-images\
    SetLocal EnableDelayedExpansion
    echo %version%
    


    for /f "delims=*" %%G in ('dir  %HOME%%SYSIM_DIR%ramdisk.img /b /s /a-d') do (
   set "str1=%%G"
   if    "!str1:%version%=!" == "!str1!"  ( set ramdisk_path=%%G) else (
   
   set ramdisk_path=%%G
   goto :create-backup ramdisk_path
   
   ) 
)
	ENDLOCAL
exit /B 0 

 :create-backup ramdisk_path
 SetLocal EnableDelayedExpansion
 echo %ramdisk_path%
set BACKUPFILE=%ramdisk_path%.backup
REM If no backup file exist, create one
if not exist %BACKUPFILE% (
    	echo [*] create Backup File
		copy %ramdisk_path% %BACKUPFILE% >Nul
            	echo [*] created Backup File
                            copy %ramdisk_path%  ramdisk.img 
                            goto :install


	) else (
    	echo [-] Backup exists already
                    copy %ramdisk_path%  ramdisk.img 
                    goto :install

	)



	ENDLOCAL
exit /B 0

:install
set tool_Path= %cd%/magisktoemulator
SetLocal EnableDelayedExpansion
echo %tool_Path%/patch.bat
call %tool_Path%/patch.bat canary



copy  ramdisk.img %ramdisk_path%
ENDLOCAL
exit /B 0


:install_modules
SetLocal EnableDelayedExpansion
 echo %~1
 SetLocal EnableDelayedExpansion
	echo [-] Pushing All Modules placed in the Modules folder
	for %%i in (modules\*.zip) do (		
		set module=%%i
        for /f "delims=" %%A in ('adb push  !module!  /data/local/tmp 2^>^&1' ) do (
				echo [-] %%A
				)
			
			)
	goto :install_ma

	ENDLOCAL
exit /B 0


:install_ma
      set ADBWORKDIR=/data/data/com.android.shell

	SetLocal EnableDelayedExpansion
	echo [-] Install all Modules placed in the Apps folder
	adb shell "su -c 'for i in $(find /data/local/tmp -name '*.zip'); do magisk --install-module "$i"; done'"
						
	ENDLOCAL
	exit /B 0
