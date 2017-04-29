$PSScriptRoot2 = Split-Path $MyInvocation.MyCommand.Path -Parent

Add-Type -path $PSScriptRoot2\Serpen.Wrapper.ProcessMemory.cs
Add-Type -TypeDefinition "namespace Serpen.Diablo {public class Spell {}}"
Add-Type -TypeDefinition "namespace Serpen.Diablo {public class Item {}}"
Add-Type -TypeDefinition "namespace Serpen.Diablo {public class Item {}}"

function Get-DiabloVersion {
[CmdLetBinding()]
param (
    [Parameter(Mandatory=$true, ParameterSetName='FromFile')] [String]$File,
    [Parameter(Mandatory=$true, ParameterSetName='FromProcess')] [System.Diagnostics.Process]$Process,
    [Parameter(Mandatory=$true, ParameterSetName='FromMemory')] [System.IntPtr]$MemoryHandle
)

if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
    switch ((Get-FileHash $File -Algorithm MD5).Hash) {
        '6F0C02AAF2B29B1C17947AE15F4B82EE' {[Version]'1.0.0.0'}
        '040C81EB1666D66BD900351CB01DE10E' {[Version]'1.0.2.0'}
        '378FF4FE861032702520BCE313C1650C' {[Version]'1.0.3.0'}
        '907201801202D7A21D47E8BDAB31AC26' {[Version]'1.0.4.0'}
        'A353E8EBCED6054B4D25D6DD821BD00F' {[Version]'1.0.5.0'}
        '6D86757A5EF2AB91D32C7E01478D4C8F' {[Version]'1.0.7.0'}
        '8C5859E70E16849512C84AF3D76E26EE' {[Version]'1.0.8.0'}
        '0D1A2B10F8B7FC1A388109BD8ABF05D1' {[Version]'1.0.9.0'}
        'DA62D5CD8BD71A0B66E6D4EF7A111233' {[Version]'1.0.9.1'}

        '7101CDDAC45ED22227B53DE2D0F11667' {[Version]'0.4.1.9'}
        '21563BAE0ED8580FC1D4B4A4344EB89A' {[Version]'0.4.1.8'}

        default {
            Write-Error 'No Version Information'
            return New-Object Version
        } #end default
    } #end switch
} else {
    if ($PSCmdlet.ParameterSetName -eq 'FromProcess') {
        $handle = [Serpen.Wrapper.ProcessMemory]::OpenProcess(0x10, $false, $Process.Id)
    } else {
        $handle = $MemoryHandle
    }

    $bufferSmall = [array]::CreateInstance([byte], 11)
    [int]$read = 0

    foreach ($VerString in $VersionStringMatch.GetEnumerator())  {
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory([int]$handle,$VerString.key,$bufferSmall,11,[ref]$read) | Out-Null
        if ([System.Text.Encoding]::ASCII.GetString($bufferSmall) -eq 'Diablo v1.0') {
            if ($PSCmdlet.ParameterSetName -eq 'FromProcess') { [Serpen.Wrapper.ProcessMemory]::CloseHandle($handle) | Out-Null}
            return $VerString.Value
        } #end if GetString
        if (([System.Text.Encoding]::ASCII.GetString($bufferSmall) -eq 'Diablo v1.0') -or ([System.Text.Encoding]::ASCII.GetString($bufferSmall) -eq 'Hellfire v1')) {
            if ($PSCmdlet.ParameterSetName -eq 'FromProcess') { [Serpen.Wrapper.ProcessMemory]::CloseHandle($handle) | Out-Null}
            return $VerString.Value
        } #end if GetString
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

    [version]$Version = Get-DiabloVersion -MemoryHandle $MemHandle

    if ($Version.Major -ge 1) {
        switch ($Version.ToString()) {
            '1.0.0.0' {$start_offset = $start_offsetV100}
            '1.0.2.0' {$start_offset = $start_offsetV102}
            '1.0.3.0' {$start_offset = $start_offsetV103}
            '1.0.4.0' {$start_offset = $start_offsetV104}
            '1.0.5.0' {$start_offset = $start_offsetV105}
            '1.0.7.0' {$start_offset = $start_offsetV107}
            '1.0.8.0' {$start_offset = $start_offsetV108}
            '1.0.9.0' {$start_offset = $start_offsetV109}
            '1.0.9.1' {$start_offset = $start_offsetV109}
            '2.0.1.0' {$start_offset = $start_offsetV201}
        }

        $DiabloSession = New-Object PSObject -Property @{Process=$proc; Version = $Version; StartOffset = $start_offset; ProcessMemoryHandle = $MemHandle}
        $DiabloSession.psobject.TypeNames.Insert(0,'Serpen.Diablo.Session')
        $global:DiabloSession = $DiabloSession
        return $DiabloSession
    } else {
        Write-Error 'Could not Connect Diablo Session'
    }
}

function DisConnect-DiabloSession {
param ($DiabloSession)
    [Serpen.Wrapper.ProcessMemory]::CloseHandle($DiabloSession.ProcessMemoryHandle) | Out-Null
    $DiabloSession = $null
    
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
param (
    $DiabloSession = $Global:DiabloSession
)

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte],$PLAYERNAME_LENGTH)

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$PLAYERS_COUNT_OFFSET,$Buffer,1,[ref]$read) | Out-Null
    
    [byte]$playersCount = $buffer[0]

    for ([int]$i = 0; $i -lt $playersCount; $i++) {
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+($i*$PLAYER_OFFSET)+$PLAYERNAME_OFFSET,$Buffer,$Buffer.length,[ref]$read) | Out-Null
        New-Object PSobject -Property @{'Index'=($i+1); 'Name'=(ConvertFrom-DiabloString $Buffer 0 $PLAYERNAME_LENGTH)}
    }

}

