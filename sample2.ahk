#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Search image and click.

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

shades = 2

imageFile = img\explorer-PC.png
ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, % "*" shades A_Space A_ScriptDir "\" imageFile
If !ErrorLevel
  MouseClick LEFT, % FoundX + 10, % FoundY + 10
Else
  MsgBox, Not Found
