
#checked
function Get-D1Version {
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'FromFile')] [String]$File,
        [Parameter(Mandatory = $true, ParameterSetName = 'FromProcess')] [System.Diagnostics.Process]$Process,
        [Parameter(Mandatory = $true, ParameterSetName = 'FromMemory')] [System.IntPtr]$MemoryHandle
    )

    $Versions = Import-Csv -Path .\data\versions.csv -Delimiter ";"

    if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
        $hash = (Get-FileHash $file -Algorithm MD5).Hash
        foreach ($Ver in $Versions) {
            if ($hash -eq $Ver.FileHash) {
                return $Ver
            }
        }
        throw 'No Version Information'
    
    }
    else {
        if ($PSCmdlet.ParameterSetName -eq 'FromProcess') {
            $handle = [Serpen.Wrapper.ProcessMemory]::OpenProcess(0x10, $false, $Process.Id)
        }
        else {
            $handle = $MemoryHandle
        }

    
        $bufferSmall = [array]::CreateInstance([byte], 30)
        [int]$read = 0

        foreach ($Ver in $Versions) {
            [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($handle, $Ver.version -as [int64], $bufferSmall, $Ver.vername.Length, [ref]$read) | Out-Null
            $str = [System.Text.Encoding]::ASCII.GetString($bufferSmall, 0, $Ver.vername.Length)
            if ($str -eq $Ver.vername) {
                if ($PSCmdlet.ParameterSetName -eq 'FromProcess') { [Serpen.Wrapper.ProcessMemory]::CloseHandle($handle) | Out-Null }
                return $Ver
            }
        } #end foreach
        [Serpen.Wrapper.ProcessMemory]::CloseHandle($handle) | Out-Null
        throw 'No Version Information'
    } #end if ParameterSetName
} #end function

#checked
function Connect-D1Session {
    $proc = Get-Process -Name diabl*, hellfir*, devilutio*

    if (!$proc) {
        throw 'Diablo is not running'
    }

    [System.IntPtr]$MemHandle = [Serpen.Wrapper.ProcessMemory]::OpenProcess(0x8 -bor 0x10 -bor 0x20, $false, $proc.id)
    if ($MemHandle -eq 0) {
        throw 'Unable to open process memory'
    }

    $Version = Get-D1Version -MemoryHandle $MemHandle

    $D1Session = New-Object PSObject -Property ([ordered]@{Process = $proc; Version = $Version.Name; ProcessMemoryHandle = $MemHandle; Offsets = New-Object psobject })
    $D1Session.Offsets | Add-Member -NotePropertyName Base -NotePropertyValue ($Version.base -as [int64])
    foreach ($of in ($Version | Get-Member -MemberType NoteProperty | Where-Object Name -NotIn ('vername', 'version', 'Name', 'filehash', 'base', 'filepv', 'filefv', 'ITEM_STRUCT_SIZE'))) {
        [int64]$ofval = 0
        if ([int64]::TryParse($Version."$($of.name)", [ref]$ofval)) {
            $ofval += $D1Session.Offsets.Base 
        }
        else {
            $ofval = $null
        }
        
        $D1Session.Offsets | Add-Member -NotePropertyName $of.name -NotePropertyValue $ofval
    }
    
    $D1Session.Offsets | Add-Member -NotePropertyName ITEM_STRUCT_SIZE -NotePropertyValue ($Version.ITEM_STRUCT_SIZE -as [int])

    $D1Session.psobject.TypeNames.Insert(0, 'Serpen.Diablo.Session')
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
    $string = ([System.Text.Encoding]::ASCII.GetString($bytes, $start, $len))
    [int]$pos = $string.IndexOf([char]0)
    if ($pos -gt 0) {
        $string.Substring(0, $pos)
    }
    else {
        $string
    }
}

#checked
function Get-D1Players {
    param (
        $D1Session = $Global:D1Session
    )
    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType PlayersCount -Length 1

    [byte]$playersCount = $buffer[0]

    Write-Verbose "Found $playersCount Players"
    
    for ([int]$i = 0; $i -lt $playersCount; $i++) {
        $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType playname -Length $PLAYERNAME_LENGTH -n $i
        
        New-Object PSobject -Property @{'Index' = ($i + 1); 'Name' = (ConvertFrom-D1String $Buffer 0 $PLAYERNAME_LENGTH) }
    }

}


