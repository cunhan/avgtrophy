:start
set ffmpeg=E:\airu\youtube-dl\ffmpeg.exe
set txt="bulianglin.txt"
set txt_dedup="bulianglin_dedup.txt"
set txt64="bulianglin_64.txt"

del %txt%
REM del %txt_dedup%

REM 从频道主页获取直播链接
yt-dlp --skip-download --no-flat-playlist https://www.youtube.com/@bulianglin/streams | find "watch" > livelink.txt
set /p bulianglin_live=<livelink.txt
set bulianglin_live=%bulianglin_live:~26%

for /l %%i in (1 1 100) do (
	REM 使用streamlink抓取直播流，推给ffmpeg截图
	REM pip install streamlink
	streamlink -O %bulianglin_live% 720p | %ffmpeg% -i - -vframes 1 tmp.jpg

	REM 使用zbar识别截图里的二维码
	REM https://zbar.sourceforge.net/download.html
	"C:\Program Files (x86)\ZBar\bin\zbarimg.exe" -q --raw tmp.jpg >> %txt%
	rem echo %date%%time% >> bulianglin.txt
	rem echo +>> bulianglin.txt

	del tmp.jpg
	timeout -t 30
)

REM sort & dedup
sort %txt% /O %txt%

type nul>%txt_dedup%
setlocal enabledelayedexpansion
for /f "delims=" %%a in ('type %txt%') do (
      set s=%%a
      findstr !s:~0,180! %txt_dedup%>nul || echo %%a>>%txt_dedup%
)
setlocal disabledelayedexpansion

REM base64加密 https://github.com/RickStrahl/Base64
"%~dp0base64.exe" encode %txt_dedup% %txt64%

REM commit to github | https://git-scm.com/download/win
git add %txt64%
git commit -m "%date%%time%"
git push origin master

del %txt%
REM del %txt_dedup%
timeout -t 60
goto start
