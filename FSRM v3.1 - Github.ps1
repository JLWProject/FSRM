<#
	.NOTES
	===========================================================================
	 Created on:   	21-May-19
	 Created by:   	Rust
	 Organization: 	JLWProject
	 Filename:
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Show-Menu
{
	param (
		[string]$Title = 'Configure and Maintain FSRM.'
	)
	cls
	Write-Host "================ $Title ================"

	Write-Host "1: Press '1' To Install and Configure FSRM"
	Write-Host "2: Press '2' To Restore Access to the SMB Shares."
	Write-Host "Q: Press 'Q' to quit."
}
do
{
	Show-Menu
	$input = Read-Host "Please make a selection"
	switch ($input)
	{
		'1' {
			cls
			'You chose option #1'
			$MajorVer = [System.Environment]::OSVersion.Version.Major
			$MinorVer = [System.Environment]::OSVersion.Version.Minor
			#if ($majorVer -ge 6 -or $MajorVer -eq 10) # FSRM Check if its installed

				$Feature = Get-WindowsFeature -Name FS-Resource-Manager

				#Command for Server 2012 and R2 and 2016/19#
				if (($MinorVer -ge 2 -or $Minorver -eq 3 -or $Majorver -eq 10) -and $Feature.Installed -ne "True")
				{ $InstallFeature = Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools }
				#Command for 2008R2#
				elseif ($MinorVer -ge 1 -and $Feature.Installed -ne "True")
				{ $InstallFeature = Add-WindowsFeature FS-FileServer, FS-Resource-Manager }
				#Command for Server 2008#
				elseif ($Feature.Installed -ne "True")
				{ $InstallFeature = &servermanagercmd -Install FS-FileServer FS-Resource-Manager }



			if ($MinorVer -ge 2 -or $MinorVer -eq 3 -or $MajorVer -eq 10) #FSRM Configuration
			{
				if (Test-Path -Path "C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NTFSSecurity\")
				{
					Write-Host "NTFS Module already installed, skipping"
				}
				Else
				{
					Start-BitsTransfer -Source 'https://github.com/Rust7thStar/NTFSSecurity/raw/master/NTFSSecurity.zip' -Destination 'C:\'
					New-item "C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NTFSSecurity" -ItemType directory
					$shell_app = new-object -com shell.application
					$zip_file = $shell_app.namespace("C:\NTFSSecurity.zip")
					$destination = $shell_app.namespace("C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NTFSSecurity")
					$destination.Copyhere($zip_file.items())
					Remove-Item "C:\NTFSSecurity.Zip"
				}

				$ShareLocation = Read-Host "Honeypot Location Ie: C:\sharename\a.donttouch"
				# We use Silently Continue as this option will be already configured on multiple runs
					New-FsrmFileGroup -Name "Known Ransomware Files" -IncludePattern "*.*" -ErrorAction SilentlyContinue

					Import-Module ntfssecurity
					New-item $ShareLocation -ItemType directory
					Add-NTFSAccess -path $ShareLocation -account "Everyone" -AccessRights FullControl
					Disable-NTFSAccessInheritance $ShareLocation -RemoveInheritedAccessRules
					Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Rust7thStar/FSRM/master/Please%20Read.txt' -Destination $ShareLocation
					Start-BitsTransfer -Source 'https://github.com/Rust7thStar/FSRM/raw/master/Please%20note.docx' -Destination $ShareLocation
					Start-BitsTransfer -Source 'https://github.com/Rust7thStar/FSRM/raw/master/changeme.pptx' -Destination $ShareLocation
					Start-BitsTransfer -Source 'https://github.com/Rust7thStar/FSRM/raw/master/plkfsfsa.xlsx' -Destination $ShareLocation

					$SMBBlock1 = (Invoke-WebRequest "https://raw.githubusercontent.com/Rust7thStar/FSRM/master/FSRMCommand.txt").Content
					$Notification = New-FsrmAction -Type Email -MailTo "[Admin Email]" -Subject "Warning: attempted to create file" -Body "User [Source Io Owner] has attempted to save to [File Screen Path] on [Server] - this is a honeypot and isn't allowed."
					$Command = New-FsrmAction -Type Command -Command "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -CommandParameters $SMBBlock1 -SecurityLevel LocalSystem -KillTimeOut 0
					New-FsrmFileScreen -Path $ShareLocation -Notification $Command, $Notification -IncludeGroup "Known Ransomware Files" -Active
					Set-FsrmSetting -SmtpServer desktopmonster-co-uk.mail.protection.outlook.com -AdminEmailAddress "Help@Desktopmonster.co.uk"

			}
			elseif ($MinorVer -ge 1 -or $MinorVer -eq 0)
			{
				$ShareLocation = Read-Host "Honeypot Location Ie: C:\sharename\a.donttouch"
				New-item $ShareLocation -ItemType directory

				(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/Rust7thStar/FSRM/master/FSRM2008.txt", "C:\FSRM2008.txt")
				(New-Object System.Net.WebClient).DownloadFile("https://github.com/Rust7thStar/FSRM/blob/master/Please%20note.docx", "$ShareLocation\Please note.docx")
				(New-Object System.Net.WebClient).DownloadFile("https://github.com/Rust7thStar/FSRM/blob/master/plkfsfsa.xlsx", "$ShareLocation\plkfsfsa.xlsx")
				(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/Rust7thStar/FSRM/master/Please%20Read.txt", "$ShareLocation\Please Read.txt")
				(New-Object System.Net.WebClient).DownloadFile("https://github.com/Rust7thStar/FSRM/blob/master/changeme.pptx", "$ShareLocation\changeme.pptx")


				Filescrn Filegroup Add /filegroup:"Known Ransomware Files" /Members:*.*
				Filescrn Screen Add /Path:$ShareLocation /Type:active /Add-filegroup:"Known Ransomware Files" "/Add-notification:C,C:\FSRM2008.txt"
			}
		} '2' {
			cls
			'You chose option #2'
			Write-host "Imput the Full AD Account Details For The User That Has Been Blocked, This is only for Windows Server 2012 onwards. Enable lanman service on servers below this edition"
			$User = Read-Host
			Get-SmbShare -Special $false | ForEach-Object { Unblock-SmbShareAccess -Name $_.Name -AccountName $User -Force }

		} 'q' {
			return
		}
	}
	Pause
}
until ($input -eq 'q')