function Get-D1Difficulty {
    param (
        $D1Session = $Global:D1Session
    )

    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType difficulty -Length 1

    [Serpen.Diablo.eDifficulty]($Buffer[0])
}

function Set-D1Difficulty {
    param (
        [Serpen.Diablo.eDifficulty]$Difficulty,
        $D1Session = $Global:D1Session
    )

    Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0

    [byte]$DifficultyIndex = 0
    switch ($Difficulty) {
        'Normal' { $DifficultyIndex = 0 }
        'Nightmare' { $DifficultyIndex = 1 }
        'Hell' { $DifficultyIndex = 2 }
    }

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, $D1Session.Offsets.difficulty , $DifficultyIndex, 1, [ref]$read)) {
        Write-Error 'Could not set Difficulty'
    }
    else {
        Write-Warning 'Takes affect in next game'
    }
}

#checked
function Get-D1Character {
    [CmdLetBinding()]
    param (
        [ValidateRange(1, 4)][byte]$PlayerIndex = 1,
        $D1Session = $Global:D1Session
    )

    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType Character -Index ($PlayerIndex - 1) -Length 469

    $obj = [Serpen.Diablo.Character]::new($buffer)
    if ($PSBoundParameters.ContainsKey("Verbose")) {
        $obj | Add-Member -NotePropertyName "_MemoryAddress" -NotePropertyValue ($D1Session.offsets.Character + ($PlayerIndex - 1) * 469)
    }
    $obj
}

#checked
function Get-D1StoreItems {
    param (
        [Parameter(Mandatory = $true)][ValidateSet('Wirt', 'Griswold Premium', 'Griswold Basic', 'Pepin', 'Adria')][String]$Store,
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession -D1Session $D1Session

    switch ($Store) {
        'Wirt' { $curSO = $D1Session.Offsets.store; $count = 1 }
        'Griswold Premium' { $curSO = $D1Session.Offsets.store + 0x178; $count = 6 }
        'Griswold Basic' { $curSO = $D1Session.Offsets.store + 0x9920 + 8; $count = 20 }
        'Pepin' { $curSO = $D1Session.Offsets.store + 0x7AA0 + 8; $count = 20 }
        'Adria' { $curSO = $D1Session.Offsets.store + 0x5DD8 + 8; $count = 20 }
    }

    for ([int]$i = 0; $i -lt $count; $i++) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset ($curSO + ($i * $D1Session.Offsets.ITEM_STRUCT_SIZE))
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        }
        else {
            break
        }
    }
}

#checked
function Get-D1TownPortal {
    [CmdLetBinding()]
    param (
        [ValidateRange(1, 4)][byte]$PlayerIndex = 1,
        $D1Session = $Global:D1Session
    )

    Test-D1ValidSession

    $Properties = GenerateHashTableProperties

    if (!(Test-ValidDiabloPlayer $PlayerIndex)) {
        throw 'No Such Player'
    }

    $offset = $D1Session.Offsets.tp + ($PlayerIndex - 1) * 24

    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetAddress $offset -Length 24

    $Properties.Add('Open', [boolean][System.BitConverter]::ToInt32($buffer, 0))
    $Properties.Add('Dungeontype', $DUNGEONTYPES_ENUM[[System.BitConverter]::ToInt32($buffer, 16)])
    $Properties.Add('Dungeon', [System.BitConverter]::ToInt32($buffer, 12))
    $Properties.Add('X', [System.BitConverter]::ToInt32($buffer, 4))
    $Properties.Add('Y', [System.BitConverter]::ToInt32($buffer, 8))
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Verbose")) {
        $Properties.Add('Buffer', $buffer)
        $Properties.Add('MemoryOffset', $offset)
    }

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0, 'Serpen.Diablo.Position')
    $returnobject
}

