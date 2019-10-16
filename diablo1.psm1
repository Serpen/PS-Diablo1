$PSScriptRoot2 = Split-Path $MyInvocation.MyCommand.Path -Parent

Add-Type -path $PSScriptRoot2\Serpen.Wrapper.ProcessMemory.cs
Add-Type -path $PSScriptRoot2\Globals.cs, $PSScriptRoot2\skeleton.cs, $PSScriptRoot2\DiabloItem.cs -CompilerParameters (new-object System.CodeDom.Compiler.CompilerParameters -Property @{CompilerOptions="/unsafe"})

. "$PSScriptRoot2\definitions.ps1"
. "$PSScriptRoot2\Offsets.ps1"

function Get-D1Version {
[CmdLetBinding()]
param (
    [Parameter(Mandatory=$true, ParameterSetName='FromFile')] [String]$File,
    [Parameter(Mandatory=$true, ParameterSetName='FromProcess')] [System.Diagnostics.Process]$Process,
    [Parameter(Mandatory=$true, ParameterSetName='FromMemory')] [System.IntPtr]$MemoryHandle
)

if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
    $hash = 0
    foreach ($Ver in $VersionTable)  {
        if ($hash -eq $Ver.FileHash) {
            return $Ver
        }
    }
    throw 'No Version Information'
    
} else {
    if ($PSCmdlet.ParameterSetName -eq 'FromProcess') {
        $handle = [Serpen.Wrapper.ProcessMemory]::OpenProcess(0x10, $false, $Process.Id)
    } else {
        $handle = $MemoryHandle
    }

    $bufferSmall = [array]::CreateInstance([byte], 18)
    [int]$read = 0

    foreach ($Ver in $VersionTable)  {
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory([int]$handle,$Ver.VersionOffset,$bufferSmall,$Ver.VersionOffsetString.Length,[ref]$read) | Out-Null
        if ([System.Text.Encoding]::ASCII.GetString($bufferSmall, 0, $Ver.VersionOffsetString.Length) -eq $Ver.VersionOffsetString) {
            if ($PSCmdlet.ParameterSetName -eq 'FromProcess') { [Serpen.Wrapper.ProcessMemory]::CloseHandle($handle) | Out-Null}
            return $Ver
        }
    } #end foreach
    [Serpen.Wrapper.ProcessMemory]::CloseHandle($handle) | Out-Null
    throw 'No Version Information'
} #end if ParameterSetName
} #end function

function Connect-D1Session {
    $proc = Get-Process -Name diabl?,hellfir?

    if ($proc -eq $null) {
        throw 'Diablo is not running'
    }

    [System.IntPtr]$MemHandle = [Serpen.Wrapper.ProcessMemory]::OpenProcess(0x8 -bor 0x10 -bor 0x20, $false, $proc.id)
    if ($MemHandle -eq 0) {
        throw 'Unable to open process memory'
    }

    $Version = Get-D1Version -MemoryHandle $MemHandle

    $D1Session = New-Object PSObject -Property @{Process=$proc; Version = $Version.Version; StartOffset = $Version.StartOffset; ProcessMemoryHandle = $MemHandle}
    $D1Session.psobject.TypeNames.Insert(0,'Serpen.Diablo.Session')
    $Global:D1Session = $D1Session
    return $D1Session

}

function DisConnect-D1Session {
param ($D1Session)
    [Serpen.Wrapper.ProcessMemory]::CloseHandle($D1Session.ProcessMemoryHandle) | Out-Null
    $D1Session = $null
    #$global:DiabloSession = $null
    
}

function ConvertFrom-D1String() {
param ([byte[]]$bytes, [int]$start, [int]$len)
    $string = ([System.Text.Encoding]::ASCII.GetString($bytes,$start,$len))
    [int]$pos = $string.IndexOf([char]0)
    if ($pos -gt 0) {
        $string.Substring(0,$pos)
    } else {
        $string
    }
}


