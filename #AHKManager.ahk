; Copyright (c) 2020 ARAKI Makoto
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
; OR OTHER DEALINGS IN THE SOFTWARE.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoTrayIcon
#SingleInstance force


TargetDir = %A_ScriptDir%
IniFile = %A_ScriptDir%\.AHKManager.ini
IniRead, Editor, %IniFile%, core, editor, "notepad.exe"

Shortcuts := Object("F1", "", "F2", "", "F3", "", "F4", "", "F5", "", "F6", "", "F7", "", "F8", "", "F9", "", "F10", "", "F11", "", "F12", "", "^F1", "", "^F2", "", "^F3", "", "^F4", "", "^F5", "", "^F6", "", "^F7", "", "^F8", "", "^F9", "", "^F10", "", "^F11", "", "^F12", "")
Shortcut2int := Object("", 1, "F1", 2, "F2", 3, "F3", 4, "F4", 5, "F5", 6, "F6", 7, "F7", 8, "F8", 9, "F9", 10, "F10", 11, "F11", 12, "F12", 13, "^F1", 14, "^F2", 15, "^F3", 16, "^F4", 17, "^F5", 18, "^F6", 19, "^F7", 20, "^F8", 21, "^F9", 22, "^F10", 23, "^F11", 24, "^F12", 25)

; リスト一覧の作成
LV_CreateList()
{
  global TargetDir
  ; AHKファイルの一覧を作成する
  Loop, %TargetDir%\*.ahk
  {
    If InStr(A_LoopFileName, "#")  ;「#」を含むファイルは除外
      Continue
    LV_Add("", A_LoopFileName, "")
  }
}

; リストからファイル名を検索し、ショートカットの表示を変更する
LV_FindFileAndSetShortcut(SeachFile, Value)
{
  Loop, % LV_GetCount()
  {
    LV_GetText(_AHKFile, A_Index, 1)
    If Trim(_AHKFile) = Trim(SeachFile)
    {
      LV_Modify(A_Index, "Col2", Value)
      Break
    }
  }
}

; リストのショートカット設定を保存
LV_SaveShortcuts()
{
  global Shortcuts
  global IniFile
  For key, value in Shortcuts
  {
    If key = ""
      Continue
    ; iniファイルに設定を書き込む
    IniWrite, %value%, %IniFile%, shortcuts, %key%
  }
}

; リストのショートカット設定を復元
LV_LoadShortcuts()
{
  global Shortcuts
  global IniFile
  For key, value in Shortcuts
  {
    ; iniファイルから設定を復元する
    IniRead, SetFile, %IniFile%, shortcuts, %key%, ""
    Shortcuts[key] := SetFile
    LV_FindFileAndSetShortcut(SetFile, key)
  }
}

;=============================================
; GUIの設定
;=============================================
Gui, +AlwaysOnTop +Resize
Gui, Font, S8, Meiryo
Gui, Add, Text, w220, Select file and type "Shift + F1”
Gui, Add, Button, vMyReloadButton gMyReloadButton xm+180 y+-20, Reload
Gui, Add, DropDownList, vMyDropDown gMyDropDown w50 xm+230 y+-26, |F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|^F1|^F2|^F3|^F4|^F5|^F6|^F7|^F8|^F9|^F10|^F11|^F12
Gui, Add, ListView, vMyListView gMyListView xm-5 y+4 r14 AltSubmit, AHK File                                      |Shortcut
LV_CreateList()
LV_LoadShortcuts()
Gui, Show, NoActivate x0 y0, AHK Manager
Return

;---------------------------------------------
; Windowサイズ変更時
;---------------------------------------------
GUISize:
  ; ListViewのサイズ調整
  LV_width  := A_GuiWidth-12
  LV_height := A_GuiHeight-35
  GuiControl, move, MyListView, w%LV_width% h%LV_height%
  ; Reloadボタンの位置調整
  ReloadButton_x := A_GuiWidth-106 
  GuiControl, move, MyReloadButton, x%ReloadButton_x%
  ; DDLの位置調整
  DDL_x := A_GuiWidth-56
  GuiControl, move, MyDropDown, x%DDL_x%
  Return

;---------------------------------------------
; ListViewクリック・ダブルクリック時
;---------------------------------------------
MyListView:
  ; 項目未選択時は何もしない
  If !(SelectedRow := LV_GetNext())
    Return
  ; 項目クリック時はDDLにショートカット情報を反映するだけ
  If A_GuiControlEvent = Normal
  {
    LV_GetText(Shortcut, SelectedRow, 2)
    GuiControl, Choose, MyDropDown, % Shortcut2int[Shortcut]
    Return
  }
  ; 項目ダブルクリックのときはエディタを開く
  If A_GuiControlEvent = DoubleClick
  {
    LV_GetText(AHKFile, SelectedRow, 1)
    Run %Editor% %AHKFile%
    Return
  }
  Return