#checked
function Get-D1Entrances {
    param (
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession -D1Session $D1Session

    $Properties = GenerateHashTableProperties

    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType Entrance -Length 1
    
    $Properties.Add('Dungeon', $true)
    $Properties.Add('Catacombs', 1 -eq ($buffer[0] -band 1))
    $Properties.Add('Caves', 2 -eq ($buffer[0] -band 2))
    $Properties.Add('Hell', 4 -eq ($buffer[0] -band 4))

    $returnobject = New-Object PSObject -Property $Properties
    $returnobject.psobject.TypeNames.Insert(0, 'Serpen.Diablo.Entrances')
    $returnobject
}

#checked
function Enable-D1Entrances {
    param (
        [Switch]$Catacombs,
        [Switch]$Caves,
        [Switch]$Hell,
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession -D1Session $D1Session

    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType Entrance -Length 1

    if ($Catacombs) { $buffer = $buffer -bor 1 }
    if ($Caves) { $buffer = $buffer -bor 2 }
    if ($Hell) { $buffer = $buffer -bor 4 }

    WriteMemoryDirect -D1Session $D1Session -OffsetType Entrance -Data $buffer

}

function Set-D1Item {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Serpen.Diablo.Item]$Item,
        $D1Session = $Global:D1Session
    )

    Test-D1ValidSession -D1Session $D1Session

    
    if (!$item.MemoryOffset) {
        throw "Item $Item not in memory"
    }

    [int]$write = 0

    $ret = [Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, $item.MemoryOffset, $item.Buffer, $item.Buffer.Length, [ref]$write)
    if (!$ret -or $write -ne $item.Buffer.length) {
        throw "Error saving item"
    }
}

#checked
function Invoke-D1IdentifyItem {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Item', Position = 0, ValueFromPipeline = $true)]
        [Serpen.Diablo.Item]$Item,
        $D1Session = $Global:D1Session
    )
    begin {
        Test-D1ValidSession -D1Session $D1Session
    }
    process {
        foreach ($itm in $item) {
            if (!$item.MemoryOffset) {
                throw "Item $Item not in memory"
            }

            $itm.Identified = $true
    
            $itm | Set-D1Item -D1Session $D1Session
        }
    
    }
}

#checked
function Repair-D1Item {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Item', Position = 0, ValueFromPipeline = $true)]
        [Serpen.Diablo.Item]$Item,
        $D1Session = $Global:D1Session
    )
    begin {
        Test-D1ValidSession -D1Session $D1Session
    }
    process {
        [int]$write = 0

        if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, ($_.MemoryOffset + 0xec), $_.DurabilityMax, 1, [ref]$write)) {
            Write-Error "Could not repair item '$($item.identifiedname)'"
        }
    }
}

function Restore-D1ItemCharges {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Item', Position = 0, ValueFromPipeline = $true)]
        [Serpen.Diablo.Item]$Item,
        $D1Session = $Global:D1Session
    )
    begin {
        Test-D1ValidSession -D1Session $D1Session
    }
    process {
        foreach ($itm in $item) {
            if (!$item.MemoryOffset) {
                throw "Item $Item not in memory"
            }
        
            $itm.Charges = $itm.ChargesMax
    
            $itm | Set-D1Item -D1Session $D1Session
        }
    }
}

