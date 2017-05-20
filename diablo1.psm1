$PSScriptRoot2 = Split-Path $MyInvocation.MyCommand.Path -Parent

Add-Type -path $PSScriptRoot2\Serpen.Wrapper.ProcessMemory.cs
Add-Type -path $PSScriptRoot2\DiabloItem.cs, $PSScriptRoot2\Spell.cs

. "$PSScriptRoot2\definitions.ps1"
. "$PSScriptRoot2\Offsets.ps1"

function Get-DiabloVersion {
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
    Write-Error 'No Version Information'
    
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
    Write-Error 'No Version Information'
} #end if ParameterSetName
} #end function

function Connect-DiabloSession {
    $proc = Get-Process -Name diabl?,hellfir?

    if ($proc -eq $null) {
        Write-Error 'Diablo is not running'
        return
    }

    [System.IntPtr]$MemHandle = [Serpen.Wrapper.ProcessMemory]::OpenProcess(0x8 -bor 0x10 -bor 0x20, $false, $proc.id)
    if ($MemHandle -eq 0) {
        Write-Error 'Unable to open process memory'
        return
    }

    $Version = Get-DiabloVersion -MemoryHandle $MemHandle

    $DiabloSession = New-Object PSObject -Property @{Process=$proc; Version = $Version.Version; StartOffset = $Version.StartOffset; ProcessMemoryHandle = $MemHandle}
    $DiabloSession.psobject.TypeNames.Insert(0,'Serpen.Diablo.Session')
    $global:DiabloSession = $DiabloSession
    return $DiabloSession

}

function DisConnect-DiabloSession {
param ($DiabloSession)
    [Serpen.Wrapper.ProcessMemory]::CloseHandle($DiabloSession.ProcessMemoryHandle) | Out-Null
    $DiabloSession = $null
    #$global:DiabloSession = $null
    
}

function ConvertFrom-DiabloString() {
param ([byte[]]$bytes, [int]$start, [int]$len)
    $string = ([System.Text.Encoding]::ASCII.GetString($bytes,$start,$len))
    [int]$pos = $string.IndexOf([char]0)
    if ($pos -gt 0) {
        $string.Substring(0,$pos)
    } else {
        $string
    }
}


function Get-DiabloPlayers {
[CmdletBinding()]
param (
    $DiabloSession = $Global:DiabloSession
)
    
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte],$PLAYERNAME_LENGTH)

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle, (GetVersionsSpecificOffset 'PlayersCount'),$Buffer,1,[ref]$read) | Out-Null
    
    [byte]$playersCount = $buffer[0]

    Write-Verbose "Found $playersCount Players"
    
    for ([int]$i = 0; $i -lt $playersCount; $i++) {
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Players' $i),$Buffer,$Buffer.length,[ref]$read) | Out-Null
        New-Object PSobject -Property @{'Index'=($i+1); 'Name'=(ConvertFrom-DiabloString $Buffer 0 $PLAYERNAME_LENGTH)}
    }

}