+F1:: ; Shift+F1押下時の処理
  ; 項目未選択時は何もしない
  If !(SelectedRow := LV_GetNext())
    Return
  ; AHKファイルの実行
  LV_GetText(AHKFile, SelectedRow, 1)
  Run, %TargetDir%\%AHKFile%,, UseErrorLevel
  If ErrorLevel = ERROR
    MsgBox Could not launch the specified file.  Perhaps it is not associated with anything.
  Return

;---------------------------------------------
; ショートカットの設定（ドロップダウンリスト選択時）
;---------------------------------------------
MyDropDown:
  ; ListView項目未選択時は何もしない
  If !(SelectedRow := LV_GetNext())
    Return
  ; 実行情報の初期化
  LV_GetText(Shortcut, SelectedRow, 2)
  Shortcuts[Shortcut] := ""
  ; ショートカットの変更
  GuiControlGet, OutputVar,, MyDropDown, text
  LV_Modify(SelectedRow, "Col2", OutputVar)  ; 表示部分の変更
  If OutputVar <> ""
  {
    ; すでに別AHKファイルが設定されているときは、元のをクリアする
    If Shortcuts[OutputVar] <> ""
      LV_FindFileAndSetShortcut(Shortcuts[OutputVar], "")
    ; 実行するAHKファイルの変更
    LV_GetText(AHKFile, SelectedRow, 1)
    Shortcuts[OutputVar] := AHKFile
  }
  Return

;---------------------------------------------
; Reloadボタンの処理
;---------------------------------------------
MyReloadButton:
LV_SaveShortcuts()
LV_Delete()
LV_CreateList()
LV_LoadShortcuts()
Return

;---------------------------------------------
; 終了時の処理
;---------------------------------------------
GuiClose:
LV_SaveShortcuts()
ExitApp

;=============================================
; ショートカット
;=============================================
; F1～F12
$F1::
$F2::
$F3::
$F4::
$F5::
$F6::
$F7::
$F8::
$F9::
$F10::
$F11::
$F12::
StringMid, ThisKey, A_ThisHotKey, 2
ThisHotKey := ThisKey
; ショートカット未登録時は、そのままキーを押下
If (Shortcuts[ThisHotKey] = "") {
  Send {%ThisKey%}
  Return
}
; ファイルが存在しないときも、そのままキーを押下
If (!FileExist(Shortcuts[ThisHotKey])) {
  Send {%ThisKey%}
  Return
}
; AHKファイル実行
Run, % TargetDir . "\" . Shortcuts[ThisHotKey],, UseErrorLevel
If ErrorLevel = ERROR
  MsgBox Could not launch the specified file.  Perhaps it is not associated with anything.
Return

; Ctrl+F1～F12
$^F1::
$^F2::
$^F3::
$^F4::
$^F5::
$^F6::
$^F7::
$^F8::
$^F9::
$^F10::
$^F11::
$^F12::
StringMid, ThisKey, A_ThisHotKey, 3
StringMid, ThisHotKey, A_ThisHotKey, 2
; ショートカット未登録時は、そのままキーを押下
If (Shortcuts[ThisHotKey] = "") {
  Send ^{%ThisKey%}
  Return
}
; ファイルが存在しないときも、そのままキーを押下
If (!FileExist(Shortcuts[ThisHotKey])) {
  Send ^{%ThisKey%}
  Return
}
; AHKファイル実行
Run, % TargetDir . "\" . Shortcuts[ThisHotKey],, UseErrorLevel
If ErrorLevel = ERROR
  MsgBox Could not launch the specified file.  Perhaps it is not associated with anything.
Return

; Capslock+F1～F12 (Need to change register)
~F13 & F1::
~F13 & F2::
~F13 & F3::
~F13 & F4::
~F13 & F5::
~F13 & F6::
~F13 & F7::
~F13 & F8::
~F13 & F9::
~F13 & F10::
~F13 & F11::
~F13 & F12::
StringMid, ThisKey, A_ThisHotKey, 8
ThisHotKey := "^" ThisKey
; ショートカット未登録時は、そのままキーを押下
If (Shortcuts[ThisHotKey] = "") {
  Send ^{%ThisKey%}
  Return
}
; ファイルが存在しないときも、そのままキーを押下
If (!FileExist(Shortcuts[ThisHotKey])) {
  Send ^{%ThisKey%}
  Return
}
; AHKファイル実行
Run, % TargetDir . "\" . Shortcuts[ThisHotKey],, UseErrorLevel
If ErrorLevel = ERROR
  MsgBox Could not launch the specified file.  Perhaps it is not associated with anything.
Return


; 再起動
^Esc::Reload