function Get-D1Players {
[CmdletBinding()]
param (
    $D1Session = $Global:D1Session
)
    $buffer = ReadMemory -D1Session $D1Session -OffsetType PlayersCount -Length 1

    [byte]$playersCount = $buffer[0]

    Write-Verbose "Found $playersCount Players"
    
    for ([int]$i = 0; $i -lt $playersCount; $i++) {
        $buffer = ReadMemory -D1Session $D1Session -OffsetType Players -Length $PLAYERNAME_LENGTH -n $i
        
        New-Object PSobject -Property @{'Index'=($i+1); 'Name'=(ConvertFrom-D1String $Buffer 0 $PLAYERNAME_LENGTH)}
    }

}

function Get-D1Difficulty {
param (
    $D1Session = $Global:D1Session
)

    $buffer = ReadMemory -D1Session $D1Session -OffsetType Difficulty -Length 1

    $DIFFICULTY_ENUM[$Buffer[0]]
}

function Set-D1Difficulty {
param (
    [Parameter(Mandatory=$true)][ValidateSet('Normal','Nightmare','Hell')][String]$Difficulty,
    $D1Session = $Global:D1Session
)

    Test-D1ValidSession -D1Session $D1Session

    [int]$read = 1

    [byte]$DifficultyIndex = 0
    switch ($Difficulty) {
        'Normal' {$DifficultyIndex = 0}
        'Nightmare' {$DifficultyIndex = 1}
        'Hell' {$DifficultyIndex = 2}
    }

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,(GetVersionsSpecificOffset -D1Session $D1Session 'Difficulty'),$DifficultyIndex,1,[ref]$read)) {
        Write-Error 'Could not set Difficulty'
    } else {
        Write-Warning 'Takes affect in next game'
    }
}

function Get-D1Character {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $D1Session = $Global:D1Session
)

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    #if (!(Test-ValidDiabloPlayer $PlayerIndex -D1Session $D1Session)) {
    #    throw 'No Such Player'
    #}

    $buffer = ReadMemory -D1Session $D1Session -OffsetType Character -Index ($PlayerIndex) -Length ([Serpen.Diablo.Character+PlayerMemStruct]::Size())

    return [Serpen.Diablo.Character]::new($buffer)

    <#
    switch ($buffer[$TYPE_OFFSET]) {
        0 {$Properties.Add('Mana Base', 1*$buffer[$STAT_OFFSET+8]+1*$buffer[$LVL_OFFSET]-1)}
        1 {$Properties.Add('Mana Base', 1*$buffer[$STAT_OFFSET+8]+2*$buffer[$LVL_OFFSET]+5)}
        2 {$Properties.Add('Mana Base', 2*$buffer[$STAT_OFFSET+8]+2*$buffer[$LVL_OFFSET]-2)}
    }

    switch ($buffer[$TYPE_OFFSET]) {
        0 {$Properties.Add('Life Base', 2*$buffer[$STAT_OFFSET+24]+2*$buffer[$LVL_OFFSET]+18)}
        1 {$Properties.Add('Life Base', 1*$buffer[$STAT_OFFSET+24]+2*$buffer[$LVL_OFFSET]+23)}
        2 {$Properties.Add('Life Base', 1*$buffer[$STAT_OFFSET+24]+1*$buffer[$LVL_OFFSET]+9)}
    }

    $char = New-Object PSObject -Property $Properties
    $char.psobject.TypeNames.Insert(0,'Serpen.Diablo.CharacterStats')
    $char
    #>
}

function Get-D1StoreItems {
param (
    [ValidateSet('Wirt','Griswold Premium','Griswold Basic','Pepin','Adria')][String]$Store,
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    switch ($Store) {
        'Wirt' {$curSO = (GetVersionsSpecificOffset -D1Session $D1Session 'Store'); $count = 1}
        'Griswold Premium' {$curSO = (GetVersionsSpecificOffset -D1Session $D1Session 'Store') - 0x18CA8 + 0x18E20; $count = 6}
        'Griswold Basic'  {$curSO = (GetVersionsSpecificOffset -D1Session $D1Session 'Store') - 0x18CA8 + 0x22740; $count = 20}
        'Pepin' {$curSO = (GetVersionsSpecificOffset -D1Session $D1Session 'Store') - 0x18CA8 + 0x20750; $count = 20}
        'Adria' {$curSO = (GetVersionsSpecificOffset -D1Session $D1Session 'Store') - 0x18CA8 + 0x1ea88; $count = 20}
    }

    for ([int]$i = 0; $i -lt $count; $i++) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset ($curSO + ($i*$ITEM_SIZE))
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        } else {
            break
        }
    }
}