function Get-DiabloCharacterStats {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $DiabloSession = $Global:DiabloSession
)
    $buffer = [array]::CreateInstance([byte], 0x200)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$PLAYERS_COUNT_OFFSET,$Buffer,1,[ref]$read) | Out-Null
    if ($PlayerIndex -gt $buffer[0]) {
        Write-Error 'No Such Player'
        return
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+(($PlayerIndex-1) * $PLAYER_OFFSET),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $Properties.Add('Name', (ConvertFrom-DiabloString -bytes $buffer $PLAYERNAME_OFFSET $PLAYERNAME_LENGTH))
    $Properties.Add('Type', $TYPE_ENUM[$buffer[$TYPE_OFFSET]])

    for ([int]$i = 0; $i -lt $STAT_ENUM.Length; $i++) {
        $Properties.Add("$($STAT_ENUM[$i]) Base", $buffer[$STAT_OFFSET+$i*8])
        $Properties.Add("$($STAT_ENUM[$i]) Now", $buffer[($STAT_OFFSET+$i*8)-4])
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
    $char = New-Object PSObject -Property $Properties
    $char.psobject.TypeNames.Insert(0,'Serpen.Diablo.CharacterStats')
    $char
}

function Get-DiabloStoreItems {
param (
    [ValidateSet('Wirt','Griswold Premium','Griswold Basic','Pepin','Adria')][String]$Store,
    $DiabloSession = $Global:DiabloSession
)
    switch ($Store) {
        'Wirt' {$curSO = $DiabloSession.StartOffset + 0x18CA8; $count = 1}
        'Griswold Premium' {$curSO = $DiabloSession.StartOffset + 0x18E20; $count = 6}
        'Griswold Basic'  {$curSO = $DiabloSession.StartOffset + 0x22740; $count = 20}
        'Pepin' {$curSO = $DiabloSession.StartOffset + 0x20750; $count = 20}
        'Adria' {$curSO = $DiabloSession.StartOffset + 0x1ea88; $count = 20}
    }

    for ([int]$i = 0; $i -lt $count; $i++) {
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset ($curSO + ($i*$ITEM_SIZE))
        if ($itm.class -ne 'invalid') {
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

    $buffer = [array]::CreateInstance([byte], 10)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$PLAYERS_COUNT_OFFSET,$Buffer,1,[ref]$read) | Out-Null
    if ($PlayerIndex -gt $buffer[0]) {
        Write-Error 'No Such Player'
        return
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$TP_OFFSET+(($PlayerIndex-1)*5),$buffer,$buffer.length,[ref]$read) | Out-Null
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

function Get-DiabloEntrances {
param (
    $DiabloSession = $Global:DiabloSession
)

    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset-$WAYPOINT_OFFSET,$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $Properties.Add('Dungeon', $true)
    $Properties.Add('Catacombs', 1 -eq ($buffer[0] -band 1))
    $Properties.Add('Caves', 2 -eq ($buffer[0] -band 2))
    $Properties.Add('Hell', 4 -eq ($buffer[0] -band 4))

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0,'Serpen.Diablo.Entrances')
    $returnobject
}

function Set-DiabloEntrances {
param (
    [Switch]$Catacombs,
    [Switch]$Caves,
    [Switch]$Hell,
    $DiabloSession = $Global:DiabloSession
)
    $buffer = [array]::CreateInstance([byte], 1)
    [int]$read = 0

    $buffer[0] = [byte]($Catacombs.ToBool())*1 + [byte]$Caves.ToBool()*2 + [byte]$Hell.ToBool()*4

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset-$WAYPOINT_OFFSET,$buffer,$buffer.length,[ref]$read)) {
        Write-Error 'Could not set DiabloEntrances'
    }
    

}