#checked64
function Set-D1LevelUpPoints {
    param (
        [Parameter(Mandatory = $true)][byte]$Points,
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession -D1Session $D1Session

    WriteMemoryDirect -D1Session $D1Session -OffsetType LvlUpPoints -Data $Points

}

#checked64
function Get-D1Spell {
    [CmdLetBinding()]
    param (
        [Serpen.Diablo.eSpell[]]$Spell,
        $D1Session = $Global:D1Session
    )
    
    #if ($Spell -eq "*" -or $Spell -eq $null) {$Spell = $SPELL_NAMES}
    if ($Spell -eq "All" -or ($Spell.Length) -eq 0) { $Spell = [enum]::GetValues([Serpen.Diablo.eSpell]) | Where-Object { $_ -gt 0 } }
    
    $spellflags = ReadMemoryDirect -D1Session $D1Session -OffsetType SpellFlags -Length 4
    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType Spell -Length 36

    foreach ($spellSingle in $Spell) {
        $intspell = $spellSingle.value__ -1 
        
        $spellflagsInt = [System.BitConverter]::ToInt32($spellflags, 0)
        $spellLevel = $buffer[$intspell]

        $returnobject = New-Object Serpen.Diablo.Spell
        $returnobject.Spell = $spellSingle
        $returnobject.Index = $intspell
        $returnobject.Spellbook = "Page $($SPELLBOX_X[$intspell]).$($SPELLBOX_Y[$intspell])"
        $returnobject.Enabled = ($spellflagsInt -band (1 -shl $intspell)) -gt 0
        $returnobject.Level = $spellLevel

        $returnobject
    }
}

#checked64
function Set-D1Spell {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Serpen.Diablo.eSpell]$Spell,
        [Parameter(Mandatory = $true)][ValidateRange(0, 15)]
        [byte]$Level,
        $D1Session = $Global:D1Session
    )
    begin {
        Test-D1ValidSession -D1Session $D1Session

        $buffer = [array]::CreateInstance([byte], 4)
    }

    process {
        foreach ($spl in $spell) {
            if ($spl.value__ -ne 0) {
                $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType SpellFlags -Length 4
                #[Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle,$D1Session.Offsets.Spell,$buffer,$buffer.length,[ref]$read) | Out-Null
                Write-Debug ($buffer -join ' ')

                $spellflags = [System.BitConverter]::ToInt32($buffer, 0)
                $spellflags = $spellflags -bor [math]::Pow(2, ($spl.value__ - 1))
                $buffer = [System.BitConverter]::GetBytes($spellflags)

        
                WriteMemoryDirect -D1Session $D1Session -OffsetType SpellFlags -Data $buffer

                WriteMemoryDirect -D1Session $D1Session -OffsetType Spell -Index ($spl.value__ - 1) -Data $level
            }
        }
    
    } #end process

}

#checked
function Get-D1Quests {
    param (
        $D1Session = $Global:D1Session
    )
    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType Quest -Length (0x18 * 16)

    for ([int]$i = 0; $i -lt 16; $i++) {
        # New-Object PSobject -Property ([ordered]@{
        #     State=$QUEST_STATE[$buffer[2+$i*0x18]]; 
        #     Name=$QUEST_ENUM[$buffer[1+$i*0x18]]; 
        #     DungeonLevel=$buffer[$i*0x18]; 
        #     QuestLevel=$buffer[12+$i*0x18]})

        $properties = GenerateHashTableProperties
        $properties.Add('State', $QUEST_STATE[$buffer[$i * 0x18 + 2]]) 
        $properties.Add('Name', $QUEST_ENUM[$buffer[$i * 0x18 + 1]]) 
        $properties.Add('DungeonLevel', $buffer[$i * 0x18]) 
        $properties.Add('QuestLevel', $buffer[$i * 0x18 + 12]) 

        $returnobject = New-Object PSobject -Property $properties
        $returnobject.psobject.TypeNames.Insert(0, 'Serpen.Diablo.Quest')
        $returnobject
    }
}

