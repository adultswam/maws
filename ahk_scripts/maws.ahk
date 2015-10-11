#Include WinSock2.ahk ; DerRaphael's WinSock2 Library - http://www.autohotkey.com/forum/topic35575.html
#Include HTTPRequest.ahk
SetKeyDelay, 100, 100
myPID := DllCall("GetCurrentProcessId")
FileDelete, %A_WorkingDir%\misc\maws.pid
FileAppend, %A_WorkingDir%\misc\%myPID%, maws.pid
AHKPath := "C:\Program Files (x86)\AutoHotkey\AutoHotkey.exe" ; Requires AutoHotKey "legacy" version 1.0.48.05 - http://www.autohotkey.com/download/AutoHotkey104805_Install.exe
NirPath := "C:\dev\nircmd\nircmd.exe" ; Requires nircmd any version
MPVPath := "C:\dev\mpv\mpv.exe" ; Requires MPV any version
VLCPath := "C:\Program Files\VideoLAN\VLC\vlc.exe" ; Requires VLC version 2.0.1 or higher
MpyPath := "C:\util\mplayer\mplayer.exe" ; Requires MPlayer any version
Server  := "irc.rizon.net"
Port    := "6667"
Channel := "#/tv/shows"
Nick    := "mews"
Pass    := "bananarama"
Email   := "tukyo"
Massah  := "swem!~swum@suguku.urushuu.nu"

If (!Socket := WS2_Connect(Connection := Server . ":" . Port))
{
   MsgBox, 16, Error!, An error occured while connecting to %Connection%
}

	WS2_AsyncSelect(Socket, "DataProcess")
	WS2_SendData(Socket, "USER " . Email . " google.com MAWS :" . Nick . "`n")
	WS2_SendData(Socket, "NICK " . Nick . "`n")
	WS2_SendData(Socket, "NICKSERV :identify " . Pass . "`n")
	Return