function Get-DiabloCharacterPosition {
param (
    [ValidateRange(1,4)][byte]$PlayerIndex = 1,
    $DiabloSession = $Global:DiabloSession
)

    $buffer = [array]::CreateInstance([byte], 0x20)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$PLAYERS_COUNT_OFFSET,$Buffer,1,[ref]$read) | Out-Null
    if ($PlayerIndex -gt $buffer[0]) {
        Write-Error 'No Such Player'
        return
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset-(($PlayerIndex-1) * $PLAYER_OFFSET),$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $Properties.Add('Dungeon', $buffer[$DUNGENON_OFFSET])
    $Properties.Add('X', $buffer[$POS_X_OFFSET])
    $Properties.Add('Y', $buffer[$POS_Y_OFFSET])

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
    $DiabloSession = $Global:DiabloSession
)

    [int]$read = 0

    if ($PSCmdLet.ParameterSetName -eq 'PropertyValue') {
        $PropOffset = -1
        switch ($Property) {
            'Identified' {$PropOffset = $ITM_IDENTIFIED_OFFSET}
            'Damage From'{$PropOffset = $ITM_DMG_FROM_OFFSET}
            'Damage To'  {$PropOffset = $ITM_DMG_TO_OFFSET}
            'Spell'      {$PropOffset = $ITM_SPELL_OFFSET}
            'Charges From' {$PropOffset = $ITM_CHARGES_FROM_OFFSET}
            'Charges To' {$PropOffset = $ITM_CHARGES_TO_OFFSET}
            'Durability From' {$PropOffset = $ITM_DUR_FROM_OFFSET}
            'Durability To' {$PropOffset = $ITM_DUR_TO_OFFSET}
            'Resist All' {$PropOffset = $ITM_RESISTALL_OFFSETS}
            'All Attributes' {$PropOffset = $ITM_ALLATTRIB_OFFSETS}
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
        }
    }

    if ($PropOffset -eq -1) {
        Write-Error "Property $Property not found"
        return
    }

    #$buffer = [array]::CreateInstance([byte],4)
    $buffer = [System.BitConverter]::GetBytes($value)

    foreach ($po in $PropOffset) {
        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$item._Offset + $po,$buffer,4,[ref]$read)) {
            Write-Error "Could not set property $Property for item '$($item.identifiedname)'"
        }
    }
}

