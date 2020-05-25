    Function Load-MissingAssembly {
        [cmdletbinding()]
        Param(
            [string]$AssemblyName,
            [string]$Environment
        )
        $SDIR = "$($PWD.Path)"
        if ([System.IO.Directory]::Exists( [System.Environment]::GetEnvironmentVariable("$($ENVIRONMENT)", "MACHINE") ) ) { 
            cd "$([System.Environment]::GetEnvironmentVariable("$($ENVIRONMENT)","MACHINE"))" 
        } else {
            $null = [System.IO.Directory]::CreateDirectory([System.Environment]::GetEnvironmentVariable("$($ENVIRONMENT)", "MACHINE"))
            cd "$([System.Environment]::GetEnvironmentVariable("$($ENVIRONMENT)","MACHINE"))" 
        }
        if (
            [System.IO.Directory]::GetFiles("C:\Windows\Microsoft.Net\assembly\GAC_MSIL", "*$($AssemblyName).dll", [System.IO.SearchOption]::AllDirectories) -or `
            "$([System.IO.Directory]::GetDirectories("$($PWD.Path)","*$($AssemblyName)*",[System.IO.SearchOption]::AllDirectories))"
        ) {
            if ([System.IO.Directory]::GetFiles("C:\Windows\Microsoft.Net\assembly\GAC_MSIL", "*$($AssemblyName).dll", [System.IO.SearchOption]::AllDirectories)) {
                $DLL = "$([System.IO.Directory]::GetFiles("C:\Windows\Microsoft.Net\assembly\GAC_MSIL","*$($AssemblyName).dll",[System.IO.SearchOption]::AllDirectories))"
                cd "$($SDIR)"
                return $DLL
            }
            if ("$([System.IO.Directory]::GetDirectories("$($PWD.Path)","*$($AssemblyName)*",[System.IO.SearchOption]::AllDirectories))") {
                cd "$([System.IO.Directory]::GetDirectories("$($PWD.Path)","*$($AssemblyName)*",[System.IO.SearchOption]::AllDirectories))\"
                if([System.IO.Directory]::Exists("$([System.IO.Directory]::GetDirectories("$($PWD.Path)","*$($AssemblyName)*",[System.IO.SearchOption]::AllDirectories))\lib")){
                    cd "$([System.IO.Directory]::GetDirectories("$($PWD.Path)","*$($AssemblyName)*",[System.IO.SearchOption]::AllDirectories))\lib"
                    cd "$([System.IO.Directory]::GetDirectories("$($PWD.Path)","net??",[System.IO.SearchOption]::AllDirectories) | sort | select -Last 1)"
                    $DLL = "$([System.io.Directory]::GetFiles("$($PWD.Path)","*.dll"))"
                    cd "$($SDIR)"
                    return $DLL
                } else {
                    $DLL = "$([System.io.Directory]::GetFiles("$($PWD.Path)","*.dll"))"
                    cd "$($SDIR)"
                    return $DLL
                }
            }
        } else {
            if (![system.io.file]::Exists("C:\ProgramData\chocolatey\bin\choco.exe")) {
                $p = [system.Diagnostics.Process]@{
                    StartInfo = [System.Diagnostics.ProcessStartInfo]@{
                        FileName  = "$($PSHOME)\PowerShell.exe";
                        Arguments = " -noprofile -nologo -ep remotesigned -c iex (irm 'https://chocolatey.org/install.ps1')";
                        Verb      = "RunAs";
                    }
                }
                $null = $p.Start()
                $p.WaitForExit()
                while (![system.io.file]::Exists("C:\ProgramData\chocolatey\bin\choco.exe")) { sleep -m 100 }
            }
            if (![System.IO.File]::Exists("C:\ProgramData\chocolatey\lib\NuGet.CommandLine\tools\nuget.exe")) {
                $p = [system.Diagnostics.Process]@{
                    StartInfo = [System.Diagnostics.ProcessStartInfo]@{
                        FileName  = "C:\ProgramData\chocolatey\bin\choco.exe";
                        Arguments = " install NuGet.CommandLine -y";
                        Verb      = "RunAs";
                    }
                }
                $null = $p.Start()
                $p.WaitForExit()
                while (![System.IO.File]::Exists("C:\ProgramData\chocolatey\lib\NuGet.CommandLine\tools\nuget.exe")) { sleep -m 100 }
            }
            . C:\ProgramData\Chocolatey\lib\NuGet.CommandLine\tools\nuget.exe install $($AssemblyName) -DependencyVersion ignore -OutputDirectory "$($PWD.Path)\Assemblies"
            cd "$([System.IO.Directory]::GetDirectories("$($PWD.Path)","*$($AssemblyName)*",[System.IO.SearchOption]::AllDirectories))\lib"
            cd "$([System.IO.Directory]::GetDirectories("$($PWD.Path)","net??",[System.IO.SearchOption]::AllDirectories) | sort | select -Last 1)"
            $TDIR = "$($PWD.Path)"
            cd $SDIR
            return "$([System.io.Directory]::GetFiles("$($TDIR)","*.dll"))"
        }
    }