function Get-DiabloDifficulty {
param (
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Difficulty'),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $DIFFICULTY_ENUM[$Buffer[0]]
}

function Set-DiabloDifficulty {
param (
    [Parameter(Mandatory=$true)][ValidateSet('Normal','Nightmare','Hell')][String]$Difficulty,
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 1

    [byte]$DifficultyIndex = 0
    switch ($Difficulty) {
        'Normal' {$DifficultyIndex = 0}
        'Nightmare' {$DifficultyIndex = 1}
        'Hell' {$DifficultyIndex = 2}
    }

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Difficulty'),$DifficultyIndex,1,[ref]$read)) {
        Write-Error 'Could not set Difficulty'
    } else {
        Write-Warning 'Takes affect in next game'
    }
}

function Get-DiabloCharacterStats {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 0x200)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    if (!(Test-ValidPlayer $PlayerIndex)) {
        Write-Error 'No Such Player'
        return
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Character' $PlayerIndex),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $Properties.Add('Name', (ConvertFrom-DiabloString -bytes $buffer $PLAYERNAME_OFFSET $PLAYERNAME_LENGTH))
    $Properties.Add('Type', $TYPE_ENUM[$buffer[$TYPE_OFFSET]])
    $Properties.Add('Alive', ![bool]$buffer[$POSSIBLE_IS_ALIVE_OFFSET])

    for ([int]$i = 0; $i -lt $STAT_ENUM.Length; $i++) {
        $Properties.Add("$($STAT_ENUM[$i]) Base", [System.BitConverter]::ToInt32($buffer,$STAT_OFFSET+$i*8))
        $Properties.Add("$($STAT_ENUM[$i]) Now", [System.BitConverter]::ToInt32($buffer,$STAT_OFFSET+$i*8-4))
    }

    if ($PlayerIndex -eq 1) {
        $Properties.Add('Experience', ([System.BitConverter]::ToInt32($buffer, $EXP_OFFSET)))
        $Properties.Add('Next Level Experience', ([System.BitConverter]::ToInt32($buffer, $EXP_OFFSET+8)))
    }
    $Properties.Add('Level', $buffer[$LVL_OFFSET])
    if ($PlayerIndex -eq 1) {
        $Properties.Add('Levelup Points', $buffer[$LEVELUP_OFFSET])

        $Properties.Add('Gold', ([System.BitConverter]::ToInt32($buffer, $GOLD_OFFSET)))
    }

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
}

function Get-DiabloStoreItems {
param (
    [ValidateSet('Wirt','Griswold Premium','Griswold Basic','Pepin','Adria')][String]$Store,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    switch ($Store) {
        'Wirt' {$curSO = (GetVersionsSpecificOffset 'Store'); $count = 1}
        'Griswold Premium' {$curSO = (GetVersionsSpecificOffset 'Store') - 0x18CA8 + 0x18E20; $count = 6}
        'Griswold Basic'  {$curSO = (GetVersionsSpecificOffset 'Store') - 0x18CA8 + 0x22740; $count = 20}
        'Pepin' {$curSO = (GetVersionsSpecificOffset 'Store') - 0x18CA8 + 0x20750; $count = 20}
        'Adria' {$curSO = (GetVersionsSpecificOffset 'Store') - 0x18CA8 + 0x1ea88; $count = 20}
    }

    for ([int]$i = 0; $i -lt $count; $i++) {
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset ($curSO + ($i*$ITEM_SIZE))
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        } else {
            break
        }
    }
}


function Get-DiabloTownPortal {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }


    $buffer = [array]::CreateInstance([byte], 10)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    if (!(Test-ValidPlayer $PlayerIndex)) {
        Write-Error 'No Such Player'
        return
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'TownPortal' $PlayerIndex),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    if ($buffer[0] -eq 0xFF) {
        Write-Verbose 'No TownPortal'
        return
    }

    $Properties.Add('Dungeontype', $DUNGEONTYPES_ENUM[$buffer[3]])
    $Properties.Add('Dungeon', $buffer[2])
    $Properties.Add('X', $buffer[0])
    $Properties.Add('Y', $buffer[1])
    $Properties.Add('Quest', $QUESTREGION_ENUM[$buffer[4]])

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Position')
    $returnobject
}

#not for mp
function Get-DiabloEntrances {
param (
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Entrance'),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $Properties.Add('Dungeon', $true)
    $Properties.Add('Catacombs', 1 -eq ($buffer[0] -band 1))
    $Properties.Add('Caves', 2 -eq ($buffer[0] -band 2))
    $Properties.Add('Hell', 4 -eq ($buffer[0] -band 4))

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Entrances')
    $returnobject
}

function Enable-DiabloEntrances {
param (
    [Switch]$Catacombs,
    [Switch]$Caves,
    [Switch]$Hell,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 0

    $buffer[0] = [byte]($Catacombs.ToBool())*1 + [byte]$Caves.ToBool()*2 + [byte]$Hell.ToBool()*4

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Entrance'),$buffer,$buffer.length,[ref]$read)) {
        Write-Error 'Could not set DiabloEntrances'
    }
    

}

function Get-DiabloCharacterPosition {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 0x100)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    if (!(Test-ValidPlayer $PlayerIndex)) {
        Write-Error 'No Such Player'
        return
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Position' $PlayerIndex),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

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

function Set-DiabloItemProperty {
param (
    [Parameter(Mandatory=$true)]
    [Object]$Item,
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
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

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
        Write-Error "Property $Property not found"
        return
    }

    $buffer = [System.BitConverter]::GetBytes($value)

    foreach ($po in $PropOffset) {
        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$item.MemoryOffset + $po,$buffer,4,[ref]$read)) {
            Write-Error "Could not set property $Property for item '$($item.identifiedname)'"
        }
    }
}