#checked
function Get-D1MonsterKills {
    param (
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession

    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType MonsterKills -Length (4 * [Serpen.Diablo.eMonster]::NUM_MTYPES)

    for ($i = 0; $i -lt 111; $i++) {
        $Properties = GenerateHashTableProperties
        
        $MonsterKills = [System.BitConverter]::ToInt32($buffer, $i * 4)
        $Properties.Add('Monster', [Serpen.Diablo.eMonster]$i)
        $Properties.Add('Kills', $MonsterKills)

        $returnobject = New-Object PSObject -Property $Properties
        $returnobject.psobject.TypeNames.Insert(0, 'Serpen.Diablo.MonsterKill')
        $returnobject
    } #foreach
}

#checked
function Get-D1HeroEquipment {
    param (
        [ValidateSet('All', 'Helm', 'Amulett', 'LeftHand', 'RightHand', 'Plate', 'LeftRing', 'RightRing')][String[]]$Position = 'All',
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession -D1Session $D1Session

    $offsets = @()

    if ($Position -contains 'All') {
        $offsets = 0..6
    }
    else {
        if ($Position -contains 'Helm') {
            $offsets += 0
        }
        if ($Position -contains 'LeftRing') {
            $offsets += 1
        }
        if ($Position -contains 'RightRing') {
            $offsets += 2
        }
        if ($Position -contains 'Amulett') {
            $offsets += 3
        }
        if ($Position -contains 'LeftHand') {
            $offsets += 4
        }
        if ($Position -contains 'RightHand') {
            $offsets += 5
        }
        if ($Position -contains 'Plate') {
            $offsets += 6
        }
    }

    $so = $D1Session.Offsets.equip - $D1Session.Offsets.ITEM_STRUCT_SIZE * 4

    foreach ($i in $offsets) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset ($so + $i * $D1Session.Offsets.ITEM_STRUCT_SIZE)
        if ($itm.Itemclass -notin ('invalid')) {
            $itm
        }
    }
}

function Get-D1Belt {
    param (
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession -D1Session $D1Session

    $Offset = $D1Session.Offsets.belt
    if (!$offset) {
        throw [System.NotSupportedException]"Belt not supported in this version"
    }

    for ([int]$i = 0; $i -lt 8; $i++) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset ($offset + $i * $D1Session.Offsets.ITEM_STRUCT_SIZE)
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

    for ([int]$i = 0; $i -lt 4 * 10; $i++) {
        $itm = ConvertTo-D1Item -D1Session $D1Session -Offset ($D1Session.Offsets.backpack + $i * $D1Session.Offsets.ITEM_STRUCT_SIZE)
        if ($itm.Itemclass -ne 'invalid') {
            $itm
        }
        else {
            break
        }
    }
}

function Get-D1Monsters {
    [CmdLetBinding()]
    param (
        $Index = -1,
        $D1Session = $Global:D1Session
    )

    $from = $Index
    $to = $Index
    if ($index -eq -1) {
        $from = 0
        $to = 200
    }
    $MONSTER_SIZE = 0xE4

    Test-D1ValidSession -D1Session $D1Session

    $REL = +32

    # first 4 are players golems

    #$MO = 0x4C9B90
    
    $of = $D1Session.offsets.monster

    for ([int]$i = $from; $i -le $to; $i++) {
        #$buffer = ReadMemory -D1Session $D1Session -OffsetType monsters -Index ($i++) -Length (0xE4)
        $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetAddress $of -Index ($i) -Length $MONSTER_SIZE

        $end = 0x40
        if ($buffer[0 + $REL] -eq 0 -and $buffer[4 + $REL] -eq 0) {
            Write-Warning "Monster count $i $($buffer[$end+$REL])"
            break
        }

        $Properties = GenerateHashTableProperties
    

        $Properties.Add('i', $i)

        $Properties.Add('active', $buffer[0x40 + $REL])
        

        $Properties.Add('typ', [System.BitConverter]::ToInt32($buffer, 0x0))
        $Properties.Add('mode', [System.BitConverter]::ToInt32($buffer, 0x4))

        $Properties.Add('X', $buffer[0x0 + $REL])
        $Properties.Add('Y', $buffer[0x4 + $REL])

        $Properties.Add('HP', [System.BitConverter]::ToInt32($buffer, 0x74 + $REL))
        $Properties.Add('HP max', [System.BitConverter]::ToInt32($buffer, 0x70 + $REL))

        $Properties.Add('Min Damage', $buffer[0x74 + $REL + 0x2c])
        $Properties.Add('Max Damage', $buffer[0x74 + $REL + 0x2c + 1])

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Verbose")) {
            $Properties.Add('_offset', $of + $i * $MONSTER_SIZE)
            $Properties.Add('_buffer', $buffer)
        }

        $returnobject = New-Object PSObject -Property $Properties
        $returnobject.psobject.TypeNames.Insert(0, 'Serpen.Diablo.Monster')
        $returnobject
    }
}

function show-D1CompleteMap {
    param($D1Session = $Global:D1Session)

    $buffer = New-Object byte[] 0x640
    for ($i = 0; $i -lt $buffer.Length; $i++) {
        $buffer[$i] = 1
    }

    $of = $D1Session.offsets.Automap

    WriteMemoryDirect -D1Session $D1Session -Data $buffer -OffsetType Automap
}

function GenerateHashTableProperties {
    param ([string]$Type)
    if ($PSVersionTable.PSVersion.Major -gt 2) {
        return [ordered]@{ }
    }
    else {
        return @{ }
    }
}

#missing properties
#   left click action, right click action, inventory space, beltable, level config

function ConvertTo-D1Item {
    param (
        [Parameter(ParameterSetName = 'File')][String]$File,
        [Parameter(ParameterSetName = 'Byte')][byte[]]$buffer,
        [Parameter(ParameterSetName = 'Session')][object]$D1Session,
        [Parameter(ParameterSetName = 'Session')][int64]$Offset
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'File') {
        $object = New-Object Serpen.Diablo.Item $File

        Write-Verbose "Processing $File"
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Byte') {
        $object = New-Object Serpen.Diablo.Item @(, $buffer)
    }
    else {
        $buffer = [array]::CreateInstance([byte], 0x170)
        [int]$read = 0
        [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle, $Offset, $buffer, $buffer.length, [ref]$read) | Out-Null
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
    $buffer = [array]::CreateInstance([byte], $D1Session.Offsets.ITEM_STRUCT_SIZE)

    if (![Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle, $item.MemoryOffset, $buffer, $buffer.length, [ref]$read)) {
        throw "Could not read item '$($item.identifiedname)'"
    }

    $filestram = [system.io.file]::Create($file)
    $filestram.Write($buffer, 0, $buffer.length)
    $filestram.Close()

}

function Suspend-D1Game {
	
    Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte], 1)
    $Buffer[0] = 2

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, $D1Session.offsets.Pause, $buffer, $buffer.length, [ref]$read)) {
        Write-Error 'Unable to suspend game'
    }
}

