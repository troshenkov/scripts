set Args = Wscript.Arguments
mDrive = Args.item(0)
Set oShell = CreateObject("Shell.Application")
oShell.NameSpace(mDrive).Self.Name = Args.item(1)