function Get-D1TownPortal {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $D1Session = $Global:D1Session
)
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    if (!(Test-ValidDiabloPlayer $PlayerIndex)) {
        throw 'No Such Player'
    }

    $buffer = ReadMemory -D1Session $D1Session -OffsetType TownPortal -n $PlayerIndex -Length 24
    
    if ($buffer[0] -eq 0xFF) {
        Write-Verbose 'No TownPortal'
        return
    }

    $Properties.Add('Open', [boolean][System.BitConverter]::ToInt32($buffer,0))
    $Properties.Add('Dungeontype', $DUNGEONTYPES_ENUM[[System.BitConverter]::ToInt32($buffer,16)])
    $Properties.Add('Dungeon', [System.BitConverter]::ToInt32($buffer,12))
    $Properties.Add('X', [System.BitConverter]::ToInt32($buffer,4))
    $Properties.Add('Y', [System.BitConverter]::ToInt32($buffer,8))
    $Properties.Add('Quest', $QUESTREGION_ENUM[[System.BitConverter]::ToInt32($buffer,20)])

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Position')
    $returnobject
}

#not for mp
function Get-D1Entrances {
param (
    $D1Session = $Global:D1Session
)
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    $buffer = ReadMemory -D1Session $D1Session -OffsetType Entrance -Length 1
    
    $Properties.Add('Dungeon', $true)
    $Properties.Add('Catacombs', 1 -eq ($buffer[0] -band 1))
    $Properties.Add('Caves', 2 -eq ($buffer[0] -band 2))
    $Properties.Add('Hell', 4 -eq ($buffer[0] -band 4))

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Entrances')
    $returnobject
}

function Enable-D1Entrances {
param (
    [Switch]$Catacombs,
    [Switch]$Caves,
    [Switch]$Hell,
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 0

    $buffer[0] = [byte]($Catacombs.ToBool())*1 + [byte]$Caves.ToBool()*2 + [byte]$Hell.ToBool()*4

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,(GetVersionsSpecificOffset -D1Session $D1Session 'Entrance'),$buffer,$buffer.length,[ref]$read)) {
        Write-Error 'Could not set DiabloEntrances'
    }
    

}

function Get-D1CharacterPosition {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $D1Session = $Global:D1Session
)
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    #if (!(Test-ValidDiabloPlayer $PlayerIndex)) {
        #throw 'No Such Player'
    #}

    $buffer = ReadMemory -D1Session $D1Session -OffsetType Position -Index $PlayerIndex -Length 0x100

    $Properties.Add('Dungeon', $buffer[0x3C])
    $Properties.Add('X', $buffer[0x40])
    $Properties.Add('Y', $buffer[0x44])

    $Properties.Add('Goto X', $buffer[0x60])
    $Properties.Add('Goto Y', $buffer[0x54])

    $Properties.Add('Direction', $Dir[$buffer[0x78]])

    $Properties.Add('Mode', @('Stand','Go Up','Go Down','Go Queer','Attack','Bow','Block??','Hurt','Dead','Spell','Portal',11,12)[$buffer[0x8]])
    $Properties.Add('Mode2', $buffer[0x8])

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Position')
    $returnobject
}

