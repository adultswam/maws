DetectHiddenWindows, On
SetTitleMatchMode, 2
AHKPath := "C:\Program Files (x86)\AutoHotkey\AutoHotkey.exe"
IfWinExist, maws.ahk
{
	Sleep, 300000
	FileDelete, %A_WorkingDir%\misc\pcomp.log
	FileAppend, %A_Now%, %A_WorkingDir%\misc\pcomp.log
	FileRead, LastPing, %A_WorkingDir%\misc\ping.log
	FileRead, PingComp, %A_WorkingDir%\misc\pcomp.log
	EnvSub, PingComp, LastPing
	If (PingComp <= 600000)
	{
		Reload
	}
	Else If (PingComp > 600000)
	{
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		IfWinExist, maws.ahk
		{
			FileRead, MawsPID, %A_WorkingDir%\misc\maws.pid
			Process, close, %MawsPID%
			Sleep, 1000
			Run, %AHKPath% %A_WorkingDir%\maws.ahk
			Reload
		}
		Else
		{
			ExitApp
		}
	}
}
Else
{
	ExitApp
}
