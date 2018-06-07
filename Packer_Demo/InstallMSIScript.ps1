Configuration InstallMSIScriptResource            
{            
    Import-DscResource -ModuleName PSDesiredStateConfiguration
             
    Node localhost            
    {    
    
    Script DownloadMsi
{
            GetScript = 
            {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = ('True' -in (Test-Path C:\MyOfficePackages\7z920-x64.msi))
                }
            }

            SetScript = 
            {
                Invoke-WebRequest -Uri "http://xyz....mention the url to download.../" -OutFile "C:\MyOfficePackages\7z920-x64.msi"
            }

            TestScript = 
            {
                $Status = ('True' -in (Test-Path C:\MyOfficePackages\7z920-x64.msi))
                $Status -eq $True
            }
        }        
        Package Install7Zip
        {
            Ensure = 'Present'
            Name = '7-Zip 9.20 (x64 edition)'
            Path = 'C:\MyOfficePackages\7z920-x64.msi'
            ProductId = '23170F69-40C1-2702-0920-000001000000'

        }
    }
}
            
InstallMSIScriptResource -OutputPath .\Install7Zip   
            
Start-DscConfiguration -Path .\InstallMSIScriptResource -Wait -Verbose            
            
Get-DscConfiguration           