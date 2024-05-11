#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\Unsorted\16d1e8e7492f7c41cffb87537dbd04d90f4a2b47.ico
#AutoIt3Wrapper_Outfile=..\..\Desktop\Stop Services - Processes.Exe
#AutoIt3Wrapper_Res_Description=Script monitors processes and services related to windows update and terminates if running.
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region ;Includes/Options/Permissions/Hotkeys

#include <ServiceControl.au3>
#include <MsgBoxConstants.au3>
#include <Misc.au3>
#include <mycustoms.au3>
#RequireAdmin
Opt("WinTitleMatchMode", 2)
HotKeySet("{ScrollLock}{PAUSE}", "_exit")
HotKeySet("{F1}", "ToggleScript") ;hotkey used to toggle on/off of script
#EndRegion ;Includes/Options/Permissions/Hotkeys

#Region ;Globals
Global $sStringInstaller = "In the _CloserInstaller function and just terminated"
Global $taskcloseran = 0
Global $sProcesses[11] = ["taskhostw.exe", "TrustedInstaller.exe", "TiWorker.exe", "CompatTelRunner.exe", "VSSVC.exe", "msiexec.exe", "msedge.exe", "helppane.exe", "net.exe", "vmcompute.exe", "MicrosoftSecurityApp.exe"] ;list of processes to always close
Global $bScriptRunning = False ; Variable to track the script's running state
Global $iLastStopServices = TimerInit() ;Variable to track the last time _stopservicescustom() was called.
Global $iLastStopProcesses = TimerInit() ;Variable to track the last time _closeinstaller() was called.
Global $iStopServicesCounter = 0 ; Counter to track the number of times _stopservicescustom() has been called
#EndRegion ;Globals

ProcessClose("vmcompute.exe")

While 1  ;Keeps script running indefinitely.  Hotkeys determine which path the script heads
	Sleep(50)
WEnd

Func ToggleScript() ;handles the toggling on and off of script.  Eventually use this to handle halting the main loop instead.
	If $bScriptRunning Then
		MsgBox($MB_SYSTEMMODAL, "AutoIT Script", "Script paused!", 1)
		$bScriptRunning = False ;this exits this function
	Else
		MsgBox($MB_SYSTEMMODAL, "AutoIT Script", "Script started!", 1)
		$bScriptRunning = True
	EndIf

	While $bScriptRunning  ;Loop indefinetly escaped by F1 hotkey
		If CheckElapsedTime($iLastStopProcesses, 3) Then ; Check if 3 seconds have passed since the last call of _stopservices
			_CloseInstaller() ;_CloseInstaller() terminates all the process names stored in $sProcesses[] array
			$iLastStopProcesses = TimerInit() ;Update $iLastStopServices with the current time for future timerdiff checks
		EndIf

		If $iStopServicesCounter < 3 Then

			_stopservicescustom()
			$iStopServicesCounter += 1
		Else
			If CheckElapsedTime($iLastStopServices, 5) Then ; Check if 10 seconds have passed since the last call of _stopservices
				_stopservicescustom() ; call function that handles checking service status and stop them if running
				$iLastStopServices = TimerInit() ;Update $iLastStopServices with the current time for future timerdiff checks
			EndIf
		EndIf

;~ 		ConsoleWrite("In main loop.  Sleeping for 2 seconds now." & @CRLF)
		Sleep(2000)
	WEnd
EndFunc   ;==>ToggleScript

Func _CloseInstaller() ;handles closing of all the processes stored in the $sProcesses array
	For $i = 0 To UBound($sProcesses) - 1 ;loop that is determined on the total number of rows in $sProcesses array
		If ProcessExists($sProcesses[$i]) Then ;if value in array is valid then
			ProcessClose($sProcesses[$i]) ;close the process stored in the current row $i of the $sProcesses array
		EndIf
	Next ;continue loop
EndFunc   ;==>_CloseInstaller

Func _stopservicescustom() ;run cmd prompt and pass net stop commands and set cmd prompt to hidden
;~ 	ConsoleWrite("In _stopservicescustom()" & @CRLF)
	If _ServiceRunning("", "TrustedInstaller") = True Then
		ToolTip("TrustedInstaller Service Detected Running, stopping now.", 0, 0, "", -1, 1)
		_stopservice("", "TrustedInstaller")
		ToolTip("") ; Clear the tooltip
	ElseIf _ServiceRunning("", "wuauserv") = True Then ;is windows update running?
		ToolTip("Windows Update Service Detected Running, stopping now.", 0, 0, "", -1, 1)
		_stopservice("", "wuauserv") ;stop windows update service
		ToolTip("") ; Clear the tooltip
	ElseIf _ServiceRunning("", "UsoSvc") = True Then ;is windows update running?
		ToolTip("Update Orchestrator Service Detected Running, stopping now.", 0, 0, "", -1, 1)
		_stopservice("", "UsoSvc") ;stop update orchestrator service
		ToolTip("") ; Clear the tooltip
	ElseIf _ServiceRunning("", "DoSvc") = True Then ;is windows update running?
		ToolTip("Delivery Optimization Service Detected Running, stopping now.", 0, 0, "", -1, 1)
		_stopservice("", "DoSvc") ;stop windows update service
		ToolTip("") ; Clear the tooltip
	ElseIf _ServiceRunning("", "WaaSMedicSvc") = True Then ;is windows update running?
		ToolTip("Windows Update Medic Service Detected Running, stopping now.", 0, 0, "", -1, 1)
		_stopservice("", "WaaSMedicSvc") ;stop windows update service
		ToolTip("") ; Clear the tooltip
	ElseIf _ServiceRunning("", "sppsvc") = True Then ;is windows update running?'
		ToolTip("Software Protection Service Detected Running, stopping now.", 0, 0, "", -1, 1)
		ProcessClose("sppsvc.exe")
		ToolTip("") ; Clear the tooltip
	ElseIf ProcessExists("sppsvc.exe") Then ;currently sppsvc.exe (software protection service related process) usually runs when updates are happening
		ToolTip("Stopping Software Protection Service", 0, 0, "", -1, 1)
		_stopservice("", "sppsvc") ;stop windows update service
		_stopservice("", "qwave")
		ToolTip("") ; Clear the tooltip
	EndIf
