#SingleInstance ignore
DetectHiddenWindows, On
SetTitleMatchMode, 2
IfWinExist, maws.ahk
{
	FileRead, HypeInt, %A_WorkingDir%\misc\hype.status
	If (HypeInt <= 6)
	{
		Sleep, 300000
		Return
	}
	Else If (HypeInt > 6 and HypeInt < 69)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 300000
		Return
	}
	Else If (HypeInt > 69 and HypeInt < 139)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 240000
		Return
	}
	Else If (HypeInt > 139 and HypeInt < 209)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 180000
		Return
	}
	Else If (HypeInt > 209 and HypeInt < 279)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 160000
		Return
	}
	Else If (HypeInt > 279 and HypeInt < 349)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 140000
		Return
	}
	Else If (HypeInt > 349 and HypeInt < 419)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 120000
		Return
	}
	Else If (HypeInt > 419 and HypeInt < 489)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 100000
		Return
	}
	Else If (HypeInt > 489 and HypeInt < 559)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 50000
		Return
	}
	Else If (HypeInt > 559 and HypeInt < 629)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 25000
		Return
	}
	Else If (HypeInt > 629 and HypeInt < 699)
	{
		EnvSub, HypeInt, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeInt%, %A_WorkingDir%\misc\hype.status
		Sleep, 5000
		Return
	}
	Else If (HypeInt > 699)
	{
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, 1, %A_WorkingDir%\misc\hype.status
		FileRead, MawsPID, %A_WorkingDir%\misc\maws.pid
		Process, close, %MawsPID%
		ExitApp
	}
}
Else
{
	ExitApp
}
