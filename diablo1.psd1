#
# Modulmanifest für das Modul "diablo1"
#
# Generiert von: Marco
#
# Generiert am: 29.04.2017
#

@{

# Die diesem Manifest zugeordnete Skript- oder Binärmoduldatei.
ModuleToProcess = 'Diablo1.psm1'

# Die Versionsnummer dieses Moduls
ModuleVersion = '0.1'

# Unterstützte PSEditions
# CompatiblePSEditions = @()

# ID zur eindeutigen Kennzeichnung dieses Moduls
GUID = 'b33a1f91-ad7c-4e01-916a-4d1082b2ca79'

# Autor dieses Moduls
Author = 'Serpen'

# Unternehmen oder Hersteller dieses Moduls
CompanyName = ''

# Urheberrechtserklärung für dieses Modul
Copyright = '(c) 2017 Serpen. Alle Rechte vorbehalten.'

# Beschreibung der von diesem Modul bereitgestellten Funktionen
Description = 'Powershell Module for Diablo 1'

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
PowerShellVersion = '2.0'

# Der Name des für dieses Modul erforderlichen Windows PowerShell-Hosts
# PowerShellHostName = ''

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Hosts
# PowerShellHostVersion = ''

# Die für dieses Modul mindestens erforderliche Microsoft .NET Framework-Version. Diese erforderliche Komponente ist nur für die PowerShell Desktop-Edition gültig.
# DotNetFrameworkVersion = ''

# Die für dieses Modul mindestens erforderliche Version der CLR (Common Language Runtime). Diese erforderliche Komponente ist nur für die PowerShell Desktop-Edition gültig.
# CLRVersion = ''

# Die für dieses Modul erforderliche Prozessorarchitektur ("Keine", "X86", "Amd64").
# ProcessorArchitecture = ''

# Die Module, die vor dem Importieren dieses Moduls in die globale Umgebung geladen werden müssen
# RequiredModules = @()

# Die Assemblys, die vor dem Importieren dieses Moduls geladen werden müssen
# RequiredAssemblies = @()

# Die Skriptdateien (PS1-Dateien), die vor dem Importieren dieses Moduls in der Umgebung des Aufrufers ausgeführt werden.
#ScriptsToProcess = 'definitions.ps1'

# Die Typdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
# TypesToProcess = @()

# Die Formatdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
FormatsToProcess = 'diablo1.ps1xml'

# Die Module, die als geschachtelte Module des in "RootModule/ModuleToProcess" angegebenen Moduls importiert werden sollen.
# NestedModules = @()

# Aus diesem Modul zu exportierende Funktionen. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Funktionen vorhanden sind.
FunctionsToExport = 'Connect-DiabloSession','ConvertTo-DiabloItem','DisConnect-DiabloSession','Export-DiabloItem','Get-DiabloBelt','Get-DiabloCharacterPosition','Get-DiabloCharacterStats','Get-DiabloDifficulty','Get-DiabloEntrances','Get-DiabloInventory','Get-DiabloMonsterKills','Get-DiabloPlayers','Get-DiabloQuests', 'Get-DiabloRucksack','Get-DiabloSpell','Get-DiabloStoreItems','Get-DiabloTownPortal','Get-DiabloVersion','Invoke-DiabloIdentifyItem','Invoke-DiabloRepairItem','Set-DiabloDifficulty', 'Set-DiabloEntrances','Set-DiabloItemProperty','Set-DiabloPoints','Set-DiabloSpell'

# Aus diesem Modul zu exportierende Cmdlets. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Cmdlets vorhanden sind.
CmdletsToExport = 'Connect-DiabloSession','ConvertTo-DiabloItem','DisConnect-DiabloSession','Export-DiabloItem','Get-DiabloBelt','Get-DiabloCharacterPosition','Get-DiabloCharacterStats','Get-DiabloDifficulty','Get-DiabloEntrances','Get-DiabloInventory','Get-DiabloMonsterKills','Get-DiabloPlayers','Get-DiabloQuests', 'Get-DiabloRucksack','Get-DiabloSpell','Get-DiabloStoreItems','Get-DiabloTownPortal','Get-DiabloVersion','Invoke-DiabloIdentifyItem','Invoke-DiabloRepairItem','Set-DiabloDifficulty', 'Set-DiabloEntrances','Set-DiabloItemProperty','Set-DiabloPoints','Set-DiabloSpell'

# Die aus diesem Modul zu exportierenden Variablen
VariablesToExport = ''

# Aus diesem Modul zu exportierende Aliase. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Aliase vorhanden sind.
AliasesToExport = @()

# Aus diesem Modul zu exportierende DSC-Ressourcen
# DscResourcesToExport = @()

# Liste aller Module in diesem Modulpaket
# ModuleList = @()

# Liste aller Dateien in diesem Modulpaket
# FileList = @()

# Die privaten Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen. Diese können auch eine PSData-Hashtabelle mit zusätzlichen von PowerShell verwendeten Modulmetadaten enthalten.
PrivateData = @{

    PSData = @{

        # 'Tags' wurde auf das Modul angewendet und unterstützt die Modulermittlung in Onlinekatalogen.
        # Tags = @()

        # Eine URL zur Lizenz für dieses Modul.
        # LicenseUri = ''

        # Eine URL zur Hauptwebsite für dieses Projekt.
        # ProjectUri = ''

        # Eine URL zu einem Symbol, das das Modul darstellt.
        # IconUri = ''

        # 'ReleaseNotes' des Moduls
        # ReleaseNotes = ''

    } # Ende der PSData-Hashtabelle

} # Ende der PrivateData-Hashtabelle

# HelpInfo-URI dieses Moduls
# HelpInfoURI = ''

# Standardpräfix für Befehle, die aus diesem Modul exportiert werden. Das Standardpräfix kann mit "Import-Module -Prefix" überschrieben werden.
#DefaultCommandPrefix = 'Diablo'

}