DataProcess(Socket, Data)
{
	global AHKPath,NirPath,MPVPath,VLCPath,MpyPath,Server,Port,Channel,Nick,Pass,Email,Massah,Name,Hostmask,Phrase,VidPath,Chnum,Chwat,WebmURL,WobmURL,LogData
	StringSplit, Param, Data, %A_Space%
	Name := SubStr(Data, 2, InStr(Data, "!")-2)
	Hostmask := SubStr(Data, InStr(Data, "@")+1, (InStr(Data, " "))-(InStr(Data, "@"))-1)
	VidPath := SubStr(Data, InStr(Data, "!play")+6)
	Chnum := SubStr(Data, InStr(Data, "!goto")+6)
	Chwat := SubStr(Data, InStr(Data, "!whatson")+9)
	Jword := SubStr(Data, InStr(Data, Channel . " :.j")+11)
	WebmURL := SubStr(Data, InStr(Data, "http"), (InStr(Data, ".webm")-InStr(Data, "http")+5))
	GifmURL := SubStr(Data, InStr(Data, "http"), (InStr(Data, ".gif")-InStr(Data, "http")+4))
	LogData := SubStr(Data, 1)

	FileAppend, %LogData%, %A_WorkingDir%\misc\bot.log
	FileRead, IgnoredNiggas, %A_WorkingDir%\misc\ignoredhosts.list

	If (Param1 == "PING")
	{
		FileRead, PingStat, %A_WorkingDir%\misc\pings.status
		If (PingStat = 0)
		{
			Return
		}
		Else If (PingStat = 1)
		{
			WS2_SendData(Socket, "PONG " . Param2 . "`n")
			FileDelete, %A_WorkingDir%\misc\ping.log
			FileAppend, %A_Now%, %A_WorkingDir%\misc\ping.log
			Run, %AHKPath% %A_WorkingDir%\HypeCheck.ahk
			DetectHiddenWindows, On
			SetTitleMatchMode, 2
			IfWinNotExist, PingCheck.ahk
			{
				Run, %AHKPath% %A_WorkingDir%\PingCheck.ahk
				Return
			}
			Else
			{
				Return
			}
			Return
		}
	}
	Else If (RegExMatch(Data, ":" . Massah . " PRIVMSG " . Nick . " !reload"))
	{
		Reload
	}
	Else If (RegExMatch(Data, ":" . Massah . " PRIVMSG " . Channel . " !reload"))
	{
		Reload
	}
	Else If (RegExMatch(Data, "ERROR Closing Link"))
	{
		Reload
	}
	Else If (RegExMatch(Data, ":.*!.*@.NOTICE " . Nick . " :please choose a different nick."))
	{
		Sleep, 500
		WS2_SendData(Socket, "NICKSERV :identify " . Pass . "`n")
		Return
	}
	Else If (RegExMatch(Data, ":.*!.*@.NOTICE " . Nick . " :Password accepted - you are now recognized."))
	{
		Sleep, 500
		WS2_SendData(Socket, "JOIN " . Channel . "`n")
		Return
	}
	Else If (RegExMatch(Data, ":.*!.*@.NOTICE " . Nick . " :You are already identified."))
	{
		Sleep, 500
		WS2_SendData(Socket, "JOIN " . Channel . "`n")
		Return
	}
	Else If (RegExMatch(Data, ":.*!.*@.KICK " . Channel . " " . Nick . " :"))
	{
		Sleep, 1500
		WS2_SendData(Socket, "JOIN " . Channel . "`n")
		Return
	}
	Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!swag"))
	{
		WS2_SendData(Socket, "KICK " . Channel . " " . Name . " :swag swag muthafucka`n")
		Return
	}
	Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!hype"))
	{
		FileRead, HypeUser, %A_WorkingDir%\misc\hype.user
		If (Name = HypeUser)
		{
			FileRead, HypeTimer, %A_WorkingDir%\misc\hype.timer
			EnvSub, HypeTimer, A_Now
			If (HypeTimer > -30)
			{
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :sod off hype nigger`n")
				Return
			}
			Else If (HypeTimer <= -60)
			{
				Goto, HypeIsValid
			}
		}
		Else If (Name != HypeUser)
		{
			Goto, HypeIsValid
		}
		HypeIsValid:
		FileDelete, %A_WorkingDir%\misc\hype.user
		FileAppend, %Name%, %A_WorkingDir%\misc\hype.user
		FileDelete, %A_WorkingDir%\misc\hype.timer
		FileAppend, %A_Now%, %A_WorkingDir%\misc\hype.timer
		FileRead, HypeLevel, %A_WorkingDir%\misc\hype.status
		EnvAdd, HypeLevel, 1
		FileDelete, %A_WorkingDir%\misc\hype.status
		FileAppend, %HypeLevel%, %A_WorkingDir%\misc\hype.status
		WS2_SendData(Socket, "NOTICE " . Name . " :hype registered`n")
		Return
	}
	Else If (RegExMatch(Data, "i)PRIVMSG " . Channel . " :" . Nick . " what does the scouter say about our hype level"))
	{
		FileRead, HypeQuery, %A_WorkingDir%\misc\hype.status
		EnvDiv, HypeQuery, 7
		WS2_SendData(Socket, "PRIVMSG " . Channel . " :it's at " . HypeQuery . "`%`n")
		Return
	}
	Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :" . Nick . " ignore "))
	{
		If (RegExMatch(IgnoredNiggas, Hostmask))
		{
			WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
			Return
		}
		Else
		{
			IgnoreName := SubStr(Data, InStr(Data, ":" . Nick . " ignore ")+13)
			StringReplace, IgnoreName, IgnoreName, `r`n, , All
			StringReplace, IgnoreName, IgnoreName, %A_Space%, , All
			If (IgnoreName = %Massah%) OR (IgnoreName = %Nick%)
			{
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :n-no...`n")
				Return
			}
			Else
			{
				WS2_SendData(Socket, "WHOIS " . IgnoreName . "`n")
				FileAppend, 1, %A_WorkingDir%\misc\whois.status
				Return
			}
		}
	}
	Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :" . Nick . " unignore "))
	{
		If (RegExMatch(IgnoredNiggas, Hostmask))
		{
			WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
			Return
		}
		Else
		{
			UnignoreName := SubStr(Data, InStr(Data, ":" . Nick . " unignore ")+15)
			WS2_SendData(Socket, "WHOIS " . UnignoreName . "`n")
			FileAppend, 2, %A_WorkingDir%\misc\whois.status
			Return
		}
	}
	Else If (RegExMatch(Data, " 311 " . Nick . " "))
	{
		IfNotExist, %A_WorkingDir%\misc\whois.status
		{
			Return
		}
		Else IfExist, %A_WorkingDir%\misc\whois.status
		{
			FileRead, WhoisStatus, %A_WorkingDir%\misc\whois.status
			FileDelete, %A_WorkingDir%\misc\whois.status
			If (WhoisStatus = 1)
			{
				StringReplace, WhoisDelim, Data, %A_SPACE%, `n, All
				FileAppend, %WhoisDelim%, %A_WorkingDir%\misc\whois.status
				FileReadLine, IgnoreHost, %A_WorkingDir%\misc\whois.status, 6
				FileDelete, %A_WorkingDir%\misc\whois.status
				FileRead, HostQuery, %A_WorkingDir%\misc\ignoredhosts.list
				MatchHost := RegExMatch(HostQuery, IgnoreHost)
				If (MatchHost = 0)
				{
					FileAppend, %IgnoreHost%%A_SPACE%, %A_WorkingDir%\misc\ignoredhosts.list
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :O' Cap'n my Cap'n!`n")
					Return
				}
				Else If (MatchHost != 0)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :already ignored`n")
					Return
				}
			}
			Else If (WhoisStatus = 2)
			{
				StringReplace, WhoisDelim, Data, %A_SPACE%, `n, All
				FileAppend, %WhoisDelim%, %A_WorkingDir%\misc\whois.status
				FileReadLine, UnignoreHost, %A_WorkingDir%\misc\whois.status, 6
				FileDelete, %A_WorkingDir%\misc\whois.status
				FileRead, HostQuery, %A_WorkingDir%\misc\ignoredhosts.list
				MatchHost := RegExMatch(HostQuery, UnignoreHost)
				If (MatchHost = 0)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :ain't ignored`n")
					Return
				}
				Else If (MatchHost != 0)
				{
					StringReplace, IgnoreList, HostQuery, %UnignoreHost%%A_SPACE%, , All
					FileDelete, %A_WorkingDir%\misc\ignoredhosts.list
					FileAppend, %IgnoreList%, %A_WorkingDir%\misc\ignoredhosts.list
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :Sir yes Sir!`n")
					Return
				}
			}
		}
	}
	Else If (RegExMatch(Data, " 401 " . Nick . " "))
	{
		IfNotExist, %A_WorkingDir%\misc\whois.status
		{
			Return
		}
		Else IfExist, %A_WorkingDir%\misc\whois.status
		{
			FileDelete, %A_WorkingDir%\misc\whois.status
			WS2_SendData(Socket, "PRIVMSG " . Channel . " :man u dum`n")
			Return
		}
	}
	Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!durn"))
	{
		IfNotExist, %A_WorkingDir%\misc\durns.time
		{
			FileAppend, %A_Now%, %A_WorkingDir%\misc\durns.time
			WS2_SendData(Socket, "KICK " . Channel . " " . Name . " :no durns here massah`n")
			Return
		}
		Else IfExist, %A_WorkingDir%\misc\durns.time
		{
			FileRead, LastTimeWas , %A_WorkingDir%\misc\durns.time
			EnvSub, LastTimeWas, A_Now
			If (LastTimeWas > -60)
			{
				WS2_SendData(Socket, "KICK " . Channel . " " . Name . " :no durns here massah`n")
				Return
			}
			Else If (LastTimeWas <= -60)
			{
				FileDelete, %A_WorkingDir%\misc\durns.time
				FileAppend, %A_Now%, %A_WorkingDir%\misc\durns.time
				WS2_SendData(Socket, "MODE " . Channel . " +b *!*@*`n")
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░░░░░░▄▄████████▄▄`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░░░▄▄███████████████▄`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░▄████████████████████▄`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :▐███▀▌░█▀█▌▄░▀▌▀▀▐▀█████▄`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :██▓▓▒▒▀░▒▐▒▒▒▒▒▌▒▌▒▒▐████▌ Wow`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :██▓▒▒▄▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐████`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :█▌▓▒▀████▄▒▒▒▒▄███▄▄▒▒████▌`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :█▌▓▒▄▀█▄▒▒▒▒▒▓▄▀█▄▄▓▒▒████▌`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :▐▓▒▒▒▒▀▒▒░░▒▒▒▓▓▀▄▒▒▒▒████`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :▐▓▒▒▒▒▒▒▐░░░▒▒▒░░░░▒▒▒▌▄▓▐`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :▐▓▒▒▒▒▒▌▄░▄▄▐▒▒▒░░▒▒▒▒▌▀▒▌ Such`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░█▒▒▒▒▄██████▄▄▒▒▒▒▒▒▐█░▌`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░██▒▒██▌▄▄▄▄▄▄▐█▒▒▒▒███▀`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░███▒█▒▒▒▄▄▄▒▒▒█▒█████▌`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░▐████▄▒▒▒█▒▒▒▒▄▄█████ Durns`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░░▀██████████████████▌`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :░░░░▐██████████████▀▒▌`n")
				Sleep, 775
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :▄▄██▌▒▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▐██▄▄`n")
				WS2_SendData(Socket, "MODE " . Channel . " -b *!*@*`n")
				Return
			}
		}
	}
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :le "))
   {
	  WS2_SendData(Socket, "KICK " . Channel . " " . Name . " :gb2 le reddit fuckface`n")
	  Return
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :Le "))
   {
	  WS2_SendData(Socket, "KICK " . Channel . " " . Name . " :gb2 le reddit fuckface`n")
	  Return
   }
   Else If (RegExMatch(Data, "\Q:" . Massah . " PRIVMSG " . Nick . " :!pings on\E"))
   {
		 FileDelete, %A_WorkingDir%\misc\pings.status
		 FileAppend, 1, %A_WorkingDir%\misc\pings.status
		 Return
   }
   Else If (RegExMatch(Data, "\Q:" . Massah . " PRIVMSG " . Nick . " :!pings off\E"))
   {
		 FileDelete, %A_WorkingDir%\misc\pings.status
		 FileAppend, 0, %A_WorkingDir%\misc\pings.status
		 Return
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!commands on"))
   {
		 FileDelete, %A_WorkingDir%\misc\commands.status
		 FileAppend, 1, %A_WorkingDir%\misc\commands.status
		 GoSub, ComGoSTATUS
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!commands off"))
   {
		 FileDelete, %A_WorkingDir%\misc\commands.status
		 FileAppend, 0, %A_WorkingDir%\misc\commands.status
		 GoSub, ComGoSTATUS
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!clips on"))
   {
		 FileDelete, %A_WorkingDir%\misc\clips.status
		 FileAppend, 1, %A_WorkingDir%\misc\clips.status
		 GoSub, ComGoSTATUS
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!clips off"))
   {
		 FileDelete, %A_WorkingDir%\misc\clips.status
		 FileAppend, 0, %A_WorkingDir%\misc\clips.status
		 GoSub, ComGoSTATUS
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!webms on"))
   {
		 FileDelete, %A_WorkingDir%\misc\webms.status
		 FileAppend, 1, %A_WorkingDir%\misc\webms.status
		 GoSub, ComGoSTATUS
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!webms off"))
   {
		 FileDelete, %A_WorkingDir%\misc\webms.status
		 FileAppend, 0, %A_WorkingDir%\misc\webms.status
		 GoSub, ComGoSTATUS
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!status"))
   {
	 GoSub, ComGoSTATUS
   }
   Else If (RegExMatch(Data, "i)PRIVMSG " . Channel . " :!HAMMER"))
   {
      WS2_SendData(Socket, "MODE " . Channel . " +b " . Name . "`n")
	  WS2_SendData(Socket, "KICK " . Channel . " " . Name . " :ヽ( ﾟヮ・)ノ.･ﾟ*｡･+☆ IT'S B&HAMMER TIME!`n")
      Return
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!do mute"))
   {
	 FileRead, CommStatus, %A_WorkingDir%\misc\commands.status
	 If (CommStatus = 0)
	 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :( ¯3¯) I'm afraid I can't let you do that, Dave.`n")
		 Return
	 }
	 Else If (RegExMatch(IgnoredNiggas, Hostmask))
	 {
		WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
		Return
	 }
	 Else If (CommStatus = 1)
	 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Command activated.`n")
		 Run, %NirPath% muteappvolume SlingFront.exe 1
		 Return
	  }
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!do unmute"))
   {
	 FileRead, CommStatus, %A_WorkingDir%\misc\commands.status
	 If (CommStatus = 0)
	 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :( ¯3¯) I'm afraid I can't let you do that, Dave.`n")
		 Return
	 }
	 Else If (RegExMatch(IgnoredNiggas, Hostmask))
	 {
		WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
		Return
	 }
	 Else If (CommStatus = 1)
	 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Command activated.`n")
		 Run, %NirPath% muteappvolume SlingFront.exe 0
		 Return
	  }
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!steaminfo"))
   {
	  WS2_SendData(Socket, "KICK " . Channel . " " . Name . " :12http://store.steampowered.com/app/24010/`n")
	  Return
   }
   Else If (RegExMatch(Data, "PRIVMSG " . Channel . " :!list"))
   {
	  WS2_SendData(Socket, "PRIVMSG " . Channel . " :12http://a.sugoi.space/channels.txt`n")
	  Return
   }
   Else If (RegExMatch(Data, ":.*!.*@.*PRIVMSG " . Channel . " :!do"))
   {
	 FileRead, CommStatus, %A_WorkingDir%\misc\commands.status
	 If (CommStatus = 0)
	 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :( ¯3¯) I'm afraid I can't let you do that, Dave.`n")
		 Return
	 }
	 Else If (RegExMatch(IgnoredNiggas, Hostmask))
	 {
		WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
		Return
	 }
	 Else If (CommStatus = 1)
	 {
      StringReplace, Command, Param5, % Chr(10),, All
      StringReplace, Command, Command, % Chr(13),, All
      If (!Command)
      {
         WS2_SendData(Socket, "PRIVMSG " . Channel . " :WHATA FUCK MAN xD`n")
         Return
      }
      Else If (Command = "hi")
      {
         WS2_SendData(Socket, "PRIVMSG " . Channel . " :WHATA FUCK MAN xD i just fall of my chair kuz i couldnt and i CANT stop laugh xDXDXDXDXDDDDDDDDDDDDDXXXXXXXXXXXXXXXXXXXDDDDDDDDDDDDDDDDDDD OMGOSH DDDDDXXXXXXXXXXXXXXXXXXXXXXXDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD DDDDDD LOOOOOOOOOLLLLL THIS IS A SHIT XDDDDDDDDDDDDDDDDDDDDXDDDDDDDDDDDDDDDDDDDDD A BIG ONE XDDDDDDDD A GRAT ONE XXXXXXDDDD CONGRATS MAN XD`n")
         Return
      }
      Else If (Command = "info")
      {
         WS2_SendData(Socket, "NOTICE " . Name . " :Command activated.`n")
		 WinWait, Form1, 
		 IfWinNotActive, Form1, , WinActivate, Form1, 
		 WinWaitActive, Form1, 
		 Send, i
         Return
      }
	 }
	}
   Else If (RegExMatch(Data, ":.*!.*@.*PRIVMSG " . Channel . " :!goto"))
   {
	 FileRead, CommStatus, %A_WorkingDir%\misc\commands.status
	 If (CommStatus = 0)
	 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :( ¯3¯) I'm afraid I can't let you do that, Dave.`n")
		 Return
	 }
	 Else If (RegExMatch(IgnoredNiggas, Hostmask))
	 {
		WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
		Return
	 }
	 Else If (CommStatus = 1)
	 {
      StringReplace, Command, Param5, % Chr(10),, All
      StringReplace, Command, Command, % Chr(13),, All
      If (!Command)
      {
         WS2_SendData(Socket, "PRIVMSG " . Channel . " :WHATA FUCK MAN xD`n")
         Return
      }
      Else If (Command = "burgertv")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "JAP") {
		 Run, taskkill /im slingfront.exe
		 Sleep, 800
		 FileDelete, %A_WorkingDir%\misc\chanlocale.txt
		 FileAppend, USA, %A_WorkingDir%\misc\chanlocale.txt
		 FileDelete, C:\Users\Owner\AppData\Roaming\SlingFront\Internal.ini
		 FileDelete, C:\Users\Owner\AppData\Roaming\SlingFront\Settings.ini
		 FileRead, ChanInt, %A_WorkingDir%\misc\intUSA.txt
		 FileRead, ChanSet, %A_WorkingDir%\misc\setUSA.txt
		 FileAppend, %ChanInt%, C:\Users\Owner\AppData\Roaming\SlingFront\Internal.ini
		 FileAppend, %ChanSet%, C:\Users\Owner\AppData\Roaming\SlingFront\Settings.ini
		 Sleep, 800
		 Run, %NirPath% script "slingfront_win.ncl"
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :⊂二二二（　＾ω＾）二⊃ moshi moshi burger dess.`n")
		 Sleep, 8000
		 WinWait, Form1, 
		 IfWinNotActive, Form1, , WinActivate, Form1, 
		 WinWaitActive, Form1, 
		 Send, {ENTER}{ENTER}
		 Return
		 }
		 Else If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :wut`n")
		 Return
		 }
      }
      Else If (Command = "pantsutv")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 Run, taskkill /im slingfront.exe
		 Sleep, 800
		 FileDelete, %A_WorkingDir%\misc\chanlocale.txt
		 FileAppend, JAP, %A_WorkingDir%\misc\chanlocale.txt
		 FileDelete, C:\Users\Owner\AppData\Roaming\SlingFront\Internal.ini
		 FileDelete, C:\Users\Owner\AppData\Roaming\SlingFront\Settings.ini
		 FileRead, ChanInt, %A_WorkingDir%\misc\intJAP.txt
		 FileRead, ChanSet, %A_WorkingDir%\misc\setJAP.txt
		 FileAppend, %ChanInt%, C:\Users\Owner\AppData\Roaming\SlingFront\Internal.ini
		 FileAppend, %ChanSet%, C:\Users\Owner\AppData\Roaming\SlingFront\Settings.ini
		 Sleep, 800
		 Run, %NirPath% script "slingfront_win.ncl"
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :⊂二（＾ω＾　）二二二⊃ moshi moshi kimono dess.`n")
		 Sleep, 5000
		 WinWait, Form1, 
		 IfWinNotActive, Form1, , WinActivate, Form1, 
		 WinWaitActive, Form1, 
		 Return
		 }
		 Else If (ChanLocale = "JAP") {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :noni`n")
		 Return
		 }
      }
      Else If (Command = "cbs")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
		 WinWait, Form1, 
		 IfWinNotActive, Form1, , WinActivate, Form1, 
		 WinWaitActive, Form1, 
		 Send, 2{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nbc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
		 WinWait, Form1, 
		 IfWinNotActive, Form1, , WinActivate, Form1, 
		 WinWaitActive, Form1, 
		 Send, 4{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "ion")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 3{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "fox")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 5{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "univision")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 6{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "abc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 7{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "ny1n")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 8{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "my9")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 9{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wlyn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 10{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cw")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 11{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "news12")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 12{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "pbs")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 13{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "qvc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 15{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "telemundo")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 16{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "unimas")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 17{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hsn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 18{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wrnn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 19{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wmbc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 20{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wliw")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 21{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nyclife")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 22{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "msnbc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 23{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cnbc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 24{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cnn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 25{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "foxnews")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 26{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "discovery")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 27{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "tlc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 28{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "mundofox")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 29{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "thenet")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 30{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "disney")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 31{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 32{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "boomerang")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 129{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "tvland")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 34{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "espn2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 35{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "espn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 36{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "tnt")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 37{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "usa")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 38{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "tbs")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 39{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "fx")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 40{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "tcm")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 41{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wetv")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 42{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "amc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 43{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bravo")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 44{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "lifetime")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 45{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "ae")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 46{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "history")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 47{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "syfy")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 48{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "abcfam")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 49{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "comedy")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 50{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "e")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 51{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "vh1")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 52{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "mtv")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 53{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bet")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 54{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "mtv2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 55{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "spike")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 56{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "animal")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 57{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "tru")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 58{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "religion")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 59{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "sportsnet")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 60{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "weather")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 62{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "esquire")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 64{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cspan")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 65{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wnyj")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 66{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bcat1")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 67{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bcat2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 68{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bcat3")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 69{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bcat4")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 70{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "otb")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 71{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nycdrive")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 72{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nycworld")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 73{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nycgov")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 74{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cuny")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 75{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cnnhead")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 77{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "fuse")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 78{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "oxygen")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 81{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "ifc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 83{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "msg")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 87{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "msg+")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 88{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "yes")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 89{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "sportsover")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 90{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hsn2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 3{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "buzzr")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 95{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "travel")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 96{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "food")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 97{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hgtv")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 98{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "foxsport1")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 99{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bbcusa")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 101{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cspan3")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 102{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "euronews")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 103{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bbcnews")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 104{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "bloomberg")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 105{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "foxbiz")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 106{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "laff")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 108{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cozi")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 109{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "thistv")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 111{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "decades")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 112{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "movies")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 113{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "antenna")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 114{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cspan2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 115{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nyslaw")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 116{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "world")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 117{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "public")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 118{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "disfam")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 120{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nick")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 121{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nicktoons")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 122{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nickjr")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 123{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "teennick")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 124{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "disneyjr")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 126{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "sprout")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 130{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wworld")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 132{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "wcreate")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 133{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "trinity")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 134{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "ewtn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 135{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "daystar")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 136{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "telecare")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 137{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "jews")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 138{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "velocity")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 150{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "universal")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 151{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "crime")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 152{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "palladia")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 153{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "fusion")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 156{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "blaze")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 157{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "natwild")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 158{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "fxx")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 159{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "fyi")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 160{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "h2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 161{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "natgeo")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 162{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "smith")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 163{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "zliv")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 164{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "classart")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 165{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cooking")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 166{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "diy")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 167{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "chiller")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 168{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cloo")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 169{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "science")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 170{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "indisc")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 171{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "desusa")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 172{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "usahero")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 173{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "lmn")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 174{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "up")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 175{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "aspire")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 176{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "logo")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 179{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "tvone")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 178{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "reelz")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 177{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "own")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 180{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "evine")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 181{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "jewelry")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 182{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "qvc+")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 183{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "greatusa")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 184{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "centric")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 185{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "vh1class")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 186{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "cmt")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 187{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "mtvhits")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 188{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "vh1soul")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 189{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "fxmovie")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 190{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hallmark")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 191{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "sundance")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 192{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hallmovie")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 193{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "ny1en")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 194{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "mtv3")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 195{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "nbcen")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 197{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "gala")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 198{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "vme")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 199{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "mlb")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 222{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "golf")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 224{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "sportman")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 242{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbo")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 301{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbo2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 302{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbocom")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 303{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbozone")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 304{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbolat")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 305{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbowest")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 306{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbosig")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 310{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "hbofam")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 311{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "showtime")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 321{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "showtime2")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 322{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "showbeyond")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 323{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "shownext")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 324{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "showfam")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 325{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "showgirls")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 326{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "showextreme")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 331{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "encore")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 351{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "encoresus")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 352{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "encorecow")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 353{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "encoreclass")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 354{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "encoreblack")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 355{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "encorefam")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 356{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else If (Command = "encorepow")
      {
         FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
		 If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
                 WinWait, Form1,
                 IfWinNotActive, Form1, , WinActivate, Form1,
                 WinWaitActive, Form1,
                 Send, 358{ENTER}
         Return
		 }
		 Else If (ChanLocale = "JAP")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
      }
      Else if Command is digit
      {
         If Command between 200 and 999
		 {
			FileRead, ChanLocale, %A_WorkingDir%\misc\chanlocale.txt
			If (ChanLocale = "JAP") {
			WS2_SendData(Socket, "NOTICE " . Name . " :Station entry activated.`n")
			WinActivate, Form1
			Send, %Chnum%{ENTER}
			Return
		 }
		 Else If (ChanLocale = "USA")
		 {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Wrong tuner`n")
		 Return
		 }
		 }
      }
	 }
	}
   Else If (RegExMatch(Data, ":.*!.*@.*PRIVMSG " . Channel . " :!play"))
   {
      StringReplace, Command, Param5, % Chr(10),, All
      StringReplace, Command, Command, % Chr(13),, All
      FileRead, ClipStat, %A_WorkingDir%\misc\clips.status
	  If (ClipStat = 0)
	  {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :( ` - ´) enjoy your no .y`n")
		 Return
	  }
	  Else If (RegExMatch(IgnoredNiggas, Hostmask))
	  {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
		 Return
	  }
	  Else If (ClipStat = 1)
	  {
		 If (!Command)
	      {
	         WS2_SendData(Socket, "PRIVMSG swam :wut`n")
	         Return
	      }
		  Else If (Command != "dontplaythis")
	      {
		   FileRead, ClipPlaying, %A_WorkingDir%\misc\playing.status
		   If (ClipPlaying = 0)
		    {
	         StringReplace, VidPath, VidPath, `n, , All
			 StringReplace, VidPath, VidPath, `r, , All
			 Run, %MPVPath% %VidPath%
			 Run, %AHKPath% %A_WorkingDir%\VidProcPL.ahk
	         Return
			}
		  Else If (ClipPlaying = 1)
		    {
			  WS2_SendData(Socket, "PRIVMSG " . Channel . " :Already playing something. Wait or !wipe`n")
			  Return
			}
	      }
	  }
   }
   Else If (RegExMatch(Data, "i)PRIVMSG " . Channel . " :#sugoi"))
   {
	  FileRead, ClipStat, %A_WorkingDir%\misc\clips.status
	  If (ClipStat = 0)
	  {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :( ´ _ `) m-muh clips...`n")
		 Return
	  }
	  Else If (RegExMatch(IgnoredNiggas, Hostmask))
	  {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
		 Return
	  }
	  Else If (ClipStat = 1)
	  {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :SUGOI ヽ( ⌒o⌒)ノ`n")
		 Run, %VLCPath% %A_WorkingDir%\clips\sugoi.mp4
		 Return
	  }
   }
   Else If (RegExMatch(Data, "i)PRIVMSG " . Channel . " :")) AND (RegExMatch(Data, "i)http")) AND (RegExMatch(Data, ".webm"))
   {
      FileRead, WebmStat, %A_WorkingDir%\misc\webms.status
	  If (WebmStat = 0)
	  {
		 Return
	  }
	  Else If (RegExMatch(IgnoredNiggas, Hostmask))
	  {
		 Return
	  }
	  Else If (WebmStat = 1)
	  {
		 StringReplace, WebmURL, WebmURL, https, http, All
		 IfNotInString, WebmURL, %A_Space%
		 {
			IfNotExist, %A_WorkingDir%\misc\webms.wait
			{
				WebmTitle := WebmURL . A_TickCount
				Run, %MpyPath% -title %WebmTitle% -noborder -vo gl_tiled -xy 500 %WebmURL%
				Run, %AHKPath% %A_WorkingDir%\VidProcMP.ahk %WebmTitle%
				Return
			}
		 }
      }
   }
   Else If (RegExMatch(Data, "i)PRIVMSG " . Channel . " :")) AND (RegExMatch(Data, "i)http")) AND (RegExMatch(Data, ".gif"))
   {
      FileRead, WebmStat, %A_WorkingDir%\misc\webms.status
	  If (WebmStat = 0)
	  {
		 Return
	  }
	  Else If (RegExMatch(IgnoredNiggas, Hostmask))
	  {
		 Return
	  }
	  Else If (WebmStat = 1)
	  {
		 StringReplace, GifmURL, GifmURL, https, http, All
		 IfNotInString, GifmURL, %A_Space%
		 {
			IfNotExist, %A_WorkingDir%\misc\webms.wait
			{
				GifmTitle := GifmURL . A_TickCount
				Run, %MpyPath% -title %GifmTitle% -noborder -vo gl_tiled -xy 500 %GifmURL%
				Run, %AHKPath% %A_WorkingDir%\VidProcMP.ahk %GifmTitle%
				Return
			}
		 }
      }
   }
   Else If (RegExMatch(Data, "i)PRIVMSG " . Channel . " :!wipe"))
   {
      FileRead, WebmStat, %A_WorkingDir%\misc\webms.status
	  If (WebmStat = 0)
	  {
		 Return
	  }
	  Else If (RegExMatch(IgnoredNiggas, Hostmask))
	  {
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :naw`n")
		 Return
	  }
	  Else If (WebmStat = 1)
	  {
		 GroupAdd, AnyMPlayerWindow, ahk_class MPlayer - The Movie Player
		 WinClose, ahk_group AnyMPlayerWindow
		 Sleep, 100
		 GroupAdd, AnyMPlayerCLI, MpyPath
		 WinClose, ahk_group AnyMPlayerCLI
		 Sleep, 100
		 GroupAdd, AnyVLCPlayerWindow, ahk_class QWidget
		 WinClose, ahk_group AnyVLCPlayerWindow
		 Sleep, 100
		 GroupAdd, AnyMPVPlayerWindow, ahk_class mpv
		 WinClose, ahk_group AnyMPVPlayerWindow
		 WS2_SendData(Socket, "PRIVMSG " . Channel . " :Shit done been wiped.`n")
		 Return
      }
   }
	Else If (RegExMatch(Data, ":.*!.*@.*PRIVMSG " . Channel . " :!whatson"))
	{
		SetEnv, OurTime, %A_Now%
		EnvAdd, OurTime, 13, Hours
		OurJikan := SubStr(OurTime, 1, 12)
		StringReplace, Command, Param5, % Chr(10),, All
		StringReplace, Command, Command, % Chr(13),, All
		If (!Command)
		{
			WS2_SendData(Socket, "PRIVMSG " . Channel . " :¯\(°_o)/¯ iono.`n")
			Return
		}
		Else If (Command != "dunno")
		{
			SetEnv, URLGuideFarm, http://www.locatetv.com/listings/
			StringReplace, Chwat, Chwat, % Chr(10),, All
			StringReplace, Chwat, Chwat, % Chr(13),, All
			SetEnv, URLGuideFull, %URLGuideFarm%%Chwat%
			FileDelete, %A_WorkingDir%\misc\LocTvData.htm
			UrlDownloadToFile, %URLGuideFull%, %A_WorkingDir%\misc\LocTvData.htm
;			HTTPRequest( "http://www.locatetv.com/listings/fox", Page_Data := "", Headers := "User-Agent: Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/5.0)", "> %A_WorkingDir%\misc\LocTvData.htm" )
			FileRead, GuideSalad, %A_WorkingDir%\misc\LocTvData.htm
			StringReplace, GuideSalad, GuideSalad, % Chr(34), _QUOT_, All
			StringReplace, GuideSalad, GuideSalad, % Chr(60), _LESS_, All
			StringReplace, GuideSalad, GuideSalad, % Chr(62), _MORE_, All
			StringReplace, GuideSalad, GuideSalad, % Chr(9), _TOBS_, All
			GuideStalks := RegExMatch(GuideSalad, "onNow clearFix_QUOT__MORE_")
			If (GuideStalks = 0)
			{
				GuideStalks := RegExMatch(GuideSalad, "nextOn clearFix_QUOT__MORE_")
			}
			StringMid, GuideGreens, GuideSalad, GuideStalks
			FileDelete, %A_WorkingDir%\misc\GuideLeaf.txt
			FileAppend, %GuideGreens%, %A_WorkingDir%\misc\GuideLeaf.txt
			FileReadLine, FoundAnyLeaf, %A_WorkingDir%\misc\GuideLeaf.txt, 1
			
			If (FoundAnyLeaf != "onNow clearFix_QUOT__MORE_") AND (FoundAnyLeaf != "nextOn clearFix_QUOT__MORE_")
			{
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1No information found.`n")
				Return
			}
			Else If (FoundAnyLeaf = "onNow clearFix_QUOT__MORE_") OR (FoundAnyLeaf = "nextOn clearFix_QUOT__MORE_")
			{
				FileReadLine, GuideShowStem, %A_WorkingDir%\misc\GuideLeaf.txt, 4
				GuideShowPrePos := RegExMatch(GuideShowStem, "/span")
				GuideShowBgnPos := RegExMatch(GuideShowStem, "QUOT__MORE_", "", GuideShowPrePos)+11
				GuideShowEndPos := RegExMatch(GuideShowStem, "_LESS_/a")-GuideShowBgnPos
				StringMid, GuideShowLeaf, GuideShowStem, GuideShowBgnPos, GuideShowEndPos
				
				FileReadLine, GuideStartStem, %A_WorkingDir%\misc\GuideLeaf.txt, 2
				GuideStartBgnPos := RegExMatch(GuideStartStem, "QUOT__MORE_")+11
				GuideStartEndPos := RegExMatch(GuideStartStem, "_LESS_/li")-GuideStartBgnPos
				StringMid, GuideStartLeaf, GuideStartStem, GuideStartBgnPos, GuideStartEndPos
				
				FileReadLine, GuideFinishStem, %A_WorkingDir%\misc\GuideLeaf.txt, 11
				GuideFinishBgnPos := RegExMatch(GuideFinishStem, "QUOT__MORE_")+11
				GuideFinishEndPos := RegExMatch(GuideFinishStem, "_LESS_/li")-GuideFinishBgnPos
				StringMid, GuideFinishLeaf, GuideFinishStem, GuideFinishBgnPos, GuideFinishEndPos
				
				WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Title: 8,1" . GuideShowLeaf . "0,1 | Started: 15,1" . GuideStartLeaf . "0,1 | Ends: 15,1" . GuideFinishLeaf . "`n")
				Return
			}
		}
	}
	Else If (RegExMatch(Data, ":.*!.*@.*PRIVMSG " . Channel . " :\.j"))
	{
		SetEnv, URLJishoHead, http://classic.jisho.org/words?jap=
		SetEnv, URLJishoTail, &eng=&dict=edict
		SetEnv, URLJishoFull, %URLJishoHead%%Jword%%URLJishoTail%
		FileDelete, %A_WorkingDir%\misc\JishoData.htm
		UrlDownloadToFile, %URLJishoFull%, %A_WorkingDir%\misc\JishoData.htm
		FileRead, JishoSoup, %A_WorkingDir%\misc\JishoData.htm
		JishoBones := RegExMatch(JishoSoup, "-- Found")
		StringMid, JishoBroth, JishoSoup, JishoBones
		FileDelete, %A_WorkingDir%\misc\JishoMeat.txt
		FileAppend, %JishoBroth%, %A_WorkingDir%\misc\JishoMeat.txt
		FileReadLine, FoundAnyMeat, %A_WorkingDir%\misc\JishoMeat.txt, 1
		
		If (FoundAnyMeat != "-- Found words -->")
		{
			WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1No results found.`n")
			Return
		}
		Else If (FoundAnyMeat = "-- Found words -->")
		{
			FileReadLine, JishoKanjiFatX, %A_WorkingDir%\misc\JishoMeat.txt, 7
			StringReplace, JishoKanjiFatX, JishoKanjiFatX, %A_TAB%%A_TAB%%A_TAB%%A_TAB%</span>,, All
			StringReplace, JishoKanjiFatX, JishoKanjiFatX, <span class="match">,, All
			StringReplace, JishoKanjiFatX, JishoKanjiFatX, </span>,, All
			StringMid, JishoKanjiX, JishoKanjiFatX, 50
			
			FileReadLine, JishoKanaFatX, %A_WorkingDir%\misc\JishoMeat.txt, 9
			StringReplace, JishoKanaFatX, JishoKanaFatX, <span class="match">,, All
			StringReplace, JishoKanaFatX, JishoKanaFatX, </span>,, All
			StringReplace, JishoKanaFatX, JishoKanaFatX, %A_TAB%%A_TAB%%A_TAB%</td>,, All
			StringMid, JishoKanaX, JishoKanaFatX, 28
			
			FileReadLine, JishoMeaningFatX, %A_WorkingDir%\misc\JishoMeat.txt, 10
			StringReplace, JishoMeaningFatX, JishoMeaningFatX, %A_TAB%%A_TAB%%A_TAB%</td>,, All
			StringReplace, JishoMeaningFatX, JishoMeaningFatX, <strong>,, All
			StringReplace, JishoMeaningFatX, JishoMeaningFatX, </strong>,, All
			StringReplace, JishoMeaningFatX, JishoMeaningFatX, <br />, %A_SPACE%, All
			StringGetPos, JishoMeaningLardX, JishoMeaningFatX, >, R
			EnvAdd, JishoMeaningLardX, 2
			StringMid, JishoMeaningX, JishoMeaningFatX, JishoMeaningLardX
		}
			
		FileReadLine, FoundSecondMeat, %A_WorkingDir%\misc\JishoMeat.txt, 39
		IsThisMeatTwo := RegExMatch(FoundSecondMeat, "z-index")
		If (IsThisMeatTwo = 0)
		{
			GoSub, ComGoJISHOXX
			Return
		}
		Else If (IsThisMeatTwo > 0)
		{
			FileReadLine, JishoKanjiFatY, %A_WorkingDir%\misc\JishoMeat.txt, 39
			StringReplace, JishoKanjiFatY, JishoKanjiFatY, %A_TAB%%A_TAB%%A_TAB%%A_TAB%</span>,, All
			StringReplace, JishoKanjiFatY, JishoKanjiFatY, <span class="match">,, All
			StringReplace, JishoKanjiFatY, JishoKanjiFatY, </span>,, All
			StringMid, JishoKanjiY, JishoKanjiFatY, 50
			
			FileReadLine, JishoKanaFatY, %A_WorkingDir%\misc\JishoMeat.txt, 41
			StringReplace, JishoKanaFatY, JishoKanaFatY, <span class="match">,, All
			StringReplace, JishoKanaFatY, JishoKanaFatY, </span>,, All
			StringReplace, JishoKanaFatY, JishoKanaFatY, %A_TAB%%A_TAB%%A_TAB%</td>,, All
			StringMid, JishoKanaY, JishoKanaFatY, 28
			
			FileReadLine, JishoMeaningFatY, %A_WorkingDir%\misc\JishoMeat.txt, 42
			StringReplace, JishoMeaningFatY, JishoMeaningFatY, %A_TAB%%A_TAB%%A_TAB%</td>,, All
			StringReplace, JishoMeaningFatY, JishoMeaningFatY, <strong>,, All
			StringReplace, JishoMeaningFatY, JishoMeaningFatY, </strong>,, All
			StringReplace, JishoMeaningFatY, JishoMeaningFatY, <br />, %A_SPACE%, All
			StringGetPos, JishoMeaningLardY, JishoMeaningFatY, >, R
			EnvAdd, JishoMeaningLardY, 2
			StringMid, JishoMeaningY, JishoMeaningFatY, JishoMeaningLardY
		}
		
		FileReadLine, FoundThirdMeat, %A_WorkingDir%\misc\JishoMeat.txt, 71
		IsThisMeatTri := RegExMatch(FoundThirdMeat, "z-index")
		If (IsThisMeatTri = 0)
		{
			GoSub, ComGoJISHOXY
			Return
		}
		Else If (IsThisMeatTri > 0)
		{
			FileReadLine, JishoKanjiFatZ, %A_WorkingDir%\misc\JishoMeat.txt, 71
			StringReplace, JishoKanjiFatZ, JishoKanjiFatZ, %A_TAB%%A_TAB%%A_TAB%%A_TAB%</span>,, All
			StringReplace, JishoKanjiFatZ, JishoKanjiFatZ, <span class="match">,, All
			StringReplace, JishoKanjiFatZ, JishoKanjiFatZ, </span>,, All
			StringMid, JishoKanjiZ, JishoKanjiFatZ, 50
		
			FileReadLine, JishoKanaFatZ, %A_WorkingDir%\misc\JishoMeat.txt, 73
			StringReplace, JishoKanaFatZ, JishoKanaFatZ, <span class="match">,, All
			StringReplace, JishoKanaFatZ, JishoKanaFatZ, </span>,, All
			StringReplace, JishoKanaFatZ, JishoKanaFatZ, %A_TAB%%A_TAB%%A_TAB%</td>,, All
			StringMid, JishoKanaZ, JishoKanaFatZ, 28
			
			FileReadLine, JishoMeaningFatZ, %A_WorkingDir%\misc\JishoMeat.txt, 74
			StringReplace, JishoMeaningFatZ, JishoMeaningFatZ, %A_TAB%%A_TAB%%A_TAB%</td>,, All
			StringReplace, JishoMeaningFatZ, JishoMeaningFatZ, <strong>,, All
			StringReplace, JishoMeaningFatZ, JishoMeaningFatZ, </strong>,, All
			StringReplace, JishoMeaningFatZ, JishoMeaningFatZ, <br />, %A_SPACE%, All
			StringGetPos, JishoMeaningLardZ, JishoMeaningFatZ, >, R
			EnvAdd, JishoMeaningLardZ, 2
			StringMid, JishoMeaningZ, JishoMeaningFatZ, JishoMeaningLardZ
			
			GoSub, ComGoJISHOYZ
			Return
		}
		
		ComGoJISHOXX:
		WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
		Return
		
		ComGoJISHOXY:
		If (JishoMeaningX != JishoMeaningY)
		{
			If (JishoKanaX != JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningY . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningY . "`n")
					Return
				}
			}
			Else If (JishoKanaX = JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningY . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Meaning2:  15,1 " . JishoMeaningY . "`n")
					Return
				}
			}
		}
		Else If (JishoMeaningX = JishoMeaningY)
		{
			If (JishoKanaX != JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 || 8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 , 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
			}
			Else If (JishoKanaX = JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 , 8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
			}
		}
		
		ComGoJISHOYZ:
		If (JishoMeaningY != JishoMeaningZ)
		{
			If (JishoKanaY != JishoKanaZ)
			{
				If (JishoKanjiY != JishoKanjiZ)
				{
					GoSub, ComGoJISHOXYZ
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiZ . "0,1 | 9,1" . JishoKanaZ . "0,1 |15,1 " . JishoMeaningZ . "`n")
					Return
				}
				Else If (JishoKanjiY = JishoKanjiZ)
				{
					GoSub, ComGoJISHOXYZ
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiZ . "0,1 | 9,1" . JishoKanaZ . "0,1 |15,1 " . JishoMeaningZ . "`n")
					Return
				}
			}
			Else If (JishoKanaY = JishoKanaZ)
			{
				If (JishoKanjiY != JishoKanjiZ)
				{
					GoSub, ComGoJISHOXYZ
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiZ . "0,1 | 9,1" . JishoKanaZ . "0,1 |15,1 " . JishoMeaningZ . "`n")
					Return
				}
				Else If (JishoKanjiY = JishoKanjiZ)
				{
					GoSub, ComGoJISHOXYZ
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Meaning3:  15,1 " . JishoMeaningZ . "`n")
					Return
				}
			}
		}
		Else If (JishoMeaningY = JishoMeaningZ)
		{
			If (JishoKanaY != JishoKanaZ)
			{
				If (JishoKanjiY != JishoKanjiZ)
				{
					JishoKanjiY := JishoKanjiY + " / " + JishoKanjiZ
					JishoKanaY := JishoKanaY + " / " + JishoKanaZ
					GoSub, ComGoJISHOXYZ
					Return
				}
				Else If (JishoKanjiY = JishoKanjiZ)
				{
					JishoKanaY := JishoKanaY + " \ " + JishoKanaZ
					GoSub, ComGoJISHOXYZ
					Return
				}
			}
			Else If (JishoKanaY = JishoKanaZ)
			{
				If (JishoKanjiY != JishoKanjiZ)
				{
					JishoKanjiY := JishoKanjiY + " ~ " + JishoKanjiZ
					GoSub, ComGoJISHOXYZ
					Return
				}
				Else If (JishoKanjiY = JishoKanjiZ)
				{
					GoSub, ComGoJISHOXYZ
					Return
				}
			}
		}
		
		ComGoJISHOXYZ:
		If (JishoMeaningX != JishoMeaningY)
		{
			If (JishoKanaX != JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningY . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningY . "`n")
					Return
				}
			}
			Else If (JishoKanaX = JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results :   8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningY . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Meaning2:  15,1 " . JishoMeaningY . "`n")
					Return
				}
			}
		}
		Else If (JishoMeaningX = JishoMeaningY)
		{
			If (JishoKanaX != JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 || 8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 , 9,1" . JishoKanaY . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
			}
			Else If (JishoKanaX = JishoKanaY)
			{
				If (JishoKanjiX != JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 , 8,1" . JishoKanjiY . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
				Else If (JishoKanjiX = JishoKanjiY)
				{
					WS2_SendData(Socket, "PRIVMSG " . Channel . " :0,1Results:    8,1" . JishoKanjiX . "0,1 | 9,1" . JishoKanaX . "0,1 |15,1 " . JishoMeaningX . "`n")
					Return
				}
			}
		}
	}
}

ComGoSTATUS:
   FileRead, CommStatus, %A_WorkingDir%\misc\commands.status
	 If (CommStatus = 1) {
		CommStatis = 0,3 ON  
		}
	 Else If (CommStatus = 0) {
		CommStatis = 0,4 OFF 
		}
	 FileRead, ClipStatus, %A_WorkingDir%\misc\clips.status
	 If (ClipStatus = 1) {
		ClipStatis = 0,3 ON  
		}
	 Else If (ClipStatus = 0) {
		ClipStatis = 0,4 OFF 
		}
	 FileRead, WebmStatus, %A_WorkingDir%\misc\webms.status
	 If (WebmStatus = 1) {
		WebmStatis = 0,3 ON  
		}
	 Else If (WebmStatus = 0) {
		WebmStatis = 0,4 OFF 
		}
	 WS2_SendData(Socket, "PRIVMSG " . Channel . " :15,1 Commands: " . CommStatis . "15,1|15,1 Youtubes: " . ClipStatis . "15,1|15,1 Webums: " . WebmStatis . "`n")
	 Return
