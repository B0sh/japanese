@echo off

FOR /R %%a IN (*.png) DO (
    magick convert "%%~a" "%%~dpna.jpg"
    DEL "%%~a"
)