function Invoke-DiabloIdentifyItem {
param (
    [Parameter(Mandatory=$true,ParameterSetName='Item')]
    [Serpen.Diablo.Item]$Item,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='Offset')]
    [uint64]$MemoryOffset,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    if ($PSCmdlet.ParameterSetName -eq 'Item') {
        $MemoryOffset = $Item.MemoryOffset   
    }

    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$MemoryOffset + 0x38,1,1,[ref]$read)) {
        Write-Error "Could not identify item '$($item.identifiedname)'"
    }
}

function Repair-DiabloItem {
param (
    [Parameter(Mandatory=$true,ParameterSetName='Item')]
    [Serpen.Diablo.Item]$Item,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='Offset')]
    [uint64]$MemoryOffset,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    if ($PSCmdlet.ParameterSetName -eq 'Item') {
        $MemoryOffset = $Item.MemoryOffset   
    }

    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$MemoryOffset + $ITM_DUR_FROM_OFFSET,$item.DurabilityMax,1,[ref]$read)) {
        Write-Error "Could not repair item '$($item.identifiedname)'"
    }
}

function Set-DiabloPoints {
param (
    [Parameter(Mandatory=$true)][byte]$Points,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Character')+$LEVELUP_OFFSET,$Points,1,[ref]$read)) {
        Write-Error 'Could not set DiabloPoints'
    }
    

}

function Get-DiabloSpell {
param (
    [Serpen.Diablo.eSpell[]]$Spell,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }


    $buffer = [array]::CreateInstance([byte], $SPELL_NAMES.Length-1+4)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Spell'),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    #if ($Spell -eq "*" -or $Spell -eq $null) {$Spell = $SPELL_NAMES}
    if ($Spell -eq "All" -or $Spell -eq $null) {$Spell = [enum]::GetValues([Serpen.Diablo.eSpell]) | ? {$_ -ge 0}}

    foreach ($spellSingle in $Spell) {
        
        $spellflags = [System.BitConverter]::ToInt32($buffer,$SPELL_NAMES.Length-1)
        $spellLevel = $buffer[$spellSingle]

        $returnobject = New-Object Serpen.Diablo.Spell
        $returnobject | Add-Member -MemberType NoteProperty -Name Spell -Value $spellSingle
        $returnobject | Add-Member -MemberType NoteProperty -Name Index -Value ([int]$spellSingle)
        $returnobject | Add-Member -MemberType NoteProperty -Name Spellbook -Value "Page $($SPELLBOX_X[$spellSingle]).$($SPELLBOX_Y[$spellSingle])"
        $returnobject | Add-Member -MemberType NoteProperty -Name Enabled -Value ($spellSingle -eq ($spellflags -band $spellSingle ))
        $returnobject | Add-Member -MemberType NoteProperty -Name Level -Value $spellLevel

        $returnobject
    }
}
function Set-DiabloSpell {
param (
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Serpen.Diablo.eSpell]$Spell,
    [Parameter(Mandatory=$true)][ValidateRange(0,15)]
    [byte]$Level,
    $DiabloSession = $Global:DiabloSession
)
begin {
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 4)
    [int]$read = 0
}

process {

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$SPELLFLAGS_OFFSET,$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $spellflags = [System.BitConverter]::ToInt32($buffer,0)
    $spellflags = $spellflags -bor [math]::Pow(2, $Spell)
    $buffer = [System.BitConverter]::GetBytes($spellflags)

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$SPELLFLAGS_OFFSET,$buffer,$buffer.length,[ref]$read)) {
        Write-Error "Could not write Spellflags for $Spell"
        return
    }

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'Spell')+$Spell,$Level,1,[ref]$read)) {
        Write-Error "Could not write Spelllevel for $Spell"
        return
    }
} #end process

}

#function Import-DiabloItem {}

function Get-DiabloQuests {
param (
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 0x18*16)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    $offset = (GetVersionsSpecificOffset 'Quest')

    if ($offset -eq -1) {
        throw [System.NotSupportedException]'Quest not supported in this version'
        return
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$Offset,$buffer,$buffer.length,[ref]$read) | Out-Null

    for ([int]$i=0; $i -lt 16; $i++) {
        New-Object PSobject -Property @{DungeonLevel=$buffer[$i*0x18]; Name=$QUEST_ENUM[$buffer[1+$i*0x18]]; Active=$QUEST_STATE[$buffer[2+$i*0x18]]; QuestLevel=$buffer[12+$i*0x18]}
    }
}