function Resume-D1Game {
	
    Test-D1ValidSession -D1Session $D1Session

    [int]$read = 0
    $Buffer = [array]::CreateInstance([byte], 1)
    $Buffer[0] = 0

    if (![Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, $D1Session.offsets.Pause, $buffer, $buffer.length, [ref]$read)) {
        Write-Error 'Unable to suspend game'
    }
}

#checked
function Test-ValidDiabloPlayer {
    param (
        [ValidateRange(1, 4)][byte]$PlayerIndex = 1,
        $D1Session = $Global:D1Session
    )

    $buffer = ReadMemoryDirect -D1Session $D1Session -OffsetType PlayersCount -Length 1
    
    if ($PlayerIndex -gt $buffer[0]) {
        return $false
    }
    else {
        return $true
    }
}

function Test-D1ValidSession {
    param (
        $D1Session = $Global:D1Session
    )
    if (!$D1Session) {
        throw 'No valid DiabloSession'
    }

    if ($D1Session.Offsets.Base -le 0) {
        throw 'No valid DiabloSession'
    }
}

function ReadMemory {
    param (
        $D1Session = $Global:D1Session,
        [String]$OffsetType,
        [uint16][Alias('n')]$Index = 0,
        [uint16]$Length
    )

    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], $Length)
    [int]$read = 0

    [int]$offset = (GetVersionsSpecificOffset -D1Session $D1Session $OffsetType $Index)

    if ($offset -le 0) {
        throw "$OffsetType not supported in $($D1Session.Version)"
    }

    $ret = [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle, $offset, $buffer, $buffer.Length, [ref]$read)
    
    if ($read -eq $Length) {
        return $buffer
    }
    else {
        throw "Could not read $ret $read != $Length"
    }
}
function ReadMemoryDirect {
    param (
        [Parameter(ParameterSetName = 'OffsetName', Mandatory = $true)]
        [string]$OffsetType,
        [Parameter(ParameterSetName = 'OffsetAddress', Mandatory = $true)]
        [int64]$OffsetAddress,
        [uint16][Alias('n')]$Index = 0,
        [uint16]$Length,
        $D1Session = $Global:D1Session
    )

    Test-D1ValidSession -D1Session $D1Session

    [int64]$offset = 0

    if ($PSCmdlet.ParameterSetName -eq 'OffsetName') {
        $offset = $D1Session.Offsets.$OffsetType + $Index * $Length

        if ($offset -le 0) {
            throw "$OffsetType not supported in $($D1Session.Version)"
        }
    }
    else {
        $offset = $OffsetAddress + $Index * $Length
    }

    $buffer = [array]::CreateInstance([byte], $Length)
    [int]$read = 0

    $ret = [Serpen.Wrapper.ProcessMemory]::ReadProcessMemory($D1Session.ProcessMemoryHandle, $offset, $buffer, $buffer.Length, [ref]$read)
    
    if ($read -eq $Length) {
        return $buffer
    }
    else {
        throw "Could not read $ret $read != $Length"
    }
}


