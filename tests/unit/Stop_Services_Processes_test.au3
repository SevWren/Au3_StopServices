#include <AutoItConstants.au3>
#include <File.au3>
#include <FileConstants.au3>
#include "../Stop Services Processes.au3"

; Create a temporary log file for testing
Local $sTempLogFile = @TempDir & "\test_log.txt"

; Test writing a simple log entry
Func TestSimpleLogEntry()
    Local $sTestEntry = "Test log entry" & @CRLF
    _LogTest($sTestEntry)
    Local $sFileContent = FileRead($sTempLogFile)
    Assert($sFileContent == $sTestEntry, "Simple log entry should be written correctly")
EndFunc

; Test writing multiple log entries
Func TestMultipleLogEntries()
    Local $sTestEntry1 = "First log entry" & @CRLF
    Local $sTestEntry2 = "Second log entry" & @CRLF
    _LogTest($sTestEntry1)
    _LogTest($sTestEntry2)
    Local $sFileContent = FileRead($sTempLogFile)
    Assert($sFileContent == $sTestEntry1 & $sTestEntry2, "Multiple log entries should be appended correctly")
EndFunc

; Test writing an empty log entry
Func TestEmptyLogEntry()
    Local $sTestEntry = ""
    _LogTest($sTestEntry)
    Local $sFileContent = FileRead($sTempLogFile)
    Assert($sFileContent == "", "Empty log entry should not write anything to the file")
EndFunc

; Test writing a log entry with special characters
Func TestSpecialCharacters()
    Local $sTestEntry = "Special chars: !@#$%^&*()" & @CRLF
    _LogTest($sTestEntry)
    Local $sFileContent = FileRead($sTempLogFile)
    Assert($sFileContent == $sTestEntry, "Log entry with special characters should be written correctly")
EndFunc

; Run all tests
TestSimpleLogEntry()
TestMultipleLogEntries()
TestEmptyLogEntry()
TestSpecialCharacters()

; Clean up the temporary log file
FileDelete($sTempLogFile)