function Set-D1ItemProperty {
param (
    [Parameter(Mandatory=$true)]
    [Serpen.Diablo.Item]$Item,
    [Parameter(Mandatory=$true,ParameterSetName='PropertyValue')]
    [String]$Property,
    [Parameter(Mandatory=$true,ParameterSetName='PropertyValue')]
    [int16]$value,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [int16]$DamageFrom,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [int16]$DamageTo,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [byte]$ResistAll,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [int16]$AllAttributes,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [int16]$Armor,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [byte]$DurabilityFrom,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [byte]$DurabilityTo,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [Serpen.Diablo.eSpell]$Spell = -1,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [uint16]$Charges,
    [Parameter(Mandatory=$false,ParameterSetName='DirectProperty')]
    [uint16]$ChargesMax,
    $D1Session = $Global:D1Session
)

    Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0

    if ($PSCmdLet.ParameterSetName -eq 'PropertyValue') {
        $PropOffset = -1
        switch ($Property) {
            'Identified' {$PropOffset = $ITM_IDENTIFIED_OFFSET}
            'Spell'      {$PropOffset = $ITM_SPELL_OFFSET}
            'Base Price' {$PropOffset = $ITM_BASEPRICE_OFFSET}
            'Armor' {$PropOffset = $ITM_ARMOR_OFFSET}
        }
    } else {
        if ($DamageFrom -ne 0) {
            $PropOffset = $ITM_DMG_FROM_OFFSET
            $value = $DamageFrom
        } elseif ($DamageTo -ne 0) {
            $PropOffset = $ITM_DMG_TO_OFFSET
            $value = $DamageTo
        } elseif ($ResistAll -ne 0) {
            $PropOffset = $ITM_RESISTALL_OFFSETS
            $value = $ResistAll
        } elseif ($AllAttributes -ne 0) {
            $PropOffset = $ITM_ALLATTRIB_OFFSETS
            $value = $AllAttributes
        } elseif ($Armor -ne 0) {
            $PropOffset = $ITM_ARMOR_OFFSET
            $value = $Armor
        } elseif ($DurabilityFrom -ne 0) {
            $PropOffset = $ITM_DUR_FROM_OFFSET
            $value = $DurabilityFrom
        } elseif ($DurabilityTo -ne 0) {
            $PropOffset = $ITM_DUR_TO_OFFSET
            $value = $DurabilityTo
        } elseif ($Spell -ne -1) {
            $PropOffset = $ITM_SPELL_OFFSET
            $value = $Spell
        } elseif ($Charges -ne 0) {
            $PropOffset = $ITM_CHARGES_FROM_OFFSET
            $value = $Charges
        } elseif ($ChargesMax -ne 0) {
            $PropOffset = $ITM_CHARGES_TO_OFFSET
            $value = $ChargesMax
        }
    }

    if ($PropOffset -eq -1) {
        throw "Property $Property not found"
    }

    $buffer = [System.BitConverter]::GetBytes($value)

    foreach ($po in $PropOffset) {
        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$item.MemoryOffset + $po,$buffer,4,[ref]$read)) {
            Write-Error "Could not set property $Property for item '$($item.identifiedname)'"
        }
    }
}

function Invoke-D1IdentifyItem {
param (
    [Parameter(Mandatory=$true,ParameterSetName='Item')]
    [Serpen.Diablo.Item]$Item,
    #[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='Offset')][uint64]$MemoryOffset,
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    if ($PSCmdlet.ParameterSetName -eq 'Item') {
        $MemoryOffset = $Item.MemoryOffset   
    }

    [int]$write = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$MemoryOffset + 0x38, 1, 1,[ref]$write)) {
        Write-Error "Could not identify item '$($item.identifiedname)'"
    }
}

function Repair-D1Item {
param (
    [Parameter(Mandatory=$true,ParameterSetName='Item')]
    [Serpen.Diablo.Item]$Item,
    #[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='Offset')][uint64]$MemoryOffset,
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    if ($PSCmdlet.ParameterSetName -eq 'Item') {
        $MemoryOffset = $Item.MemoryOffset   
    }

    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$MemoryOffset + $ITM_DUR_FROM_OFFSET,$item.DurabilityMax,1,[ref]$read)) {
        Write-Error "Could not repair item '$($item.identifiedname)'"
    }
}