function WriteMemoryDirect {
    param (
        [Parameter(Mandatory = $true)][string]$OffsetType,
        [uint16][Alias('n')]$Index = 0,
        [Parameter(Mandatory = $true)][byte[]]$Data,
        $D1Session = $Global:D1Session
    )
    
    Test-D1ValidSession -D1Session $D1Session
    
    [int64]$offset = $D1Session.Offsets.$OffsetType + $Index
    
    if ($offset -le 0) {
        throw "$OffsetType not supported in $($D1Session.Version)"
    }
    
    [int]$write = 0
    
    $ret = [Serpen.Wrapper.ProcessMemory]::WriteProcessMemory($D1Session.ProcessMemoryHandle, $offset, $Data, $Data.Length, [ref]$write)
        
    if (!$ret -or ($write -ne $data.Length)) {
        throw "Could not write $ret $write != $($data.Length)))"
    } 
}

#checked
<#
.EXAMPLE
    New-D1TownPortal -X 55 -Y 43 -Dungeon 3 -DungeonType 1 -Quest
    Townportal to hidden maze quest level
.EXAMPLE
    New-D1TownPortal -X 55 -Y 43 -Dungeon 4 -DungeonType 3 -Quest
    Poisend Water 
.EXAMPLE
    New-D1TownPortal -X 55 -Y 43 -Dungeon 5 -DungeonType 1 -Quest
    Lazarus
#>
function New-D1TownPortal {
    param (
        [Parameter(Mandatory = $true)][byte][ValidateRange(0, 16)]$Dungeon,
        [Parameter(Mandatory = $true)][byte]$X,
        [Parameter(Mandatory = $true)][byte]$Y,
        [sbyte]$DungeonType = -1,
        [switch]$Quest,
        $D1Session = $Global:D1Session
    )

    Test-D1ValidSession -D1Session $D1Session

    $buffer = [array]::CreateInstance([byte], 24)

    $buffer[00] = 1
    $buffer[04] = $X
    $buffer[08] = $y
    $buffer[12] = $Dungeon

    if ($DungeonType -eq -1) {
        if ($Dungeon -eq 0) {
            $buffer[16] = 0
        }
        elseif ($Dungeon -lt 5) {
            $buffer[16] = 1
        }
        elseif ($Dungeon -lt 9) {
            $buffer[16] = 2
        }
        elseif ($Dungeon -lt 13) {
            $buffer[16] = 3
        }
        elseif ($Dungeon -lt 20) {
            $buffer[16] = 4
        }
    }
    else {
        $buffer[16] = $DungeonType
    }

    if ($Quest) {
        $buffer[20] = 1

    }

    WriteMemoryDirect -D1Session $D1Session -OffsetType tp -data $buffer
}

function Enable-D1TownPortal {
    param (
        $D1Session = $Global:D1Session
    )
    Test-D1ValidSession -D1Session $D1Session

    WriteMemoryDirect -D1Session $D1Session -OffsetType tp -Data 1

    Write-Warning "Townportal takes effect after reload"
}

#Export-ModuleMember -Function * -Cmdlet *