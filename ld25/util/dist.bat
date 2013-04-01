mkdir ..\dist
cd ..\src
..\deps\7za a -tzip ..\dist\phaedra.love * ..\art
cd ..
cd deps
copy /b love.exe+..\dist\phaedra.love ..\dist\phaedra.exe
copy /b *.dll ..\dist\
cd ..\util