function Restore-D1ItemCharges {
param (
    [Parameter(Mandatory=$true,ParameterSetName='Item')][Serpen.Diablo.Item]$Item,
    #[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='Offset')][uint64]$MemoryOffset,
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    if ($PSCmdlet.ParameterSetName -eq 'Item') {
        $MemoryOffset = $Item.MemoryOffset   
    }

    [int]$write = 0

    if ($item.ChargesMax -eq 0) {
        throw 'Item has no charges'
    }

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$MemoryOffset + $ITM_CHARGES_FROM_OFFSET,$item.ChargesMax,1,[ref]$write)) {
        Write-Error "Could not restore item charges '$($item.identifiedname)'"
    }
}

function Set-D1Points {
param (
    [Parameter(Mandatory=$true)][byte]$Points,
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,(GetVersionsSpecificOffset -D1Session $D1Session 'Character')+$LEVELUP_OFFSET,$Points,1,[ref]$read)) {
        Write-Error 'Could not set DiabloPoints'
    }
    

}

function Get-D1Spell {
param (
    [Serpen.Diablo.eSpell[]]$Spell,
    $D1Session = $Global:D1Session
)
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    $buffer = ReadMemory -D1Session $D1Session -OffsetType Spell -Length ($SPELL_NAMES.Length-1+4)
    
    #if ($Spell -eq "*" -or $Spell -eq $null) {$Spell = $SPELL_NAMES}
    if ($Spell -eq "All" -or $Spell -eq $null) {$Spell = [enum]::GetValues([Serpen.Diablo.eSpell]) | Where-Object {$_ -ge 0}}

    foreach ($spellSingle in $Spell) {
        
        $spellflags = [System.BitConverter]::ToInt32($buffer,$SPELL_NAMES.Length-1)
        $spellLevel = $buffer[$spellSingle]

        $returnobject = New-Object Serpen.Diablo.Spell
        $returnobject.Spell = $spellSingle
        $returnobject.Index = ([int]$spellSingle)
        $returnobject.Spellbook = "Page $($SPELLBOX_X[$spellSingle]).$($SPELLBOX_Y[$spellSingle])"
        $returnobject.Enabled = ($spellSingle -eq ($spellflags -band $spellSingle ))
        $returnobject.Level = $spellLevel

        $returnobject
    }
}
function Set-D1Spell {
param (
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Serpen.Diablo.eSpell]$Spell,
    [Parameter(Mandatory=$true)][ValidateRange(0,15)]
    [byte]$Level,
    $D1Session = $Global:D1Session
)
begin {
    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], 4)
    [int]$read = 0
}

process {

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle,$D1Session.StartOffset+$SPELLFLAGS_OFFSET,$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $spellflags = [System.BitConverter]::ToInt32($buffer,0)
    $spellflags = $spellflags -bor [math]::Pow(2, $Spell)
    $buffer = [System.BitConverter]::GetBytes($spellflags)

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$D1Session.StartOffset+$SPELLFLAGS_OFFSET,$buffer,$buffer.length,[ref]$read)) {
        throw "Could not write Spellflags for $Spell"
    }

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,(GetVersionsSpecificOffset -D1Session $D1Session 'Spell')+$Spell,$Level,1,[ref]$read)) {
        throw "Could not write Spelllevel for $Spell"
    }
} #end process

}

function Get-D1Quests {
param (
    $D1Session = $Global:D1Session
)

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    $buffer = ReadMemory -D1Session $D1Session -OffsetType Quest -Length (0x18*16)

    for ([int]$i=0; $i -lt 16; $i++) {
        New-Object PSobject -Property @{DungeonLevel=$buffer[$i*0x18]; Name=$QUEST_ENUM[$buffer[1+$i*0x18]]; Active=$QUEST_STATE[$buffer[2+$i*0x18]]; QuestLevel=$buffer[12+$i*0x18]}
    }
}


