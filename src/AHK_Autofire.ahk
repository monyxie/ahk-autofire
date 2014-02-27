/*
  AHK AutoFire
  version: 0.1
  author: monyxie
  website: http://github.com/monyxie/ahk-autofire
  2014/2
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;Icon, ahk_autofire.ico

IniFile := "Settings.ini"
;AhkExe := "地下城与勇士"

IsOn := 0
ToggleKey := "Alt"
Interval := 20
Keys := "x"

; 若未存在配置文件则创建
IfNotExist, %IniFile%
    Gosub, SaveSettings
Else
    Gosub, ReadSettings

#IfWinActive, ahk_class 地下城与勇士
{
    Gosub, RegisterKeys
    TrayTip, AHK连发器已启动, 游戏内双击<%ToggleKey%>键开启连发。, 1
}
return

; subroutines ---

; 读取配置
ReadSettings:
IfExist, %IniFile%
{
    IniRead, ToggleKey, %IniFile%, Settings, ToggleKey
    IniRead, Interval, %IniFile%, Settings, Interval
    IniRead, Keys, %IniFile%, Settings, Keys
}
Return

; 保存配置
SaveSettings:
    IniWrite, %ToggleKey%, %IniFile%, Settings, ToggleKey
    IniWrite, %Interval%, %IniFile%, Settings, Interval
    IniWrite, %Keys%, %IniFile%, Settings, Keys
Return

; 开启/关闭
ToggleOnOff:
If ((A_PriorHotkey = A_ThisHotkey) AND (A_TimeSincePriorHotkey < 300))
{
    If (IsOn)
    {
          Loop, Parse, Keys, |
          {
              Hotkey, $%A_LoopField%, , Off
          }
          IsOn := 0
          ;TrayTip, AHK连发器, 连发已关闭。, 1
          ShowToolTip("连发已关闭")
    }
    Else
    {
          Loop, Parse, Keys, |
          {
            Hotkey, $%A_LoopField%, , On
          }
          IsOn := 1
            StringReplace, Keys4Display, Keys, |, %A_Space%, All
            StringUpper, Keys4Display, Keys4Display
          ;TrayTip, AHK连发器, 连发已开启。`n连发键：%Keys4Display%, 1
          ShowToolTip(Keys4Display . "键连发已开启")
    }
}
Return

; 注册连发键
RegisterKeys:
Loop, Parse, Keys, |
{
    Hotkey, $%A_LoopField%, Autofire, Off
}
Hotkey, %ToggleKey%, ToggleOnOff
Return

Autofire:
StringTrimLeft, KeyName, A_ThisHotKey, 1
Loop
{
    If Not GetKeyState(KeyName, "P")
        Break
        Send {%KeyName% Down}
    Sleep 20
        Send {%KeyName% Up}
    Sleep 20
}
Return

; 显示提示
ShowToolTip(text)
{
    WinGetPos, , , Width, Height, A
    ;X := Width/2-15
    X := 5/800*Width
    Y := 480/600*Height

    ToolTip, %text%, %X%, %Y%
    SetTimer, RemoveToolTip, 1000
    Return
}

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return