function Get-DiabloMonsterKills {
param (
    [String[]]$Monster,
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], ($Monster_ENUM.Length)*4)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'MonsterKills'),$buffer,$buffer.length,[ref]$read) | Out-Null
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
            Write-Error "$Spell not found"
            break
        }
        
        $MonsterKills = [System.BitConverter]::ToInt32($buffer,$MonsterIndex*4)

        $Properties.Add('Monster', $MonsterSingle)
        $Properties.Add('Kills', $MonsterKills)

        $returnobject = New-Object PSObject -Property $Properties
        $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.MonsterKill')
        $returnobject
    } #foreach
}

function Get-DiabloHeroEquipment {
param (
    [ValidateSet('All', 'Helm','Amulett','LeftHand','RightHand','Plate','LeftRing','RightRing')][String[]]$Position = 'All',
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

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
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset (GetVersionsSpecificOffset 'Inventory' $i)
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        }
    }
}

function Get-DiabloBelt {
param (
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $Offset = GetVersionsSpecificOffset 'Belt'
    if ($offset -eq -1) {
        throw [System.NotSupportedException]"Belt not supported in this version"
        return
    }

    for ([int]$i = 0; $i -lt 8; $i++) {
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset (GetVersionsSpecificOffset 'Belt' $i)
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        }
    }
}

function Get-DiabloHeroInventory {
param (
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    for ([int]$i = 0; $i -lt 18; $i++) {
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset (GetVersionsSpecificOffset 'Rucksack' $i)
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        } else {
            break
        }
    }
}

function Get-DiabloMonsters {
param (
    $DiabloSession = $Global:DiabloSession
)

    $MONSTER_SIZE = 0xE4

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], $MONSTER_SIZE)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    $REL = 0

    # first 4 are players golems

    $MO = 0x4C9B90
    
    #del f:\d1\monster-buffer.bin -ea silentlycontinue

    for ([int]$i=0; $i -le 200; $i++) {
    #foreach ($i in 68) {
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$MO + ($i*$MONSTER_SIZE) ,$buffer,$buffer.length,[ref]$read) | Out-Null
        #(($buffer | % {"{0:x2}" -f $_}) -join ' ') | Out-File -Append -FilePath f:\d1\monster-buffer.bin
        $end = 0x40
        if ($buffer[0] -eq 0 -and $buffer[4] -eq 0) {
            Write-warning "Monster count $i $($buffer[$end])"
            break
        }

        if ($PSVersionTable.PSVersion.Major -gt 2) {
            $Properties = [ordered]@{}
        } else {
            $Properties = @{}
        }

        $Properties.Add('n', $i)

        $Properties.Add('active', $buffer[0x40])
        $Properties.Add('_offset', $MO + ($i*$MONSTER_SIZE))

        $Properties.Add('X', $buffer[0x0+$REL])
        $Properties.Add('Y', $buffer[0x4+$REL])

        $Properties.Add('Goto X', $buffer[0x10+$REL])
        $Properties.Add('Goto Y', $buffer[0x14+$REL])


        $Properties.Add('HP', [System.BitConverter]::ToInt32($buffer,0x74+$REL))
        $Properties.Add('HP max', [System.BitConverter]::ToInt32($buffer,0x70+$REL))

        $returnobject = New-Object PSObject -Property $Properties
        $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Monster')
        $returnobject
    }
}

#missing properties
#   left click action, right click action, inventory space, beltable, level config

function ConvertTo-DiabloItem {
param (
    [Parameter(ParameterSetName='File')][String]$File,
    [Parameter(ParameterSetName='Byte')][byte[]]$buffer,
    [Parameter(ParameterSetName='Session')][object]$DiabloSession,
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
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$Offset,$buffer,$buffer.length,[ref]$read) | Out-Null
        $object = New-Object Serpen.Diablo.Item -ArgumentList @(, $buffer)
        $object | Add-Member -MemberType NoteProperty -Name MemoryOffset -Value $Offset
    }
    
    $object
}

function Export-DiabloItem {
param (
    [Object]$Item,
    [String]$File,
    $DiabloSession = $Global:DiabloSession
)
    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    [int]$read = 0
    $buffer = [array]::CreateInstance([byte], $ITEM_SIZE)

    if (![Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$item.MemoryOffset,$buffer,$buffer.length,[ref]$read)) {
        Write-Error "Could not read item '$($item.identifiedname)'"
    }

    $filestram = [system.io.file]::Create($file)
    $filestram.Write($buffer, 0, $buffer.length)
    $filestram.Close()

}