function Invoke-DiabloIdentifyItem {
param (
    [Parameter(Mandatory=$true)][Object]$Item,
    $DiabloSession = $Global:DiabloSession
)
    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$item._Offset + 0x38,1,1,[ref]$read)) {
        Write-Error "Could not identify item '$($item.identifiedname)'"
    }
}

function Invoke-DiabloRepairItem {
param (
    [Parameter(Mandatory=$true)][Object]$Item,
    $DiabloSession = $Global:DiabloSession
)
    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$item._Offset + $ITM_DUR_FROM_OFFSET,$item.DurTo,1,[ref]$read)) {
        Write-Error "Could not repair item '$($item.identifiedname)'"
    }
}

function Set-DiabloPoints {
param (
    [Parameter(Mandatory=$true)][byte]$Points,
    $DiabloSession = $Global:DiabloSession
)
    [int]$read = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$LEVELUP_OFFSET,$Points,1,[ref]$read)) {
        Write-Error 'Could not set DiabloPoints'
    }
    

}

function Get-DiabloSpell {
param (
    [String[]]$Spell,
    $DiabloSession = $Global:DiabloSession
)

    $buffer = [array]::CreateInstance([byte], $SPELL_NAMES.Length-1+4)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$SPELLS_OFFSET,$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    if ($Spell -eq "*" -or $Spell -eq $null) {$Spell = $SPELL_NAMES}

    foreach ($spellSingle in $Spell) {
        $SpellIndex = -1
        for ([int]$i=0; $i -lt $SPELL_NAMES.Length; $i++) {
            if ($SPELL_NAMES[$i] -eq $spellSingle) {
                $SpellIndex = $i
                $spellSingle = $SPELL_NAMES[$i]
                break
            }
        }
        if ($SpellIndex -eq -1) {
            Write-Error "$Spell not found"
            break
        }
        #$SpellIndex = 0 #$SPELL_NAMES.IndexOf($Spell)
        $spellflags = [System.BitConverter]::ToInt32($buffer,$SPELL_NAMES.Length-1)
        $spellLevel = $buffer[$SpellIndex]

        $returnobject = New-Object Serpen.Diablo.Spell
        $returnobject | Add-Member -MemberType NoteProperty -Name Spell -Value $spellSingle
        $returnobject | Add-Member -MemberType NoteProperty -Name Index -Value $SpellIndex
        $returnobject | Add-Member -MemberType NoteProperty -Name Spellbook -Value "Page $($SPELLBOX_X[$SpellIndex]).$($SPELLBOX_Y[$SpellIndex])"
        $returnobject | Add-Member -MemberType NoteProperty -Name Enabled -Value ($SpellIndex -eq ($spellflags -band $SpellIndex ))
        $returnobject | Add-Member -MemberType NoteProperty -Name Level -Value $spellLevel

        $returnobject
    }
}
function Set-DiabloSpell {
param (
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [String]$Spell,
    [Parameter(Mandatory=$true)][ValidateRange(0,15)]
    [byte]$Level,
    $DiabloSession = $Global:DiabloSession
)
begin {
    $buffer = [array]::CreateInstance([byte], 4)
    [int]$read = 0
}

process {
    $SpellIndex = -1
    for ([int]$i=0; $i -lt $SPELL_NAMES.Length; $i++) {
        if ($SPELL_NAMES[$i] -eq $Spell) {
            $SpellIndex = $i
            break
        }
    }
    if ($SpellIndex -eq -1) {
        Write-Error "$Spell not found"
        break
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$SPELLFLAGS_OFFSET,$buffer,$buffer.length,[ref]$read) | Out-Null
    Write-Debug ($buffer -join ' ')

    $spellflags = [System.BitConverter]::ToInt32($buffer,0)
    $spellflags = $spellflags -bor [math]::Pow(2, $SpellIndex)
    $buffer = [System.BitConverter]::GetBytes($spellflags)

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$SPELLFLAGS_OFFSET,$buffer,$buffer.length,[ref]$read)) {
        Write-Error 'Could not write Spellflags'
        return
    }

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset+$SPELLS_OFFSET+$SpellIndex,$Level,1,[ref]$read)) {
        Write-Error 'Could not write Spelllevel'
        return
    }
} #end process

}

