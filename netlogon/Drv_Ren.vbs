' ===================================================================
' Rename Drive Label Script
' ===================================================================
'
' This script allows you to rename the label of a drive (e.g., "C:" or "D:")
' using the Windows Script Host (WSH) and Shell.Application object.
'
' Usage:
' cscript rename_drive_label.vbs <drive_letter> <new_label>
'
' Example:
' cscript rename_drive_label.vbs "C:" "NewLabel"
'
' Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
' ===================================================================

' Set the command-line arguments to be used
Set Args = Wscript.Arguments

' Ensure that the correct number of arguments have been passed
If Args.Count < 2 Then
    Wscript.Echo "Usage: cscript rename_drive_label.vbs <drive_letter> <new_label>"
    Wscript.Quit 1
End If

' Get the drive letter (e.g., "C:" or "D:") from the first argument
mDrive = Args.item(0)

' Create a Shell object to interact with the file system
Set oShell = CreateObject("Shell.Application")

' Rename the drive label (set the new name from the second argument)
oShell.NameSpace(mDrive).Self.Name = Args.item(1)

' Optional: Display a confirmation message
Wscript.Echo "Drive label of " & mDrive & " has been renamed to " & Args.item(1)

' Exit the script
Wscript.Quit 0
