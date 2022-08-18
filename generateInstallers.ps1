SET timestmp=20150206_1803
attrib -R .\Environment\Installer\ServicePlatform\*.* /D /S
subst k: \\bogexp1\DL\Encrypted\Bundle\Rosen_14.1_%timestmp%_Services.Platform
"C:\Program Files (x86)\InstallShield\2012 SAB\System\iscmdbld.exe" -p .\Environment\Installer\ServicePlatform\PlatformInstaller.ism -l PATH_TO_BASE_WEBSITE_FILES="k:\base_website" -b k:\ 
subst k: /D
attrib +R .\Environment\Installer\ServicePlatform\*.* /D /S



REM Creation of the Application Installer
attrib -R .\Environment\Installer\ApplicationInstaller\*.* /D /S
subst l: \\bogexp1\DL\Encrypted\Bundle\Rosen_14.1_%timestmp%_Clients.Infrastructure 
"C:\Program Files (x86)\InstallShield\2012 SAB\System\iscmdbld.exe" -p .\Environment\Installer\ApplicationInstaller\RoaimsClient.ism -l PATH_TO_BASE_APPLICATIO_FILES="l:\base_application" -b l:\ 
subst l: /D
attrib +R .\Environment\Installer\ApplicationInstaller\*.* /D /S