#function Import-DiabloItem {}

function Get-DiabloMonsterKills {
param (
    [String[]]$Monster,
    $DiabloSession = $Global:DiabloSession
)

    $buffer = [array]::CreateInstance([byte], ($Monster_ENUM.Length)*4)
    [int]$read = 0

    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$DiabloSession.StartOffset-$MONSTER_OFFSET,$buffer,$buffer.length,[ref]$read) | Out-Null
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
        }
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
    }
}

function Get-DiabloInventory {
param (
    $DiabloSession = $Global:DiabloSession
)
    for ([int]$i = 0; $i -lt 7; $i++) {
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset ($DiabloSession.StartOffset + $INV_OFFSET +($i*$ITEM_SIZE))
        if ($itm.class -ne 'invalid') {
            $itm
        }
    }

    
}

function Get-DiabloBelt {
param (
    $DiabloSession = $Global:DiabloSession
)
    for ([int]$i = 0; $i -lt 8; $i++) {
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset ($DiabloSession.StartOffset + $BELT_OFFSET +($i*$ITEM_SIZE))
        if ($itm.class -ne 'invalid') {
            $itm
        }
    }
}

function Get-DiabloRucksack {
param (
    $DiabloSession = $Global:DiabloSession
)
    for ([int]$i = 0; $i -lt 18; $i++) {
        $itm = ConvertTo-DiabloItem -DiabloSession $DiabloSession -Offset ($DiabloSession.StartOffset + $INV_BACKPACK_OFFSET +($i*$ITEM_SIZE))
        if ($itm.class -ne 'invalid') {
            $itm
        } else {
            break
        }
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
    
    $pre2 = 0
    if ($PSCmdlet.ParameterSetName -eq 'File') {
        [System.IO.FileStream]$stream = [System.IO.File]::OpenRead($File)
        $buffer = [array]::CreateInstance([byte],$stream.Length)
        $read = $stream.Read($buffer, 0, $stream.Length)
        $stream.Close()

        Write-Verbose "Processing $File"
    } elseif ($PSCmdlet.ParameterSetName -eq 'Byte') {
        $read = $buffer.Length
        $pre2 = 0 #-1
    } else {
        $buffer = [array]::CreateInstance([byte], 0x170)
        [int]$read = 0
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$Offset,$buffer,$buffer.length,[ref]$read) | Out-Null
    }

    [byte[]]$ITM_FORMAT_PREEMBLE = @(0x49,0x54,0x4d,0x30,0x31,0x2e,0x49,0x27,0x6c,0x6c,0x20,0x67,0x65,0x74,0x20,0x74,0x68,0x61,0x74,0x20,0x61,0x6c,0x27,0x54,0x68,0x6f,0x72,0x21,0x0,0x0,0x0,0x0)
	$PREAMBLE = -1
    if ($read -eq 0x190) {
        $PREAMBLE = 0x20 #-1
    } elseif ($read -eq 0x170) {
        $PREAMBLE = 0-$pre2
    }

    #if ($buffer[0..0x1f] -eq $ITM_FORMAT_PREEMBLE) {
    if ((compare-object $buffer[0..0x1f] $ITM_FORMAT_PREEMBLE) -eq $null) {
        $PREAMBLE = 0x20
    }
	
	if ($PREAMBLE -eq -1) {
		write-Warning "Unknown Header in $file"
		return
	}
    
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        $Properties = [ordered]@{}
    } else {
        $Properties = @{}
    }

    #$properties.Add("File", $File)
	#$properties.Add("PREAMBLE", $PREAMBLE)
	
    $properties.Add("UnidentifiedName", (ConvertFrom-DiabloString $buffer (0x3d+$PREAMBLE) 0x40))
    $properties.Add("IdentifiedName", (ConvertFrom-DiabloString $buffer (0x7d+$PREAMBLE) 0x40))

    $properties.Add("ID", [System.BitConverter]::ToUInt32($buffer,$PREAMBLE))

    $temp = [System.BitConverter]::ToUInt16($buffer,0x4+$PREAMBLE)
    
    if ($temp -eq ($temp -bor 0x10000)) {
        $properties.Add("Found", "0x10000 Level ?" + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x8000)) {
        $properties.Add("Found", "0x8000 Level ?" + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x4000)) {
        $properties.Add("Found", "0x4000 Level ?" + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x2000)) {
        $properties.Add("Found", "Adria Level ?" + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x1000)) {
        $properties.Add("Found", "Wirt Level " + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x800)) {
        $properties.Add("Found", "Griswold Premium Level " + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x400)) {
        $properties.Add("Found", "Griswold Basic Level " + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x200)) {
        $properties.Add("Found", "Single Player Monster Level " + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0x100)) {
        $properties.Add("Found", "Monster Level " + ($temp -band 63))
    } elseif ($temp -eq ($temp -bor 0xc0)) {
        $properties.Add("Found", "Unique Monster Level " + ($temp  -band 63))
    } elseif ($temp -eq ($temp -bor 0x40)) {
        #$properties.Add("Found", "Dungeon Level " + (($temp -band 63) -shr 1))
        $properties.Add("Found", "Dungeon Level " + (($temp -band 63) /2))
    } else {
        $properties.Add("Found", "Unknown Level " + ($temp -band 63))
    }

    #0x6,0x7 00 GAP
    
	#$temp = [System.BitConverter]::ToInt32($buffer,0x8+$PREAMBLE)
	$temp = $buffer[0x8+$PREAMBLE]
	if ($itemClass.containsKey($temp -as [int])) {
		$properties.Add("Class", $itemClass[$temp -as [int]])
	} else {
		$properties.Add("Class", $temp)
	}

    #$properties.Add("Col", [System.BitConverter]::ToUInt32($buffer,0xc+$PREAMBLE)) #0-91

    #$properties.Add("Row", [System.BitConverter]::ToUInt32($buffer,0x10+$PREAMBLE)) #0-92

    #$properties.Add("drop_anim_update", [System.BitConverter]::ToUInt32($buffer,0x14+$PREAMBLE)) #0-1
    #$properties.Add("drop_cel_data", [System.BitConverter]::ToUInt32($buffer,0x18+$PREAMBLE))
    #$properties.Add("drop_frame_count", [System.BitConverter]::ToUInt32($buffer,0x1C+$PREAMBLE))

    #$properties.Add("cur_drop_frame", [System.BitConverter]::ToUInt32($buffer,0x20+$PREAMBLE)) #1-16
    #$properties.Add("drop_width", [System.BitConverter]::ToUInt32($buffer,0x24+$PREAMBLE)) #0,96
    #$properties.Add("drop_x_offset", [System.BitConverter]::ToUInt32($buffer,0x28+$PREAMBLE))

    #$properties.Add("inactive", [System.BitConverter]::ToUInt32($buffer,0x2C+$PREAMBLE))

    #$properties.Add("drop_state", $buffer[0x30+$PREAMBLE]) #0/1

    #$properties.Add("draw_quest_item", [bool][System.BitConverter]::ToUInt32($buffer,0x34+$PREAMBLE)) #0/1

    $properties.Add("Identified", [bool][System.BitConverter]::ToUInt32($buffer,0x38+$PREAMBLE))

    switch ($buffer[0x3c+$PREAMBLE]) {
        0x0 {$properties["Quality"] = "normal"}
        0x1 {$properties["Quality"] = "magic"}
        0x2 {$properties["Quality"] = "Unique"}
        else {$properties["Quality"] =  $buffer[0x3c]}
    }

    if ($buffer[0xBD+$PREAMBLE] -lt $equip_type.length) {
        $properties["equip_type"] = $equip_type[$buffer[0xBD+$PREAMBLE]]
    } else {
        $properties["equip_type"] = $buffer[0xBD+$PREAMBLE]
    }
    
    if ($buffer[0xBE+$PREAMBLE] -lt $item_category.length) {
        $properties["Category"] = $item_category[$buffer[0xBE+$PREAMBLE]]
    } else {
        $properties["Category"] = $buffer[0xBE+$PREAMBLE]
    }
    
    $properties.Add("Graphics", [System.BitConverter]::ToUInt32($buffer,0xC0+$PREAMBLE))

    $properties.Add("BasePrice", [System.BitConverter]::ToUInt32($buffer,0xC4+$PREAMBLE))
    $properties.Add("IdentifiedPrice", [System.BitConverter]::ToUInt32($buffer,0xC8+$PREAMBLE))

    $properties.Add("DamageFrom", [System.BitConverter]::ToUInt32($buffer,0xCC+$PREAMBLE))
    $properties.Add("DamageTo", [System.BitConverter]::ToUInt32($buffer,0xD0+$PREAMBLE))

    $properties.Add("Amor", [System.BitConverter]::ToInt32($buffer,0xD4+$PREAMBLE))

    $properties.Add("Special Effect", "0x{0:x}" -f ([System.BitConverter]::ToUInt32($buffer,0xD8+$PREAMBLE)))

    $temp = [System.BitConverter]::ToUInt32($buffer,0xDC+$PREAMBLE)
	if ($itemCode.containsKey($temp -as [int])) {
		$properties.Add("itemCode", $itemCode[$temp -as [int]])
	} else {
		$properties.Add("itemCode", $temp)
	}

    $temp = ([System.BitConverter]::ToUInt32($buffer,0xE0+$PREAMBLE))-1
    if ($temp -ne -1) {
        $properties.Add("Spell", $SPELL_NAMES[$temp])
    }
    $properties.Add("ChargesFrom", [System.BitConverter]::ToUInt32($buffer,0xE4+$PREAMBLE))
    $properties.Add("ChargesTo", [System.BitConverter]::ToUInt32($buffer,0xE8+$PREAMBLE))

    $properties.Add("DurFrom", [System.BitConverter]::ToUInt32($buffer,0xEC+$PREAMBLE))
    $properties.Add("DurTo", [System.BitConverter]::ToUInt32($buffer,0xF0+$PREAMBLE))

    $properties.Add("DamageBonus", [System.BitConverter]::ToInt32($buffer,0xF4+$PREAMBLE))
    $properties.Add("ToHitBonus", [System.BitConverter]::ToInt32($buffer,0xF8+$PREAMBLE))

    $properties.Add("AmorBonus", [System.BitConverter]::ToInt32($buffer,0xFc+$PREAMBLE))
    $properties.Add("StrengthBonus", [System.BitConverter]::ToInt32($buffer,0x100+$PREAMBLE))
    $properties.Add("MagicBonus", [System.BitConverter]::ToInt32($buffer,0x104+$PREAMBLE))
    $properties.Add("DexterityBonus", [System.BitConverter]::ToInt32($buffer,0x108))
    $properties.Add("VitalityBonus", [System.BitConverter]::ToInt32($buffer,0x10c+$PREAMBLE))

    $properties.Add("ResistFire", [System.BitConverter]::ToInt32($buffer,0x110+$PREAMBLE))
    $properties.Add("ResistLightning", [System.BitConverter]::ToInt32($buffer,0x114+$PREAMBLE))
    $properties.Add("ResistMagic", [System.BitConverter]::ToInt32($buffer,0x118+$PREAMBLE))

    $properties.Add("ManaBonus", [System.BitConverter]::ToUint16($buffer,0x11c+$PREAMBLE) / 64) #-shr 6)

    $properties.Add("LifeBonus", [System.BitConverter]::ToUint16($buffer,0x120+$PREAMBLE) /64) #-shr 6)

    $properties.Add("ExtraDamage", [System.BitConverter]::ToUInt32($buffer,0x124+$PREAMBLE))
    $properties.Add("DamageModifier", [System.BitConverter]::ToInt32($buffer,0x128+$PREAMBLE))

    $properties.Add("LightRadius", [System.BitConverter]::ToInt32($buffer,0x12c+$PREAMBLE)*10)
    
    $properties.Add("SpellBonus", $buffer[0x130+$PREAMBLE])
    #$properties.Add("Held in Hand", [bool]$buffer[0x131+$PREAMBLE])

    $properties.Add("unique_id", [System.BitConverter]::ToUInt32($buffer,0x134+$PREAMBLE))

    $properties.Add("FireDamageFrom", [System.BitConverter]::ToUInt32($buffer,0x138+$PREAMBLE))
    $properties.Add("FireDamageTo", [System.BitConverter]::ToUInt32($buffer,0x13c+$PREAMBLE))
    
    $properties.Add("LightningDamageFrom", [System.BitConverter]::ToUInt32($buffer,0x140+$PREAMBLE))
    $properties.Add("LightningDamageTo", [System.BitConverter]::ToUInt32($buffer,0x144+$PREAMBLE))

    $properties.Add("armor_penetration", [System.BitConverter]::ToUInt16($buffer,0x148+$PREAMBLE))

    #$properties.Add("prefix_effect_type", $buffer[0x14C+$PREAMBLE])
    #$properties.Add("suffix_effect_type", $buffer[0x14D+$PREAMBLE])

    #$properties.Add("prefix_price", $buffer[0x150+$PREAMBLE])
    #$properties.Add("prefix_price_multiplier", $buffer[0x154+$PREAMBLE])

    #$properties.Add("suffix_price", $buffer[0x158+$PREAMBLE])
    #$properties.Add("suffix_price_multiplier", $buffer[0x15C+$PREAMBLE])

    $properties.Add("ReqStr", $buffer[0x160+$PREAMBLE])
    $properties.Add("ReqMagic", $buffer[0x161+$PREAMBLE])
    $properties.Add("ReqDex", $buffer[0x162+$PREAMBLE])
    $properties.Add("ReqVit", $buffer[0x163+$PREAMBLE])

    $properties.Add("Equippable", [bool]$buffer[0x164+$PREAMBLE])

    #$properties.Add("item_id", [System.BitConverter]::ToUInt32($buffer,0x168+$PREAMBLE))


    $temp = [System.BitConverter]::ToUInt32($buffer,0x168+$PREAMBLE)
    if ($itemType.containsKey($temp -as [int])) {
		$properties.Add("item_id", $itemType[$temp -as [int]])
	} else {
		$properties.Add("item_id", $temp)
	}
    # 0x18C 00 GAP

    if ($PSCmdlet.ParameterSetName -eq 'Session') {
         $properties.Add("_Offset", $Offset)
    }
    
    $object = New-Object PSObject -Property $properties
    $object.psobject.TypeNames.Insert(0,'Serpen.Diablo.Item')

    $object
}

function Export-DiabloItem {
param (
    [Object]$Item,
    [String]$File,
    $DiabloSession = $Global:DiabloSession
)
    [int]$read = 0
    $buffer = [array]::CreateInstance([byte], $ITEM_SIZE)

    if (![Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($DiabloSession.ProcessMemoryHandle,$item._Offset,$buffer,$buffer.length,[ref]$read)) {
        Write-Error "Could not read item '$($item.identifiedname)'"
    }

    $filestram = [system.io.file]::Create($file)
    $filestram.Write($buffer, 0, $buffer.length)
    $filestram.Close()


}
