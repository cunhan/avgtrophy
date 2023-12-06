:start
set ffmpeg=E:\airu\youtube-dl\ffmpeg.exe
set txt="bulianglin.txt"
set txt64="bulianglin_64.txt"
del %txt%
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
rem keep links for 1hours
REM base64加密 https://github.com/RickStrahl/Base64
"%~dp0base64.exe" encode %txt% %txt64%

REM commit to github
git add %txt64%
git commit -m "%date%%time%"
git push origin master

timeout -t 3600
goto start

REM 订阅转换搭建 https://github.com/tindy2013/subconverter/releases
REM https://127.0.0.1:25500/sub?target=clash&new_name=true&url=<节点列表文本转url编码>&insert=false&config=<ini文件链接转url编码>