function Get-D1MonsterKills {
param (
    [String[]]$Monster,
    $D1Session = $Global:D1Session
)

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    $buffer = ReadMemory -D1Session $D1Session -OffsetType MonsterKills -Length ($Monster_ENUM.Length*4)

    Write-Debug ($buffer -join ' ')

    if ($Monster -eq "*" -or $Monster -eq $null) {$Monster = $Monster_ENUM}

    foreach ($MonsterSingle in $Monster) {
        if ($PSVersionTable.PSVersion.Major -gt 2) {
            $Properties = [ordered]@{}
        } else {
            $Properties = @{}
        }

        $MonsterIndex = -1
        for ([int]$i=0; $i -lt $Monster_ENUM.Length; $i++) {
            if ($Monster_ENUM[$i] -eq $MonsterSingle) {
                $MonsterIndex = $i
                $MonsterSingle = $Monster_ENUM[$i]
                break
            }
        } #foreach

        if ($MonsterIndex -eq -1) {
            throw "$Spell not found"
        }
        
        $MonsterKills = [System.BitConverter]::ToInt32($buffer,$MonsterIndex*4)

        $Properties.Add('Monster', $MonsterSingle)
        $Properties.Add('Kills', $MonsterKills)

        $returnobject = New-Object PSObject -Property $Properties
        $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.MonsterKill')
        $returnobject
    } #foreach
}

function Get-D1HeroEquipment {
param (
    [ValidateSet('All', 'Helm','Amulett','LeftHand','RightHand','Plate','LeftRing','RightRing')][String[]]$Position = 'All',
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    $offsets = @()

    if ($Position -contains 'All') {
        $offsets = 0..6
    } else {
        if ($Position -contains 'Helm') {
            $offsets += 0
        }
        if ($Position -contains 'LeftRing') {
            $offsets += 1
        }
        if ($Position -contains 'RightRing') {
            $offsets += 2
        }
        if ($Position -contains 'RightHand') {
            $offsets += 3
        }
        if ($Position -contains 'LeftHand') {
            $offsets += 4
        }
        if ($Position -contains 'Amulett') {
            $offsets += 5
        }
        if ($Position -contains 'Plate') {
            $offsets += 6
        }
    }

    foreach ($i in $offsets) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset (GetVersionsSpecificOffset -D1Session $D1Session 'Inventory' $i)
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        }
    }
}

function Get-D1Belt {
param (
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    $Offset = GetVersionsSpecificOffset -D1Session $D1Session 'Belt'
    if ($offset -eq -1) {
        throw [System.NotSupportedException]"Belt not supported in this version"
    }

    for ([int]$i = 0; $i -lt 8; $i++) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset (GetVersionsSpecificOffset -D1Session $D1Session 'Belt' $i)
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        }
    }
}

function Get-D1HeroInventory {
param (
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    for ([int]$i = 0; $i -lt 18; $i++) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset (GetVersionsSpecificOffset -D1Session $D1Session 'Rucksack' $i)
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        } else {
            break
        }
    }
}

function Get-D1Monsters {
param (
    $D1Session = $Global:D1Session,
    $Index = -1
)

    $from = $Index
    $to = $Index
    if ($index -eq -1) {
        $from = 0
        $to = 200
    }
    $MONSTER_SIZE = 0xE4

    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], $MONSTER_SIZE)

    $REL = +32

    # first 4 are players golems

    $MO = 0x4C9B90
    
    #del f:\d1\monster-buffer.bin -ea silentlycontinue

    

    for ([int]$i=$from; $i -le $to; $i++) {
        $buffer = ReadMemory -D1Session $D1Session -OffsetType monsters -Index ($i++) -Length (0xE4)

        $end = 0x40
        if ($buffer[0+$REL] -eq 0 -and $buffer[4+$REL] -eq 0) {
            Write-warning "Monster count $i $($buffer[$end+$REL])"
            break
        }

        $Properties = GenerateReturnObject

        $Properties.Add('i', $i)

        $Properties.Add('active', $buffer[0x40+$REL])
        $Properties.Add('_offset', (GetVersionsSpecificOffset -Type Monsters -n ($i++)))

        $Properties.Add('mode', [System.BitConverter]::ToInt32($buffer,0x4))

        $Properties.Add('X', $buffer[0x0+$REL])
        $Properties.Add('Y', $buffer[0x4+$REL])

        $Properties.Add('Goto X', $buffer[0x8+$REL])
        $Properties.Add('Goto Y', $buffer[0xC+$REL])

        $Properties.Add('Old X', $buffer[0x10+$REL])
        $Properties.Add('Old Y', $buffer[0x14+$REL])


        $Properties.Add('HP', [System.BitConverter]::ToInt32($buffer,0x74+$REL))
        $Properties.Add('HP max', [System.BitConverter]::ToInt32($buffer,0x70+$REL))

        $Properties.Add('Min Damge', $buffer[0x74+$REL+0x2c])
        $Properties.Add('Max Damge', $buffer[0x74+$REL+0x2c+1])

        $returnobject = New-Object PSObject -Property $Properties
        $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Monster')
        $returnobject
    }
}

