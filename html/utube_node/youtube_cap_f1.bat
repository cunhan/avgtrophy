:start
CD /D "%~dp0"
set ffmpeg=ffmpeg.exe
set txt="bulianglin.txt"
set txt_dedup="bulianglin_dedup.txt"
set txt64="bulianglin_64.txt"

del %txt%
del %txt_dedup%

REM 从频道主页获取直播链接
del livelink.txt
yt-dlp --skip-download --no-flat-playlist https://www.youtube.com/@bulianglin/streams | find "watch" > livelink.txt
set /p bulianglin_live=<livelink.txt
set bulianglin_live=%bulianglin_live:~26%

del livelink.txt
yt-dlp --skip-download --no-flat-playlist https://www.youtube.com/@mac2win/streams | find "watch" > livelink.txt
set /p mac2win_live=<livelink.txt
set mac2win_live=%mac2win_live:~26%

for /l %%i in (1 1 100) do (
	REM 使用streamlink抓取直播流，推给ffmpeg截图
	REM pip install streamlink
	streamlink -O %bulianglin_live% 720p | %ffmpeg% -i - -vframes 1 tmp.jpg
	REM 使用zbar识别截图里的二维码
	REM https://zbar.sourceforge.net/download.html
	"C:\Program Files (x86)\ZBar\bin\zbarimg.exe" -q --raw tmp.jpg >> %txt%
	del tmp.jpg
	
	streamlink -O %mac2win_live% 720p | %ffmpeg% -i - -vframes 1 tmp.jpg
	"C:\Program Files (x86)\ZBar\bin\zbarimg.exe" -q --raw tmp.jpg >> %txt%
	del tmp.jpg
	
	timeout -t 30
)

REM sort & dedup
C:\Python38\Python.exe bll_dedup.py

REM base64加密 https://github.com/RickStrahl/Base64
"%~dp0base64.exe" encode %txt_dedup% %txt64%

REM commit to github | https://git-scm.com/download/win
git add %txt64%
git commit -m "%date%%time%"
git push origin master

del %txt%
del %txt_dedup%
timeout -t 60
goto start