EndFunc   ;==>_stopservicescustom

Func CheckElapsedTime($iStartTime, $iInterval)  ;handles the calculation of time difference in ms to seconds
	Return TimerDiff($iStartTime) >= ($iInterval * 1000)
EndFunc   ;==>CheckElapsedTime

Func _exit()
;~ 	MsgBox(0, "Hotkey Triggered", "Ctrl + Shift + Esc was pressed. Exiting...")
	Exit
EndFunc   ;==>_exit







#cs
Func _stopservicescustom() ;run cmd prompt and pass net stop commands and set cmd prompt to hidden
;~ 	ConsoleWrite("In _stopservicescustom()" & @CRLF)
	If _ServiceRunning("", "TrustedInstaller") = True Then
		MsgBox("", "", "TrustedInstaller Service Detected Running, stopping now.", 1)
		_stopservice("", "TrustedInstaller")
	ElseIf _ServiceRunning("", "wuauserv") = True Then ;is windows update running?
		MsgBox("", "", "Windows Update Service Detected Running, stopping now.", 1)
		_stopservice("", "wuauserv") ;stop windows update service
	ElseIf _ServiceRunning("", "UsoSvc") = True Then ;is windows update running?
		MsgBox("", "", "Update Orchestrator Service Detected Running, stopping now.", 1)
		_stopservice("", "UsoSvc") ;stop update orchestrator service
	ElseIf _ServiceRunning("", "DoSvc") = True Then ;is windows update running?
		MsgBox("", "", "Delivery Optimization Service Detected Running, stopping now.", 1)
		_stopservice("", "DoSvc") ;stop windows update service
	ElseIf _ServiceRunning("", "WaaSMedicSvc") = True Then ;is windows update running?
		MsgBox("", "", "Windows Update Medic Service Detected Running, stopping now.", 1)
		_stopservice("", "WaaSMedicSvc") ;stop windows update service
	ElseIf _ServiceRunning("", "sppsvc") = True Then ;is windows update running?'
		MsgBox("", "", "Software Protection Service Detected Running, stopping now.", 1)
		;    _stopservice("", "sppsvc") ;stop windows update service
		ProcessClose("sppsvc.exe")
	ElseIf ProcessExists("sppsvc.exe") Then ;currently sppsvc.exe (software protection service related process) usually runs when updates are happening
		_stopservice("", "sppsvc") ;stop windows update service
		_stopservice("", "qwave")
	EndIf
EndFunc   ;==>_stopservicescustom
#ce

#cs
Func _stopservicescustom() ;run cmd prompt and pass net stop commands and set cmd prompt to hidden

;~ 	ConsoleWrite("In _stopservicescustom()" & @CRLF)
	If _ServiceRunning("", "Trusted Installer") = True Then
		MsgBox("", "TrustedInstaller", " Service Detected Running, stopping now.",1)
		_stopservice("", "TrustedInstaller")
	ElseIf _ServiceRunning("", "wuauserv") = True Then ;is windows update running?
		MsgBox("", "", "Windows Update Service Detected Running, stopping now.",1)
		_stopservice("", "wuauserv") ;stop windows update service
	ElseIf _ServiceRunning("", "UsoSvc") = True Then ;is windows update running?
		MsgBox("", "", "Update Orchestrator Service Detected Running, stopping now.",1)
		_stopservice("", "UsoSvc") ;stop update orchestrator service
	ElseIf _ServiceRunning("", "DoSvc") = True Then ;is windows update running?
		MsgBox("", "", "Delivery Optimization Service Detected Running, stopping now.",1)
		_stopservice("", "DoSvc") ;stop windows update service
	ElseIf _ServiceRunning("", "WaaSMedicSvc") = True Then ;is windows update running?
		MsgBox("", "", " Service Detected Running, stopping now.",1)
		_stopservice("", "WaaSMedicSvc") ;stop windows update service
	ElseIf _ServiceRunning("", "sppsvc") = True Then ;is windows update running?'
		MsgBox("", "", " Service Detected Running, stopping now.",1)
		_stopservice("", "sppsvc") ;stop windows update service
	EndIf

	If ProcessExists("sppsvc.exe") Then ;currently sppsvc.exe (software protection service related process) usually runs when updates are happening
		_stopservice("", "sppsvc") ;stop windows update service
		_stopservice("", "qwave")
	EndIf
EndFunc   ;==>_stopservicescustom
#ce