function GenerateReturnObject {
param ([string]$Type)
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        return [ordered]@{}
    } else {
        return @{}
    }
}

#missing properties
#   left click action, right click action, inventory space, beltable, level config

function ConvertTo-D1Item {
param (
    [Parameter(ParameterSetName='File')][String]$File,
    [Parameter(ParameterSetName='Byte')][byte[]]$buffer,
    [Parameter(ParameterSetName='Session')][object]$D1Session,
    [Parameter(ParameterSetName='Session')][int]$Offset
)
    
    if ($PSCmdlet.ParameterSetName -eq 'File') {
        $object = New-Object Serpen.Diablo.Item $File

        Write-Verbose "Processing $File"
    } elseif ($PSCmdlet.ParameterSetName -eq 'Byte') {
        $object = New-Object Serpen.Diablo.Item @(, $buffer)
    } else {
        $buffer = [array]::CreateInstance([byte], 0x170)
        [int]$read = 0
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle,$Offset,$buffer,$buffer.length,[ref]$read) | Out-Null
        $object = New-Object Serpen.Diablo.Item -ArgumentList @(, $buffer)
        $object | Add-Member -MemberType NoteProperty -Name MemoryOffset -Value $Offset
    }
    
    $object
}

function Export-D1Item {
param (
    [Object]$Item,
    [String]$File,
    $D1Session = $Global:D1Session
)
    Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0
    $buffer = [array]::CreateInstance([byte], $ITEM_SIZE)

    if (![Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle,$item.MemoryOffset,$buffer,$buffer.length,[ref]$read)) {
        throw "Could not read item '$($item.identifiedname)'"
    }

    $filestram = [system.io.file]::Create($file)
    $filestram.Write($buffer, 0, $buffer.length)
    $filestram.Close()

}

function Open-D1UI {
param (
    [Switch]$Character,
    [Switch]$Inventory,
    [Switch]$Spellbook,
    [Switch]$QuestLog,
    [Switch]$AutoMap,
    [Switch]$Spells,
    $D1Session = $Global:D1Session
)

    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 1

    $addresses = @()

    if ($Character) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Char'
    }
    if ($Inventory) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Inventory'
    }
    if ($Spellbook) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Spellbook'
    }
    if ($QuestLog) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Questlog'
    }
    if ($AutoMap) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_AutoMap'
    }
    if ($Spells) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Spells'
    }

    foreach ($addr in $addresses) {
        [Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$addr,$buffer,1,[ref]$read) | Out-Null
        if ($buffer[0] -ne 1) {
        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$addr,1,1,[ref]$read)) {
                Write-Error 'Could not Open UI'
            }
        }
    }
}

function Close-D1UI {
param (
    [Switch]$Character,
    [Switch]$Inventory,
    [Switch]$Spellbook,
    [Switch]$QuestLog,
    [Switch]$AutoMap,
    [Switch]$Spells,
    $D1Session = $Global:D1Session
)

    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 1

    $addresses = @()

    if ($Character) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Char'
    }
    if ($Inventory) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Inventory'
    }
    if ($Spellbook) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Spellbook'
    }
    if ($QuestLog) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Questlog'
    }
    if ($AutoMap) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_AutoMap'
    }
    if ($Spells) {
        $addresses += GetVersionsSpecificOffset -D1Session $D1Session 'UI_Spells'
    }

    foreach ($addr in $addresses) {
        [Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$addr,$buffer,1,[ref]$read)
        if ($buffer[0] -ne 1) {
        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,$addr,0,1,[ref]$read)) {
                Write-Error 'Could not Close UI'
            }
        }
    }
}


