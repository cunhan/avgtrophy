:start
set ffmpeg=E:\airu\youtube-dl\ffmpeg.exe
set txt="bulianglin.txt"
set txt64="bulianglin_64.txt"
del %txt%
REM ��Ƶ����ҳ��ȡֱ������
yt-dlp --skip-download --no-flat-playlist https://www.youtube.com/@bulianglin/streams | find "watch" > livelink.txt
set /p bulianglin_live=<livelink.txt
set bulianglin_live=%bulianglin_live:~26%

for /l %%i in (1 1 100) do (
	REM ʹ��streamlinkץȡֱ�������Ƹ�ffmpeg��ͼ
	REM pip install streamlink
	streamlink -O %bulianglin_live% 720p | %ffmpeg% -i - -vframes 1 tmp.jpg

	REM ʹ��zbarʶ���ͼ��Ķ�ά��
	REM https://zbar.sourceforge.net/download.html
	"C:\Program Files (x86)\ZBar\bin\zbarimg.exe" -q --raw tmp.jpg >> %txt%
	rem echo %date%%time% >> bulianglin.txt
	rem echo +>> bulianglin.txt

	del tmp.jpg
	timeout -t 30
)
rem keep links for 1hours
REM base64���� https://github.com/RickStrahl/Base64
"%~dp0base64.exe" encode %txt% %txt64%

REM commit to github
git add %txt64%
git commit -m "%date%%time%"
git push origin master

timeout -t 3600
goto start

REM ����ת��� https://github.com/tindy2013/subconverter/releases
REM https://127.0.0.1:25500/sub?target=clash&new_name=true&url=<�ڵ��б��ı�תurl����>&insert=false&config=<ini�ļ�����תurl����>