function Open-DiabloUI {
param (
    [Switch]$Character,
    [Switch]$Inventory,
    [Switch]$Spellbook,
    [Switch]$QuestLog,
    [Switch]$AutoMap,
    [Switch]$Spells,
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 1

    $addresses = @()

    if ($Character) {
        $addresses += GetVersionsSpecificOffset 'UI_Char'
    }
    if ($Inventory) {
        $addresses += GetVersionsSpecificOffset 'UI_Inventory'
    }
    if ($Spellbook) {
        $addresses += GetVersionsSpecificOffset 'UI_Spellbook'
    }
    if ($QuestLog) {
        $addresses += GetVersionsSpecificOffset 'UI_Questlog'
    }
    if ($AutoMap) {
        $addresses += GetVersionsSpecificOffset 'UI_AutoMap'
    }
    if ($Spells) {
        $addresses += GetVersionsSpecificOffset 'UI_Spells'
    }

    foreach ($addr in $addresses) {
        [Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$addr,$buffer,1,[ref]$read) | Out-Null
        if ($buffer[0] -ne 1) {
        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$addr,1,1,[ref]$read)) {
                Write-Error 'Could not Open UI'
            }
        }
    }
}

function Close-DiabloUI {
param (
    [Switch]$Character,
    [Switch]$Inventory,
    [Switch]$Spellbook,
    [Switch]$QuestLog,
    [Switch]$AutoMap,
    [Switch]$Spells,
    $DiabloSession = $Global:DiabloSession
)

    if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 1

    $addresses = @()

    if ($Character) {
        $addresses += GetVersionsSpecificOffset 'UI_Char'
    }
    if ($Inventory) {
        $addresses += GetVersionsSpecificOffset 'UI_Inventory'
    }
    if ($Spellbook) {
        $addresses += GetVersionsSpecificOffset 'UI_Spellbook'
    }
    if ($QuestLog) {
        $addresses += GetVersionsSpecificOffset 'UI_Questlog'
    }
    if ($AutoMap) {
        $addresses += GetVersionsSpecificOffset 'UI_AutoMap'
    }
    if ($Spells) {
        $addresses += GetVersionsSpecificOffset 'UI_Spells'
    }

    foreach ($addr in $addresses) {
        [Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$addr,$buffer,1,[ref]$read)
        if ($buffer[0] -ne 1) {
        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$addr,0,1,[ref]$read)) {
                Write-Error 'Could not Close UI'
            }
        }
    }
}


function Suspend-DiabloGame {
if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte],1)
    $Buffer[0]=2

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle, (GetVersionsSpecificOffset 'Pause'), $buffer, $buffer.length,[ref]$read)) {
        Write-Error 'Unable to suspend game'
    }
}

function Resume-DiabloGame {
if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte],1)
    $Buffer[0]=0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle, (GetVersionsSpecificOffset 'Pause'), $buffer, $buffer.length,[ref]$read)) {
        Write-Error 'Unable to suspend game'
    }
}

function Test-ValidPlayer {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $DiabloSession = $Global:DiabloSession
)
    [int]$read = 0
    $buffer = [array]::CreateInstance([byte], 1)

    $Offset=GetVersionsSpecificOffset 'PlayersCount'
    if ($offset -eq -1) {
        return $true
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset 'PlayersCount'),$Buffer,1,[ref]$read) | Out-Null
    if ($PlayerIndex -gt $buffer[0]) {
        return $false
    } else {
        return $true
    }
}

function Test-ValidSession {
param (
    $DiabloSession = $Global:DiabloSession
)
	if ($DiabloSession -eq $null) {
        Write-Error 'No valid DiabloSession'
        return
    }
}

function ReadMemory {
param (
    $DiabloSession = $Global:DiabloSession,
    [String]$OffsetType,
    [uint]$n,
    [uint]$Length
)
    $buffer = [array]::CreateInstance([byte],$Length)
    [int]$read = 0

    $ret = [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,(GetVersionsSpecificOffset $OffsetType $n),$buffer,$buffer.length,[ref]$read) | Out-Null
    
    if ($read -ne $Length) {

    }
}