function Suspend-D1Game {
	
	Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte],1)
    $Buffer[0]=2

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, (GetVersionsSpecificOffset -D1Session $D1Session 'Pause'), $buffer, $buffer.length,[ref]$read)) {
        Write-Error 'Unable to suspend game'
    }
}

function Resume-D1Game {
	
	Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte],1)
    $Buffer[0]=0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, (GetVersionsSpecificOffset -D1Session $D1Session 'Pause'), $buffer, $buffer.length,[ref]$read)) {
        Write-Error 'Unable to suspend game'
    }
}

function Test-ValidDiabloPlayer {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $D1Session = $Global:D1Session
)

    $buffer = ReadMemory -D1Session $D1Session -OffsetType PlayersCount -Length 1
    
    if ($PlayerIndex -gt $buffer[0]) {
        return $false
    } else {
        return $true
    }
}

function Test-D1ValidSession {
param (
    $D1Session = $Global:D1Session
)
	if ($D1Session -eq $null) {
        throw 'No valid DiabloSession'
    }

    if ($D1Session.StartOffset -le 0) {
        throw 'No valid DiabloSession'
    }
}

function ReadMemory {
param (
    $D1Session = $Global:D1Session,
    [String]$OffsetType,
    [uint16][Alias('n')]$Index=0,
    [uint16]$Length
)

    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], $Length)
    [int]$read = 0

    $offset = (GetVersionsSpecificOffset -D1Session $D1Session $OffsetType $Index)

    if ($offset -le 0) {
        throw "$OffsetType not supported in $($D1Session.Version)"
    }

    $ret = [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle,$offset, $buffer, $buffer.Length, [ref]$read) | Out-Null
    
    if ($read -eq $Length) {
        return $buffer
    } else {
        throw "Could not read $ret = $read"
    }
}

#works only after once opened menu
function Get-D1GameSettings {
param (
    $D1Session = $Global:D1Session
)
       
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }
    [byte[]]$buffer = ReadMemory -OffsetType GameSettings -len 0x29

    $Properties.Add("MusicVolume", $buffer[0])
    $Properties.Add("SoundVolume", $buffer[0xC])
    $Properties.Add("Gamma", $buffer[0x18])

    if ($buffer[0x28] -eq 0xa0) {
        $Properties.Add("ColorCycling", $true)
    } else {
        $Properties.Add("ColorCycling", $false)
    }
    #$buffer
    New-Object -TypeName psobject -Property $Properties

}


function New-D1TownPortal {
param (
    [Parameter(Mandatory=$true)][byte][ValidateRange(1,16)]$Dungeon,
    [Parameter(Mandatory=$true)][byte]$X,
    [Parameter(Mandatory=$true)][byte]$Y,
    $D1Session = $Global:D1Session
)

    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], 24)
    [int]$write = 0

    $buffer[00] = 1
    $buffer[04] = $X
    $buffer[08] = $y
    $buffer[12] = $Dungeon

    if ($Dungeon -eq 0) {
        $buffer[16] = 0
    } elseif ($Dungeon -lt 5) {
        $buffer[16] = 1
    } elseif ($Dungeon -lt 10) {
        $buffer[16] = 2
    } elseif ($Dungeon -lt 15) {
        $buffer[16] = 3
    } elseif ($Dungeon -lt 20) {
        $buffer[16] = 4
    }

    $buffer[20] = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,(GetVersionsSpecificOffset -D1Session $D1Session 'TownPortal'),$buffer,$buffer.length ,[ref]$write)) {
        Write-Error 'Could not open Portal'
    } else {
        Write-Warning "Takes affect after reload"
    }
}

function Enable-D1TownPortal {
param (
    $D1Session = $Global:D1Session
)
    
    [int]$write = 0
    
    Test-D1ValidSession -D1Session $D1Session

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle,(GetVersionsSpecificOffset -D1Session $D1Session 'TownPortal'),1,1,[ref]$write)) {
        Write-Error 'Could not open Portal'
    } else {
        Write-Warning "Takes affect after reload"
    }
}

Export-ModuleMember -Function * -Cmdlet *