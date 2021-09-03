all: windows clear
love:
	zip -9 -r 2090.love .

win64: love
	cat ~/Downloads/love-11.2.0-win64/love.exe 2090.love > 2090.exe
	zip -j 2090win64.zip 2090.exe ~/Downloads/love-11.2.0-win64/*.dll ~/Downloads/love-11.2.0-win64/license.txt

clear:
	rm 2090.*

windows: win64
